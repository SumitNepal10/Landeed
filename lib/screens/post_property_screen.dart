import 'package:flutter/material.dart';
import 'package:landeed/models/property.dart';
import 'package:landeed/constant/colors.dart';
import 'package:landeed/services/property_service.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:landeed/utils/route_name.dart';
import 'package:provider/provider.dart';
import 'package:landeed/utils/web_image_utils.dart';

class PostPropertyScreen extends StatefulWidget {
  final Property? property;
  const PostPropertyScreen({super.key, this.property});

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PropertyService _propertyService;
  bool _isLoading = false;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _livingRoomsController = TextEditingController();

  String _selectedType = 'Apartment';
  String _selectedPurpose = 'Sale';
  final List<XFile> _images = [];
  final List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isNegotiable = false;
  bool _isFurnished = false;
  bool _hasParking = false;
  bool _hasGarden = false;
  bool _hasSwimmingPool = false;
  String _selectedFloor = 'Ground Floor';
  String _selectedDirection = 'East';

  final List<String> _propertyTypes = [
    'Land',
    'House',
    'Apartment',
    'Flat',
  ];

  final List<String> _purposes = [
    'Sale',
    'Rent',
  ];

  final List<String> _floors = [
    'Ground Floor',
    'First Floor',
    'Second Floor',
    'Third Floor',
    'Fourth Floor',
    'Fifth Floor',
  ];

  final List<String> _directions = [
    'East',
    'West',
    'North',
    'South',
    'North-East',
    'North-West',
    'South-East',
    'South-West',
  ];

