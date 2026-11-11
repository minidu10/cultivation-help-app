import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agromaster/core/theme/app_theme.dart';

void main() {
  // Regression: the transparent app bar was read as dark, so the light theme
  // got white status bar icons that could not be seen.
  test('the light theme draws dark status bar icons', () {
    final style = AppTheme.light().appBarTheme.systemOverlayStyle!;
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });

  test('the dark theme draws light status bar icons', () {
    final style = AppTheme.dark().appBarTheme.systemOverlayStyle!;
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });
}
