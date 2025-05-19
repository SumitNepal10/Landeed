import 'package:flutter/material.dart';
import 'package:partice_project/models/property.dart';
import 'package:partice_project/constant/colors.dart';
import 'package:partice_project/services/property_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:partice_project/utils/route_name.dart';

class PostPropertyScreen extends StatefulWidget {
  const PostPropertyScreen({Key? key}) : super(key: key);

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyService = PropertyService();
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
  String _selectedPurpose = 'For Sale';
  List<XFile> _images = [];
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
    'Commercial Space',
  ];

  final List<String> _purposes = [
    'For Sale',
    'For Rent',
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

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
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

      final success = await _propertyService.uploadProperty(
        title: _titleController.text,
        type: _selectedType,
        purpose: _selectedPurpose,
        location: _locationController.text,
        size: _sizeController.text,
        price: _priceController.text,
        isNegotiable: _isNegotiable,
        description: _descriptionController.text,
        availabilityDate: _availabilityController.text,
        contactInfo: _contactController.text,
        images: _images,
        roomDetails: roomDetails,
        features: features,
        floorLevel: _selectedFloor,
        facingDirection: _selectedDirection,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property uploaded successfully!'),
            backgroundColor: Colors.green,
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
    return Image.network(
      image.path,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey,
          child: const Icon(Icons.error),
        );
      },
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
                          ),
                          items: _propertyTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
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
                          ),
                          items: _purposes.map((String purpose) {
                            return DropdownMenuItem<String>(
                              value: purpose,
                              child: Text(purpose),
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

                  // Room Details
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
                        child: TextFormField(
                          controller: _roomsController,
                          decoration: const InputDecoration(
                            labelText: 'Bedrooms',
                            hintText: 'Number of bedrooms',
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
                            hintText: 'Number of bathrooms',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _kitchenController,
                          decoration: const InputDecoration(
                            labelText: 'Kitchen',
                            hintText: 'Number of kitchens',
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
                            hintText: 'Number of living rooms',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Features
                  const Text(
                    'Additional Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Furnished'),
                          value: _isFurnished,
                          onChanged: (value) {
                            setState(() {
                              _isFurnished = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Parking'),
                          value: _hasParking,
                          onChanged: (value) {
                            setState(() {
                              _hasParking = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Garden'),
                          value: _hasGarden,
                          onChanged: (value) {
                            setState(() {
                              _hasGarden = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Swimming Pool'),
                          value: _hasSwimmingPool,
                          onChanged: (value) {
                            setState(() {
                              _hasSwimmingPool = value!;
                            });
                          },
                        ),
                      ),
                    ],
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

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Detailed overview of the property',
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
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
                    'Property Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photos'),
                  ),
                  const SizedBox(height: 8),
                  if (_images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                _buildImagePreview(_images[index]),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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