package com.cultivation.app;

import org.junit.jupiter.api.Test;

import com.cultivation.app.support.IntegrationTest;

/**
 * Every bean wires together, every Flyway migration applies to a real
 * Postgres, and Hibernate's schema validation agrees with the result.
 */
class AppApplicationTests extends IntegrationTest {

	@Test
	void contextLoads() {
	}

}