  @override
  void initState() {
    super.initState();
    _propertyService = PropertyService(
      Provider.of<AuthService>(context, listen: false),
    );
    _selectedPurpose = 'Sale';

    // If editing, pre-fill fields
    final prop = widget.property;
    if (prop != null) {
      _titleController.text = prop.title;
      _locationController.text = prop.location;
      _sizeController.text = prop.area.toString();
      _priceController.text = prop.price.toString();
      _descriptionController.text = prop.description;
      _contactController.text = prop.userEmail ?? '';
      _selectedType = prop.propertyType;
      _selectedPurpose = prop.isSale ? 'Sale' : 'Rent';
      _isNegotiable = false; // You can map this if you have the field
      _existingImageUrls.clear();
      _existingImageUrls.addAll(prop.images);
      // Room details
      _roomsController.text = prop.bedrooms.toString();
      _bathroomsController.text = prop.bathrooms.toString();
      // Features, floor, direction, etc. can be mapped similarly if needed
    }
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      // Calculate how many more images can be added
      final remainingSlots = 5 - _images.length;
      final filesToAdd = pickedFiles.take(remainingSlots).toList();
      
      setState(() {
        _images.addAll(filesToAdd);
      });

      // Show warning if some images were not added
      if (pickedFiles.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only ${remainingSlots} more image(s) allowed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomDetails = {
        'bedrooms': _roomsController.text,
        'bathrooms': _bathroomsController.text,
        'kitchen': _kitchenController.text,
        'livingRooms': _livingRoomsController.text,
      };

      final features = {
        'furnished': _isFurnished,
        'parking': _hasParking,
        'garden': _hasGarden,
        'swimmingPool': _hasSwimmingPool,
      };

      final propertyData = {
        'title': _titleController.text,
        'type': _selectedType,
        'purpose': _selectedPurpose,
        'location': _locationController.text,
        'size': _sizeController.text,
        'price': _priceController.text,
        'isNegotiable': _isNegotiable,
        'description': _descriptionController.text,
        'availabilityDate': _availabilityController.text,
        'contactInfo': _contactController.text,
        'images': _existingImageUrls.map((url) => url).toList(),
        'roomDetails': roomDetails,
        'features': features,
        'floorLevel': _selectedFloor,
        'facingDirection': _selectedDirection,
      };

      // Combine existing and new images for submission
      final allImages = [
        ..._existingImageUrls, // URLs of images already on the server
        ..._images.map((image) => image.path), // New images to upload
      ];
      propertyData['images'] = allImages;

      bool success = false;
      if (widget.property != null) {
        // Editing: PATCH
        await _propertyService.editProperty(widget.property!.id, propertyData);
        success = true;
      } else {
        // Creating: POST
        success = await _propertyService.uploadProperty(propertyData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.property != null
                ? 'Property updated successfully! It will be reviewed by our team before being published.'
                : 'Property submitted successfully! It will be reviewed by our team before being published.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        // Navigate to home screen and clear the stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homeScreen,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading property: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview(XFile image) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? FutureBuilder<String>(
                    future: WebImageUtils.getImageUrl(image),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      }
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _images.remove(image);
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Property'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Property Title',
                      hintText: 'e.g., 2BHK Apartment in Lazimpat',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a property title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Property Type and Purpose
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Property Type',
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          isExpanded: true,
                          items: _propertyTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPurpose,
                          decoration: const InputDecoration(
                            labelText: 'Purpose',
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          isExpanded: true,
                          items: _purposes.map((String purpose) {
                            return DropdownMenuItem<String>(
                              value: purpose,
                              child: Text(
                                purpose,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPurpose = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dynamic fields based on property type
                  if (_selectedType != 'Land') ...[
                    // Room Details
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _roomsController,
                            decoration: const InputDecoration(
                              labelText: 'Bedrooms',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _bathroomsController,
                            decoration: const InputDecoration(
                              labelText: 'Bathrooms',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kitchenController,
                            decoration: const InputDecoration(
                              labelText: 'Kitchens',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _livingRoomsController,
                            decoration: const InputDecoration(
                              labelText: 'Living Rooms',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Features
                    Row(
                      children: [
                        Checkbox(
                          value: _isFurnished,
                          onChanged: (value) {
                            setState(() {
                              _isFurnished = value!;
                            });
                          },
                        ),
                        const Text('Furnished'),
                        Checkbox(
                          value: _hasParking,
                          onChanged: (value) {
                            setState(() {
                              _hasParking = value!;
                            });
                          },
                        ),
                        const Text('Parking'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasGarden,
                          onChanged: (value) {
                            setState(() {
                              _hasGarden = value!;
                            });
                          },
                        ),
                        const Text('Garden'),
                        Checkbox(
                          value: _hasSwimmingPool,
                          onChanged: (value) {
                            setState(() {
                              _hasSwimmingPool = value!;
                            });
                          },
                        ),
                        const Text('Swimming Pool'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'District, Municipality, Ward, Street',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Property Size and Price
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Property Size',
                            hintText: 'Area in sq. ft.',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter property size';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            hintText: 'Amount in NPR',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the price';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _isNegotiable,
                        onChanged: (value) {
                          setState(() {
                            _isNegotiable = value!;
                          });
                        },
                      ),
                      const Text('Price is negotiable'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Room Details (Floor Level and Facing Direction)
                  if (_selectedType != 'Land') ...[
                    const Text(
                      'Room Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedFloor,
                            decoration: const InputDecoration(
                              labelText: 'Floor Level',
                            ),
                            items: _floors.map((String floor) {
                              return DropdownMenuItem<String>(
                                value: floor,
                                child: Text(floor),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFloor = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDirection,
                            decoration: const InputDecoration(
                              labelText: 'Facing Direction',
                            ),
                            items: _directions.map((String direction) {
                              return DropdownMenuItem<String>(
                                value: direction,
                                child: Text(direction),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDirection = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Detailed overview of the property (70-200 words)',
                      helperText: '${_descriptionController.text.split(' ').where((word) => word.isNotEmpty).length} words',
                    ),
                    maxLines: 4,
                    onChanged: (value) {
                      setState(() {
                        // Update the helper text with word count
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      final wordCount = value.split(' ').where((word) => word.isNotEmpty).length;
                      if (wordCount < 70) {
                        return 'Description must be at least 70 words';
                      }
                      if (wordCount > 200) {
                        return 'Description cannot exceed 200 words';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Availability Date
                  TextFormField(
                    controller: _availabilityController,
                    decoration: const InputDecoration(
                      labelText: 'Availability Date',
                      hintText: 'When will the property be available?',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        _availabilityController.text = date.toString().split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Information',
                      hintText: 'Phone number or email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact information';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Photo Upload
                  const Text(
                    'Property Photos (Max 5)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text('Add Photos (${_existingImageUrls.length + _images.length}/5)'),
                  ),
                  const SizedBox(height: 8),
                  if (_existingImageUrls.isNotEmpty || _images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Existing images from server
                          ..._existingImageUrls.map((url) => Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(url, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _existingImageUrls.remove(url);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                          // New images picked in this session
                          ..._images.map((image) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildImagePreview(image),
                              )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProperty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Post Property',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _availabilityController.dispose();
    _roomsController.dispose();
    _bathroomsController.dispose();
    _kitchenController.dispose();
    _livingRoomsController.dispose();
    super.dispose();
  }
} 