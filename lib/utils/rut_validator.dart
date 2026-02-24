class RutValidator {
  
  /// Formats a RUT string adding dots and hyphen (e.g., 123456789 -> 12.345.678-9)
  static String format(String text) {
    if (text.isEmpty) return "";
    
    // Remove all non-numeric characters except 'k' or 'K'
    String raw = text.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    
    if (raw.length < 2) return raw;

    String dv = raw.substring(raw.length - 1);
    String body = raw.substring(0, raw.length - 1);

    // Add dots
    String formattedBody = "";
    int counter = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      formattedBody = body[i] + formattedBody;
      counter++;
      if (counter == 3 && i != 0) {
        formattedBody = ".$formattedBody";
        counter = 0;
      }
    }

    return "$formattedBody-$dv";
  }

  /// Validates if a RUT is mathematically correct using Modulo 11
  static bool isValid(String text) {
    String raw = text.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    
    if (raw.length < 7) return false; // Minimum length for a valid RUT

    String body = raw.substring(0, raw.length - 1);
    String dv = raw.substring(raw.length - 1);

    int bodyNum = int.tryParse(body) ?? 0;
    if (bodyNum == 0) return false;

    int sum = 0;
    int multiplier = 2;

    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier++;
      if (multiplier == 8) multiplier = 2;
    }

    int remainder = sum % 11;
    String calculatedDv;

    if (remainder == 0) {
      calculatedDv = '0';
    } else if (remainder == 1) {
      calculatedDv = 'K';
    } else {
      calculatedDv = (11 - remainder).toString();
    }

    return calculatedDv == dv;
  }
}
