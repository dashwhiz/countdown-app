import 'dart:math';
import 'package:flutter/material.dart';

class HelperFunctions {
  HelperFunctions._();

  // ========== Text Helpers ==========

  /// Capitalizes the first letter of a string.
  /// Returns empty string if input is null or empty.
  static String capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return '';
    if (text.length == 1) return text.toUpperCase();
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizes the first letter of each sentence.
  /// Sentences are determined by periods followed by spaces.
  static String capitalizeSentences(String? text) {
    if (text == null || text.isEmpty) return '';

    final sentences = text.split('. ');
    final capitalizedSentences = sentences.map((sentence) {
      if (sentence.isEmpty) return sentence;
      return capitalizeFirst(sentence);
    }).toList();

    return capitalizedSentences.join('. ');
  }

  // ========== Color Helpers ==========

  /// Calculate appropriate text color (white or black) based on background luminance.
  /// Uses W3C formula for calculating relative luminance.
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate relative luminance using the W3C formula
    final r = backgroundColor.r;
    final g = backgroundColor.g;
    final b = backgroundColor.b;

    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    final luminance = 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;

    // Use white text for dark backgrounds, black text for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
