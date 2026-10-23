package com.cultivation.app.alerts;

import static org.hamcrest.Matchers.allOf;
import static org.hamcrest.Matchers.containsString;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.client.ExpectedCount.manyTimes;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.CacheManager;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import com.cultivation.app.service.ReminderNotificationJob;
import com.cultivation.app.support.IntegrationTest;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * The whole path from reminder to alert, with OpenWeather replaced by a stub
 * that serves forecasts built relative to "now", so the test means the same
 * thing whatever day it runs.
 */
@TestPropertySource(properties = {
    "weather.openweather.api-key=test-key",
    "app.reminders.email-enabled=true",
    "app.reminders.lead-days=2,1"
})
class WeatherAlertIntegrationTest extends IntegrationTest {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private static final ObjectMapper JSON = new ObjectMapper();
    private static final LocalDate TOMORROW = LocalDate.now().plusDays(1);

    @Autowired
    @Qualifier("openWeatherRestTemplate")
    private RestTemplate openWeather;

    @Autowired
    private CacheManager caches;

    @Autowired
    private ReminderNotificationJob digestJob;

    private MockRestServiceServer server;

    /** A single weather condition for one 3-hour slot. */
    private record Weather(double chance, double mm, double wind, double temp) {
        static final Weather FINE = new Weather(0.1, 0, 2, 30);
    }

    @BeforeEach
    void freshStub() {
        // Forecasts are cached by place; each test brings its own weather.
        caches.getCacheNames().forEach(name -> caches.getCache(name).clear());
        server = MockRestServiceServer.bindTo(openWeather).ignoreExpectOrder(true).build();
        server.expect(manyTimes(), requestTo(allOf(containsString("/geo/1.0/direct"), containsString("q=Polonnaruwa"))))
            .andRespond(withSuccess("[{\"name\":\"Polonnaruwa\",\"country\":\"LK\",\"lat\":7.94,\"lon\":81.0}]",
                                    MediaType.APPLICATION_JSON));
        server.expect(manyTimes(), requestTo(allOf(containsString("/geo/1.0/direct"), containsString("q=North"))))
            .andRespond(withSuccess("[]", MediaType.APPLICATION_JSON));
    }

    private void forecast(Function<LocalDateTime, Weather> weather) throws Exception {
        server.expect(manyTimes(), requestTo(containsString("/data/2.5/forecast")))
            .andRespond(withSuccess(forecastJson(weather), MediaType.APPLICATION_JSON));
    }

    /** Rain tomorrow from noon to 6 PM; fine otherwise. */
    private static Weather rainTomorrowAfternoon(LocalDateTime slot) {
        boolean wet = slot.toLocalDate().equals(TOMORROW) && slot.getHour() >= 12 && slot.getHour() < 18;
        return wet ? new Weather(0.85, 6, 3, 28) : Weather.FINE;
    }

