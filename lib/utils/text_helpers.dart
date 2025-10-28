class TextHelpers {
  TextHelpers._();

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
}
