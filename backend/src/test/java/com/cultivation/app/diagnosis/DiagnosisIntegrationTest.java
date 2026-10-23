package com.cultivation.app.diagnosis;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.ExpectedCount.manyTimes;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.http.client.MockClientHttpRequest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.support.IntegrationTest;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

@TestPropertySource(properties = "app.diagnosis.daily-limit=3")
class DiagnosisIntegrationTest extends IntegrationTest {

    private static final ObjectMapper JSON = new ObjectMapper();

    private static final Map<String, Object> BLAST = Map.ofEntries(
        Map.entry("isPlant", true),
        Map.entry("cropGuess", "Rice"),
        Map.entry("condition", "Rice blast"),
        Map.entry("confidence", 0.82),
        Map.entry("severity", "moderate"),
        Map.entry("seeExpert", false),
        Map.entry("symptoms", List.of("Diamond-shaped grey lesions")),
        Map.entry("treatmentOrganic", List.of("Remove badly affected leaves")),
        Map.entry("treatmentChemical", List.of("Tricyclazole, as the label directs")),
        Map.entry("prevention", List.of("Avoid excess nitrogen")),
        Map.entry("model", "vision-test"));

    @Autowired
    @Qualifier("aiRestTemplate")
    private RestTemplate ai;

    private MockRestServiceServer server;
    private final List<Map<String, Object>> sentToAi = new ArrayList<>();

    @BeforeEach
    void stubAi() {
        sentToAi.clear();
        server = MockRestServiceServer.bindTo(ai).ignoreExpectOrder(true).build();
    }

    private void aiAnswers(Map<String, Object> answer) {
        server.expect(manyTimes(), requestTo("http://localhost:1/ai/diagnose")).andRespond(request -> {
            @SuppressWarnings("unchecked")
            Map<String, Object> body = JSON.readValue(((MockClientHttpRequest) request).getBodyAsString(), Map.class);
            sentToAi.add(body);
            return withSuccess(JSON.writeValueAsString(answer), MediaType.APPLICATION_JSON).createResponse(request);
        });
    }

    private long paddy(Session session) throws Exception {
        return createCrop(session, Map.of("name", "Paddy", "variety", "BG 300", "plantingDate", "2026-05-01"));
    }

    private ResultActions upload(Session session, long cropId, byte[] bytes, String filename, String note)
            throws Exception {
        var request = multipart("/api/crops/" + cropId + "/diagnoses")
            .file(new MockMultipartFile("image", filename, "image/jpeg", bytes))
            .header(HttpHeaders.AUTHORIZATION, session.bearer());
        if (note != null) {
            request.param("note", note);
        }
        return mockMvc.perform(request);
    }

    // ----------------------------------------------------------- happy path

    @Test
    void aPhotoIsDiagnosedAndKeptInTheCropsHistory() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        long crop = paddy(session);

        ResultActions result = upload(session, crop, photo(2400, 1800, "jpg"), "leaf.jpg", "Spots on lower leaves")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.isPlant").value(true))
            .andExpect(jsonPath("$.condition").value("Rice blast"))
            .andExpect(jsonPath("$.confidence").value(0.82))
            .andExpect(jsonPath("$.treatmentChemical[0]").value("Tricyclazole, as the label directs"))
            .andExpect(jsonPath("$.note").value("Spots on lower leaves"));
        long id = idOf(result);

