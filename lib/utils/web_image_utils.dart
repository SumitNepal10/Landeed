// Conditional import for web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class WebImageUtils {
  static Future<String> getImageUrl(XFile file) async {
    if (kIsWeb) {
      // For web, read the file as bytes and convert to base64
      final Uint8List bytes = await file.readAsBytes();
      final String base64Image = base64Encode(bytes);
      
      // Get file extension and mime type
      final extension = file.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      
      // Create data URL
      return 'data:$mimeType;base64,$base64Image';
    } else {
      // For mobile platforms, return the file path
      return file.path;
    }
  }

  static String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default to JPEG if unknown
    }
  }
} 