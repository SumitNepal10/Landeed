import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:partice_project/models/property.dart';
import 'package:partice_project/services/auth_service.dart';
import 'package:partice_project/constant/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class PropertyService {
  final AuthService _authService = AuthService();

  Future<bool> uploadProperty({
    required String title,
    required String type,
    required String purpose,
    required String location,
    required String size,
    required String price,
    required bool isNegotiable,
    required String description,
    required String availabilityDate,
    required String contactInfo,
    required List<XFile> images,
    required Map<String, dynamic> roomDetails,
    required Map<String, bool> features,
    required String floorLevel,
    required String facingDirection,
  }) async {
    try {
      // Get current user's token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Convert and compress images to base64
      List<String> base64Images = [];
      for (var image in images) {
        try {
          // Compress the image
          final compressedImage = await _compressImage(image);
          
          // Convert to base64
          final bytes = await compressedImage.readAsBytes();
          String base64Image = base64Encode(bytes);
          String extension = image.path.split('.').last.toLowerCase();
          String mimeType = _getMimeType(extension);
          base64Images.add('data:$mimeType;base64,$base64Image');
        } catch (e) {
          print('Error processing image: $e');
          continue;
        }
      }

      // Map purpose to backend enum values
      String mappedPurpose = purpose == 'For Sale' ? 'Sale' : 'Rent';

      // Prepare property data
      final propertyData = {
        'title': title,
        'type': type,
        'purpose': mappedPurpose,
        'location': location,
        'size': size,
        'price': price,
        'isNegotiable': isNegotiable,
        'description': description,
        'availabilityDate': availabilityDate,
        'contactInfo': contactInfo,
        'images': base64Images,
        'roomDetails': roomDetails,
        'features': features,
        'floorLevel': floorLevel,
        'facingDirection': facingDirection,
      };

      // Make API request to upload property
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(propertyData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to upload property: ${response.body}');
      }
    } catch (e) {
      print('Error uploading property: $e');
      rethrow;
    }
  }

  Future<File> _compressImage(XFile file) async {
    // Get the file path
    final filePath = file.path;
    
    // Create a temporary file path for the compressed image
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    
    // Compress the image
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 50, // Adjust quality (0-100)
      minWidth: 1024, // Maximum width
      minHeight: 1024, // Maximum height
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }

  String _getMimeType(String extension) {
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