    @Test
    void fertilizerBeforeRainIsFlaggedWithABetterDay() throws Exception {
        forecast(WeatherAlertIntegrationTest::rainTomorrowAfternoon);
        Session session = register();
        long crop = createCrop(session, Map.of("name", "Paddy", "plantingDate", "2026-05-01",
                                               "fieldLocation", "Polonnaruwa"));
        long reminder = addReminder(session, crop, TOMORROW.atTime(9, 0).format(ISO));

        getAs(session, "/api/alerts")
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].type").value("RAIN_WASHOFF"))
            .andExpect(jsonPath("$[0].severity").value("HIGH"))
            .andExpect(jsonPath("$[0].reminderId").value(reminder))
            .andExpect(jsonPath("$[0].cropName").value("Paddy"))
            .andExpect(jsonPath("$[0].location").value("Polonnaruwa, LK"))
            .andExpect(jsonPath("$[0].rainChancePercent").value(85))
            .andExpect(jsonPath("$[0].suggestedAt").value(TOMORROW.plusDays(1).atTime(9, 0).format(ISO)))
            .andExpect(jsonPath("$[0].message").value(containsString("may wash off")));
    }

    @Test
    void anUnrecognisedFieldNameFallsBackToTheFarmersTown() throws Exception {
        forecast(WeatherAlertIntegrationTest::rainTomorrowAfternoon);
        Session session = register();   // registered with city Polonnaruwa
        long crop = createCrop(session, Map.of("name", "Chilli", "plantingDate", "2026-05-01",
                                               "fieldLocation", "North Field"));
        addReminder(session, crop, TOMORROW.atTime(9, 0).format(ISO));

        getAs(session, "/api/alerts")
            .andExpect(jsonPath("$[0].type").value("RAIN_WASHOFF"))
            .andExpect(jsonPath("$[0].location").value("Polonnaruwa, LK"));
    }

    @Test
    void fineWeatherMeansNoAlerts() throws Exception {
        forecast(slot -> Weather.FINE);
        Session session = register();
        long crop = createCrop(session, "Paddy");
        addReminder(session, crop, TOMORROW.atTime(9, 0).format(ISO));

        getAs(session, "/api/alerts").andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void aHeatwaveWarnsOncePerPlaceNamingEveryCrop() throws Exception {
        forecast(slot -> slot.toLocalDate().equals(TOMORROW) && slot.getHour() == 12
            ? new Weather(0.0, 0, 2, 37) : Weather.FINE);
        Session session = register();
        createCrop(session, "Paddy");
        createCrop(session, "Chilli");

        getAs(session, "/api/alerts")
            .andExpect(jsonPath("$.length()").value(1))
            .andExpect(jsonPath("$[0].type").value("HEAT_STRESS"))
            .andExpect(jsonPath("$[0].cropName").value(containsString("Paddy")))
            .andExpect(jsonPath("$[0].cropName").value(containsString("Chilli")))
            .andExpect(jsonPath("$[0].maxTempC").value(37.0));
    }

    @Test
    void anOpenWeatherOutageMeansNoAlertsNotAnError() throws Exception {
        server.expect(manyTimes(), requestTo(containsString("/data/2.5/forecast"))).andRespond(withServerError());
        Session session = register();
        long crop = createCrop(session, "Paddy");
        addReminder(session, crop, TOMORROW.atTime(9, 0).format(ISO));

        getAs(session, "/api/alerts").andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void theDailyEmailCarriesTheWarning() throws Exception {
        forecast(WeatherAlertIntegrationTest::rainTomorrowAfternoon);
        Session session = register();
        long crop = createCrop(session, Map.of("name", "Paddy", "plantingDate", "2026-05-01",
                                               "fieldLocation", "Polonnaruwa"));
        addReminder(session, crop, TOMORROW.atTime(9, 0).format(ISO));

        digestJob.sendUpcomingDigests();

        verify(mailService).sendReminderDigest(
            eq(session.email()), anyString(), contains("WEATHER: Rain likely"), eq(1));
    }

    @Test
    void theFiveDayForecastHasOneRowPerDay() throws Exception {
        forecast(slot -> Weather.FINE);

        // 40 three-hour slots from now cover five days, plus part of a sixth
        // unless they happen to start exactly at midnight.
        mockMvc.perform(get("/api/weather/daily").param("lat", "7.94").param("lon", "81.0"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.location").value("Polonnaruwa, LK"))
            .andExpect(jsonPath("$.days.length()").value(org.hamcrest.Matchers.either(
                org.hamcrest.Matchers.is(5)).or(org.hamcrest.Matchers.is(6))))
            .andExpect(jsonPath("$.days[0].maxTempC").value(30.0));
    }

    // ------------------------------------------------------------ fixture

    /**
     * An OpenWeather /forecast body: 40 slots on the 3-hour grid, starting
     * with the slot that contains "now", in the server's own time zone.
     */
    private static String forecastJson(Function<LocalDateTime, Weather> weather) throws Exception {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime start = now.toLocalDate().atTime(now.getHour() / 3 * 3, 0);
        List<Map<String, Object>> list = new ArrayList<>();
        for (int i = 0; i < 40; i++) {
            LocalDateTime slot = start.plusHours(3L * i);
            Weather w = weather.apply(slot);
            list.add(Map.of(
                "dt", slot.atZone(ZoneId.systemDefault()).toEpochSecond(),
                "main", Map.of("temp", w.temp(), "temp_max", w.temp(), "humidity", 70),
                "weather", List.of(Map.of("description", w.mm() > 0 ? "moderate rain" : "clear sky",
                                          "icon", w.mm() > 0 ? "10d" : "01d")),
                "pop", w.chance(),
                "rain", Map.of("3h", w.mm()),
                "wind", Map.of("speed", w.wind()),
                "dt_txt", slot.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))));
        }
        return JSON.writeValueAsString(Map.of(
            "list", list,
            "city", Map.of("name", "Polonnaruwa", "country", "LK")));
    }
}
