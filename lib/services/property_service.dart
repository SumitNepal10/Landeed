import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:landeed/models/property.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/constant/api_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class PropertyService {
  final AuthService _authService;

  PropertyService(this._authService);

  Future<List<Map<String, dynamic>>> getRecentProperties({
    String? type,
    String? purpose,
    String? status,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, String> params = {
      'propertyClass': 'Regular',
      'limit': '5',
      if (type != null) 'type': type,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties').replace(queryParameters: params);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData.map((item) => Map<String, dynamic>.from(item)));
    } else {
      throw Exception('Failed to fetch recent properties');
    }
  }

  Future<List<Map<String, dynamic>>> getPremiumProperties({
    String? type,
    String? purpose,
    String? status,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, String> params = {
      'propertyClass': 'Premium',
      'limit': '5',
      if (type != null) 'type': type,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties').replace(queryParameters: params);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData.map((item) => Map<String, dynamic>.from(item)));
    } else {
      throw Exception('Failed to fetch premium properties');
    }
  }

  Future<List<Map<String, dynamic>>> getTopProperties({
    String? type,
    String? purpose,
    String? status,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, String> params = {
      'propertyClass': 'Top',
      'limit': '5',
      if (type != null) 'type': type,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties').replace(queryParameters: params);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData.map((item) => Map<String, dynamic>.from(item)));
    } else {
      throw Exception('Failed to fetch top properties');
    }
  }

  Future<bool> uploadProperty(Map<String, dynamic> propertyData) async {
    try {
      // Handle image paths and convert them to base64
      final List<String> imagePaths = List<String>.from(propertyData['images']);
      List<String> base64Images = [];

      for (String imagePath in imagePaths) {
        try {
          if (kIsWeb) {
            // For web, read the file as bytes and convert to base64
            final XFile file = XFile(imagePath);
            final Uint8List bytes = await file.readAsBytes();
            final String base64Image = base64Encode(bytes);
            
            // Get file extension and mime type
            final extension = imagePath.split('.').last.toLowerCase();
            final mimeType = _getMimeType(extension);
            
            // Create data URL
            final dataUrl = 'data:$mimeType;base64,$base64Image';
            base64Images.add(dataUrl);
          } else {
            final File imageFile = File(imagePath);
            if (await imageFile.exists()) {
              // Compress the image
              final compressedImage = await _compressImage(XFile(imagePath));
              
              // Convert to base64
              final bytes = await compressedImage.readAsBytes();
              final base64Image = base64Encode(bytes);
              
              // Get file extension and mime type
              final extension = imagePath.split('.').last.toLowerCase();
              final mimeType = _getMimeType(extension);
              
              // Create data URL
              final dataUrl = 'data:$mimeType;base64,$base64Image';
              base64Images.add(dataUrl);
            }
          }
        } catch (e) {
          print('Error processing image $imagePath: $e');
          // If there's an error processing the image, skip it
          continue;
        }
      }

      if (base64Images.isEmpty) {
        throw Exception('No valid images were processed');
      }

      // Get the logged-in user's email
      final userData = await _authService.getUser();
      if (userData == null || userData['email'] == null) {
        throw Exception('User email not found');
      }

      // Update the property data with encoded images and user email
      final updatedPropertyData = {
        ...propertyData,
        'images': base64Images,
        'userEmail': userData['email'],
      };

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedPropertyData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to upload property: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading property: $e');
    }
  }

  Future<List<Property>> getUserProperties() async {
    try {
      final userData = await _authService.getUser();

      if (userData == null || userData['email'] == null) {
        throw Exception('User email not found');
      }

      final url = '${ApiConstants.baseUrl}/properties/my-properties?email=${userData['email']}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // print('Raw response data for user properties: $responseData'); // Log raw data
        // Directly map the raw data to Property objects using fromJson
        return responseData.map((json) {
          try {
            final property = Property.fromJson(json);
            // print('Successfully parsed property: ${property.id}'); // Log successful parsing
            return property;
          } catch (e) {
            // print('Error parsing property JSON: $e for data: $json'); // Log parsing errors
            rethrow; // Re-throw the parsing error to be caught by the screen
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch user properties with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the caught exception after logging
      print('Error fetching user properties: $e');
      rethrow;
    }
  }

  Future<File> _compressImage(XFile file) async {
    try {
      // Get the file path
      final filePath = file.path;
      
      // Create a temporary file path for the compressed image
      final lastIndex = filePath.lastIndexOf('.');
      if (lastIndex == -1) {
        throw Exception('Invalid file path: no extension found');
      }
      
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_compressed${filePath.substring(lastIndex)}";
      
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
    } catch (e) {
      print('Error in _compressImage: $e');
      rethrow;
    }
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

  Future<List<Property>> getAllProperties({
    String? type,
    String? purpose,
    String? status,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final Map<String, String> params = {};
      if (type != null) params['type'] = type;
      if (purpose != null) params['purpose'] = purpose;
      if (status != null) params['status'] = status;
      if (location != null) params['location'] = location;
      if (minPrice != null) params['minPrice'] = minPrice.toString();
      if (maxPrice != null) params['maxPrice'] = maxPrice.toString();

      final uri = Uri.parse('${ApiConstants.baseUrl}/properties').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['properties'] ?? []);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties: \\${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception('Error fetching properties: $e');
    }
  }

  Future<Property> getPropertyById(String id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties/$id');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Property.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch property details');
    }
  }

  Future<bool> toggleFavorite(String propertyId, String userEmail) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/toggle-favorite');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': userEmail}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to toggle favorite: \\${response.body}');
    }
  }

  Future<List<Property>> getFavoriteProperties(String userEmail) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/properties/favorites?email=$userEmail');
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch favorite properties: \\${response.body}');
    }
  }
} 