        assertThat(list(getAs(session, "/api/crops/" + crop + "/diagnoses"))).hasSize(1);
        getAs(session, "/api/crops/" + crop + "/diagnoses/" + id)
            .andExpect(jsonPath("$.prevention[0]").value("Avoid excess nitrogen"));
    }

    @Test
    void theModelGetsAShrunkCleanJpegAndTheCropName() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        long crop = paddy(session);

        upload(session, crop, photo(2400, 1800, "png"), "leaf.png", null).andExpect(status().isOk());

        Map<String, Object> sent = sentToAi.get(0);
        assertThat(sent.get("crop_hint")).isEqualTo("Paddy (BG 300)");
        assertThat(sent.get("mime_type")).isEqualTo("image/jpeg");
        BufferedImage forAi = ImageIO.read(new ByteArrayInputStream(
            Base64.getDecoder().decode((String) sent.get("image_base64"))));
        assertThat(Math.max(forAi.getWidth(), forAi.getHeight())).isEqualTo(1024);
    }

    @Test
    void onlyASmallThumbnailIsStored() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        long crop = paddy(session);
        String url = JsonPath.read(upload(session, crop, photo(2400, 1800, "jpg"), "leaf.jpg", null)
            .andReturn().getResponse().getContentAsString(), "$.thumbnailUrl");

        byte[] thumb = getAs(session, url)
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.IMAGE_JPEG))
            .andReturn().getResponse().getContentAsByteArray();

        BufferedImage image = ImageIO.read(new ByteArrayInputStream(thumb));
        assertThat(image.getWidth()).isEqualTo(320);
        assertThat(image.getHeight()).isEqualTo(240);
    }

    @Test
    void deletingRemovesTheDiagnosisAndItsPhoto() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        long crop = paddy(session);
        long id = idOf(upload(session, crop, photo(800, 600, "jpg"), "leaf.jpg", null));

        deleteAs(session, "/api/crops/" + crop + "/diagnoses/" + id).andExpect(status().isNoContent());

        assertThat(list(getAs(session, "/api/crops/" + crop + "/diagnoses"))).isEmpty();
        getAs(session, "/api/crops/" + crop + "/diagnoses/" + id + "/thumbnail").andExpect(status().isNotFound());
    }

    @Test
    void aPhotoThatIsNotAPlantIsAnsweredButNotKept() throws Exception {
        aiAnswers(Map.of("isPlant", false, "condition", "Not a plant", "confidence", 0.0, "severity", "none"));
        Session session = register();
        long crop = paddy(session);

        upload(session, crop, photo(800, 600, "jpg"), "thumb.jpg", null)
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.isPlant").value(false))
            .andExpect(jsonPath("$.id").doesNotExist());

        assertThat(list(getAs(session, "/api/crops/" + crop + "/diagnoses"))).isEmpty();
    }

    // ------------------------------------------------------------- refusals

    @Test
    void anotherFarmersCropIsRefusedBeforeAnyAiCall() throws Exception {
        aiAnswers(BLAST);
        Session owner = register();
        long crop = paddy(owner);

        upload(register(), crop, photo(800, 600, "jpg"), "leaf.jpg", null).andExpect(status().isNotFound());
        assertThat(sentToAi).isEmpty();
    }

    @Test
    void aFileThatIsNotAnImageIsRefusedWhateverItsName() throws Exception {
        aiAnswers(BLAST);
        Session session = register();

        upload(session, paddy(session), "not really a photo".getBytes(), "leaf.jpg", null)
            .andExpect(status().isUnsupportedMediaType());
        assertThat(sentToAi).isEmpty();
    }

    @Test
    void gifsAreNotAccepted() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        byte[] gif = "GIF89a....".getBytes();

        upload(session, paddy(session), gif, "leaf.gif", null).andExpect(status().isUnsupportedMediaType());
    }

    @Test
    void aCorruptJpegIsRefusedClearly() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        byte[] corrupt = new byte[2048];
        corrupt[0] = (byte) 0xFF;
        corrupt[1] = (byte) 0xD8;
        corrupt[2] = (byte) 0xFF;

        upload(session, paddy(session), corrupt, "leaf.jpg", null)
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("That photo could not be read. Try taking it again."));
    }

    @Test
    void aPhotoOverFiveMegabytesIsTooLarge() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        byte[] big = Arrays.copyOf(photo(800, 600, "jpg"), 5 * 1024 * 1024 + 1);

        upload(session, paddy(session), big, "leaf.jpg", null).andExpect(status().is(413));
    }

    @Test
    void aLongNoteIsRefused() throws Exception {
        aiAnswers(BLAST);
        Session session = register();

        upload(session, paddy(session), photo(800, 600, "jpg"), "leaf.jpg", "x".repeat(301))
            .andExpect(status().isBadRequest());
    }

    @Test
    void theDailyLimitStopsFurtherChecks() throws Exception {
        aiAnswers(BLAST);
        Session session = register();
        long crop = paddy(session);
        byte[] leaf = photo(800, 600, "jpg");

        for (int i = 0; i < 3; i++) {
            upload(session, crop, leaf, "leaf.jpg", null).andExpect(status().isOk());
        }
        upload(session, crop, leaf, "leaf.jpg", null).andExpect(status().isTooManyRequests());
        assertThat(sentToAi).hasSize(3);
    }

    @Test
    void anAiOutageIs503AndNothingIsSaved() throws Exception {
        server.expect(manyTimes(), requestTo("http://localhost:1/ai/diagnose")).andRespond(withServerError());
        Session session = register();
        long crop = paddy(session);

        upload(session, crop, photo(800, 600, "jpg"), "leaf.jpg", null).andExpect(status().isServiceUnavailable());

        assertThat(list(getAs(session, "/api/crops/" + crop + "/diagnoses"))).isEmpty();
    }

    // -------------------------------------------------------------- fixture

    /** A leaf-ish picture: green with a few brown spots, so it is not a flat colour. */
    private static byte[] photo(int width, int height, String format) throws Exception {
        BufferedImage image = new BufferedImage(width, height,
            "png".equals(format) ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(new Color(46, 125, 50));
        g.fillRect(0, 0, width, height);
        g.setColor(new Color(121, 85, 72));
        for (int i = 0; i < 12; i++) {
            g.fillOval(width * i / 12, height / 3 + (i % 3) * height / 8, width / 20, height / 20);
        }
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(image, "jpg".equals(format) ? "jpeg" : "png", out);
        return out.toByteArray();
    }
}
