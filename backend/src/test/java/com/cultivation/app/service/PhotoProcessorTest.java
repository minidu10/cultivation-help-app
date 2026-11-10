package com.cultivation.app.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.zip.CRC32;

import javax.imageio.ImageIO;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import com.cultivation.app.exception.ApiException;

class PhotoProcessorTest {

    private final PhotoProcessor processor = new PhotoProcessor();

    /**
     * A 50-byte PNG whose header claims 9000 x 9000 pixels. Decoding it would
     * allocate about 300 MB; it must be refused from the header alone.
     */
    @Test
    void anImageClaimingHugeDimensionsIsRefusedBeforeDecoding() {
        byte[] bomb = pngHeaderOnly(9_000, 9_000);

        assertThatThrownBy(() -> processor.prepare(bomb))
            .isInstanceOf(ApiException.class)
            .extracting(e -> ((ApiException) e).getStatus())
            .isEqualTo(HttpStatus.CONTENT_TOO_LARGE);
    }

    @Test
    void smallPhotosAreNeverScaledUp() throws Exception {
        PhotoProcessor.Prepared prepared = processor.prepare(jpeg(200, 150));

        BufferedImage forAi = ImageIO.read(new ByteArrayInputStream(prepared.forAi()));
        BufferedImage thumb = ImageIO.read(new ByteArrayInputStream(prepared.thumbnail()));
        assertThat(forAi.getWidth()).isEqualTo(200);
        assertThat(thumb.getWidth()).isEqualTo(200);
    }

    @Test
    void portraitPhotosAreFittedByTheirHeight() throws Exception {
        PhotoProcessor.Prepared prepared = processor.prepare(jpeg(1500, 3000));

        BufferedImage thumb = ImageIO.read(new ByteArrayInputStream(prepared.thumbnail()));
        assertThat(thumb.getHeight()).isEqualTo(320);
        assertThat(thumb.getWidth()).isEqualTo(160);
    }

    @Test
    void anEmptyUploadAsksForAPhoto() {
        assertThatThrownBy(() -> processor.prepare(new byte[0])).hasMessage("Choose a photo to check");
    }

    @Test
    void typesAreRecognisedByTheirBytes() throws Exception {
        assertThat(PhotoProcessor.isJpeg(jpeg(10, 10))).isTrue();
        assertThat(PhotoProcessor.isPng(pngHeaderOnly(10, 10))).isTrue();
        assertThat(PhotoProcessor.isJpeg("GIF89a".getBytes(StandardCharsets.US_ASCII))).isFalse();
        assertThat(PhotoProcessor.isPng(new byte[] {1, 2})).isFalse();
    }

    private static byte[] jpeg(int width, int height) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB), "jpeg", out);
        return out.toByteArray();
    }

    /** PNG signature plus a valid IHDR chunk, and no image data at all. */
    private static byte[] pngHeaderOnly(int width, int height) {
        ByteBuffer ihdr = ByteBuffer.allocate(13)
            .putInt(width).putInt(height)
            .put((byte) 8)   // bit depth
            .put((byte) 2)   // colour type: RGB
            .put((byte) 0).put((byte) 0).put((byte) 0);
        byte[] type = "IHDR".getBytes(StandardCharsets.US_ASCII);
        CRC32 crc = new CRC32();
        crc.update(type);
        crc.update(ihdr.array());

        return ByteBuffer.allocate(8 + 4 + 4 + 13 + 4)
            .put(new byte[] {(byte) 0x89, 'P', 'N', 'G', '\r', '\n', 0x1A, '\n'})
            .putInt(13).put(type).put(ihdr.array()).putInt((int) crc.getValue())
            .array();
    }
}
