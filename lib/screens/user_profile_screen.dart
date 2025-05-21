import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:landeed/services/auth_service.dart';
import 'package:landeed/components/app_button.dart';
import 'package:landeed/components/app_input.dart';
import 'package:landeed/components/gap.dart';
import 'package:landeed/constant/colors.dart';

class UserProfileScreen extends StatefulWidget {
  final bool startInEditMode;

  const UserProfileScreen({
    super.key,
    this.startInEditMode = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = authService.userData;
    if (userData != null) {
      _nameController.text = userData['fullName'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _phoneController.text = userData['phoneNumber'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? profileImageBase64;
      
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        profileImageBase64 = base64Encode(bytes);
      }

      await authService.updateUserProfile(
        name: _nameController.text.trim(),
        profileImageBase64: profileImageBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userData = authService.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (userData?['profileImage'] != null
                            ? MemoryImage(base64Decode(userData!['profileImage']))
                            : null) as ImageProvider?,
                    child: userData?['profileImage'] == null && _profileImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(isWidth: false, isHeight: true, height: 24),
              AppInput(
                controller: _nameController,
                label: 'Full Name',
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const Gap(isWidth: false, isHeight: true, height: 16),
              AppInput(
                controller: _emailController,
                label: 'Email',
                enabled: false,
                keyboardType: TextInputType.emailAddress,
              ),
              const Gap(isWidth: false, isHeight: true, height: 16),
              AppInput(
                controller: _phoneController,
                label: 'Phone Number',
                enabled: false,
                keyboardType: TextInputType.phone,
              ),
              if (_isEditing) ...[
                const Gap(isWidth: false, isHeight: true, height: 24),
                AppButton(
                  onPress: _isLoading ? null : _saveProfile,
                  title: _isLoading ? 'Saving...' : 'Save Changes',
                  width: double.infinity,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 