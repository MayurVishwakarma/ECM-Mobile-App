import 'package:translator/translator.dart';

class TranslationHelper {
  // static final _translator = GoogleTranslator();
  static final GoogleTranslator _translator = GoogleTranslator();

  static Future<String> translateToHindi(String text) async {
    try {
      var translation = await _translator.translate(text, from: 'en', to: 'hi');
      String translatedText = translation.text;

      // If translation didn't change much, do literal transliteration
      if (_isMostlySame(text, translatedText)) {
        translatedText = _literalTransliterate(text);
      }

      return translatedText;
    } catch (e) {
      return _literalTransliterate(text); // Fallback to transliteration
    }
  }

  /// Check if translation is basically unchanged
  static bool _isMostlySame(String original, String translated) {
    // Removing spaces and comparing lowercase
    String o = original.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    String t = translated.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return o == t;
  }

  /// Literal English → Hindi transliteration (basic mapping)
  static String _literalTransliterate(String text) {
    Map<String, String> mapping = {
      'a': 'ए',
      'b': 'बी',
      'c': 'सी',
      'd': 'डी',
      'e': 'ई',
      'f': 'एफ',
      'g': 'जी',
      'h': 'एच',
      'i': 'आई',
      'j': 'जे',
      'k': 'के',
      'l': 'एल',
      'm': 'एम',
      'n': 'एन',
      'o': 'ओ',
      'p': 'पी',
      'q': 'क्यू',
      'r': 'आर',
      's': 'एस',
      't': 'टी',
      'u': 'यू',
      'v': 'वी',
      'w': 'डब्ल्यू',
      'x': 'एक्स',
      'y': 'वाई',
      'z': 'जेड',
      '0': '०',
      '1': '१',
      '2': '२',
      '3': '३',
      '4': '४',
      '5': '५',
      '6': '६',
      '7': '७',
      '8': '८',
      '9': '९'
    };

    StringBuffer result = StringBuffer();
    for (var char in text.split('')) {
      String lower = char.toLowerCase();
      if (mapping.containsKey(lower)) {
        result.write(mapping[lower]);
      } else {
        result.write(char); // Keep as is if not in map
      }
    }
    return result.toString();
  }
  /*static Future<String> translateToHindi(String text) async {
    try {
      // Step 1: Try normal translation
      var translation = await _translator.translate(text, from: 'en', to: 'hi');

      // Step 2: If nothing changed (means no proper translation), do literal transliteration
      if (translation.text.trim().toLowerCase() == text.trim().toLowerCase()) {
        return _transliterateToHindi(text);
      }

      return translation.text;
    } catch (e) {
      return _transliterateToHindi(text); // fallback to transliteration
    }
  }

  /// Simple literal transliteration function (A=ए, B=बी, etc.)
  static String _transliterateToHindi(String text) {
    final Map<String, String> letterMap = {
      'a': 'ए',
      'b': 'बी',
      'c': 'सी',
      'd': 'डी',
      'e': 'ई',
      'f': 'एफ',
      'g': 'जी',
      'h': 'एच',
      'i': 'आई',
      'j': 'जे',
      'k': 'के',
      'l': 'एल',
      'm': 'एम',
      'n': 'एन',
      'o': 'ओ',
      'p': 'पी',
      'q': 'क्यू',
      'r': 'आर',
      's': 'एस',
      't': 'टी',
      'u': 'यू',
      'v': 'वी',
      'w': 'डब्ल्यू',
      'x': 'एक्स',
      'y': 'वाई',
      'z': 'जेड',
    };

    StringBuffer hindiText = StringBuffer();
    for (var char in text.split('')) {
      String lowerChar = char.toLowerCase();
      if (letterMap.containsKey(lowerChar)) {
        hindiText.write(letterMap[lowerChar]!);
      } else {
        hindiText.write(char); // keep symbols/numbers as is
      }
    }
    return hindiText.toString();
  }
*/
  // /// Translate text from English to Hindi
  // static Future<String> translateToHindi(String text) async {
  //   try {
  //     var translation = await _translator.translate(text, from: 'en', to: 'hi');
  //     return translation.text;
  //   } catch (e) {
  //     return text; // fallback to original if API fails
  //   }
  // }

  /// Translate text to English from Hindi
  static Future<String> translateToEnglish(String text) async {
    try {
      var translation = await _translator.translate(text, from: 'hi', to: 'en');
      return translation.text;
    } catch (e) {
      return text;
    }
  }
}
