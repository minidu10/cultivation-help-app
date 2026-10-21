package com.cultivation.app.dto;

import jakarta.validation.groups.Default;

/**
 * Validation group for create requests.
 *
 * The same request class serves POST (create) and PUT (partial update, where
 * a missing field means "leave it alone"). Required-field rules belong to
 * this group only; limits such as maximum length sit in Default and apply to
 * both. Extending Default means validating OnCreate checks both sets.
 */
public interface OnCreate extends Default {
}
