import 'dart:convert';

class ImageUtils {
  static String getProfileImageUrl(dynamic pathData) {
    const String defaultImage = 'https://i.pravatar.cc/150';
    if (pathData == null || pathData.toString().isEmpty) {
      return defaultImage;
    }
    final String pathString = pathData.toString();
    
    // Try to parse as JSON
    try {
      if (pathString.startsWith('{')) {
        final Map<String, dynamic> decoded = jsonDecode(pathString);
        if (decoded.containsKey('profile') && decoded['profile'] != null) {
          return decoded['profile'].toString();
        }
      } else if (pathString.startsWith('[')) {
        final List<dynamic> decoded = jsonDecode(pathString);
        if (decoded.isNotEmpty && decoded[0] != null) {
          return decoded[0].toString();
        }
      }
    } catch (_) {
      // Not JSON or parse error, fallback to returning the string directly
    }

    // If it's a URL, return it directly
    if (pathString.startsWith('http')) {
      return pathString;
    }

    return defaultImage;
  }
}
