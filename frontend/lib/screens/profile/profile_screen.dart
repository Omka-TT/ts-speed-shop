import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../components/animated_error_message.dart';
import '../../components/top_notification_widget.dart';
import '../../models/Notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import 'components/profile_menu.dart';
import 'components/profile_pic.dart';
import 'avatar_preview_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _displayMessage;
  bool _isErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.instance.getProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final errorNotification = NotificationModel(
          id: 'profile_error_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Failed to Load Profile',
          message: 'Could not load your profile. Please try again.',
          createdAt: DateTime.now(),
        );
        await TopNotificationOverlay.show(
          context,
          errorNotification,
          displayDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _pickAndPreviewAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final bytes = await image.readAsBytes();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvatarPreviewScreen(
            imageBytes: bytes,
            onConfirm: () {
              _uploadAvatar(bytes, image.name);
              Navigator.pop(context);
            },
            onChooseAnother: () {
              Navigator.pop(context);
              _pickAndPreviewAvatar(); // Pick another image
            },
          ),
        ),
      );
    }
  }

  Future<void> _uploadAvatar(Uint8List bytes, String filename) async {
    try {
      await ProfileService.instance.uploadAvatarBytes(bytes, filename);
      await _loadProfile(); // Refresh profile data
      if (mounted) {
        setState(() {
          _displayMessage = 'Avatar updated successfully';
          _isErrorMessage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayMessage = 'Failed to upload avatar: $e';
          _isErrorMessage = true;
        });
      }
    }
  }

  void _showMyAccountDialog() {
    if (_profileData == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'Username:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(
                        _profileData!['username'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'Email:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(
                        _profileData!['email'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        currentUsername: _profileData?['username'] ?? '',
        currentEmail: _profileData?['email'] ?? '',
        onSave: _handleSettingsSave,
      ),
    );
  }

  Future<void> _handleSettingsSave(String newUsername, String newEmail) async {
    try {
      // Track original values
      final originalUsername = _profileData?['username'] ?? '';
      final originalEmail = _profileData?['email'] ?? '';

      // Build update data with only changed fields
      final updateData = <String, String>{};
      if (newUsername != originalUsername && newUsername.isNotEmpty) {
        updateData['username'] = newUsername;
      }
      if (newEmail != originalEmail && newEmail.isNotEmpty) {
        updateData['email'] = newEmail;
      }

      // If nothing changed, just close dialog
      if (updateData.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      // Send only changed fields
      await ProfileService.instance.updateProfile(
        username: updateData['username'],
        email: updateData['email'],
      );

      // Refresh profile data
      await _loadProfile();

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _displayMessage = 'Profile updated successfully';
          _isErrorMessage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayMessage = 'Failed to update profile: $e';
          _isErrorMessage = true;
        });
      }
    }
  }

  void _showHelpCenterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Help Center',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: const Text('How do I change my profile picture?'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Tap the avatar on the profile page and choose a new image.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: const Text('How do I track my orders?'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Open the Orders section to see your purchase history.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: const Text('How do I add products to favorites?'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Tap the heart icon on any product.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: const Text('What payment methods are supported?'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Currently card and PayPal are supported.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: const Text('How do I contact support?'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Send an email to support@shopapp.com.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        nav.pop(); // Close dialog first
                        
                        // Clear all providers
                        final authProvider = context.read<AuthProvider>();
                        final cartProvider = context.read<CartProvider>();
                        final favoritesProvider = context.read<FavoritesProvider>();
                        final orderProvider = context.read<OrderProvider>();
                        final profileProvider = context.read<ProfileProvider>();
                        
                        // Clear all data
                        cartProvider.clear();
                        favoritesProvider.clear();
                        orderProvider.clear();
                        profileProvider.clear();
                        
                        // Logout
                        await authProvider.logout();
                        
                        if (!context.mounted) return;
                        
                        // Show logout notification
                        final logoutNotification = NotificationModel(
                          id: 'logout_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Logged Out',
                          message: 'You have been successfully logged out',
                          createdAt: DateTime.now(),
                        );
                        await TopNotificationOverlay.show(
                          context,
                          logoutNotification,
                          displayDuration: const Duration(seconds: 2),
                        );
                        
                        // Navigate to sign in
                        if (context.mounted) {
                          nav.pushNamedAndRemoveUntil(
                            '/sign_in',
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Animated message display
                  if (_displayMessage != null)
                    AnimatedErrorMessage(
                      message: _displayMessage!,
                      isError: _isErrorMessage,
                      displayDuration: const Duration(seconds: 5),
                      fadeInDuration: const Duration(seconds: 1),
                      fadeOutDuration: const Duration(milliseconds: 500),
                      onDismiss: () {
                        if (mounted) {
                          setState(() {
                            _displayMessage = null;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  ProfilePic(
                    imageUrl: _profileData?['avatar'],
                    onTap: _pickAndPreviewAvatar,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenu(
                          text: "My Account",
                          icon: "assets/icons/User Icon.svg",
                          press: _showMyAccountDialog,
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        ProfileMenu(
                          text: "Settings",
                          icon: "assets/icons/Settings.svg",
                          press: _showSettingsDialog,
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        ProfileMenu(
                          text: "Help Center",
                          icon: "assets/icons/Question mark.svg",
                          press: _showHelpCenterDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ProfileMenu(
                      text: "Log Out",
                      icon: "assets/icons/Log out.svg",
                      press: _showLogoutDialog,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Settings Dialog Widget for editing username and email
class _SettingsDialog extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final Function(String username, String email) onSave;

  const _SettingsDialog({
    required this.currentUsername,
    required this.currentEmail,
    required this.onSave,
  });

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.currentUsername,
    );
    _emailController = TextEditingController(
      text: widget.currentEmail,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _isValidEmail(_emailController.text.trim());
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _handleSave() async {
    if (!_isFormValid()) {
      setState(() {
        _errorMessage = 'Please enter valid username and email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(
        _usernameController.text.trim(),
        _emailController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Animated error message
            if (_errorMessage != null)
              AnimatedErrorMessage(
                message: _errorMessage!,
                isError: true,
                displayDuration: const Duration(seconds: 5),
                fadeInDuration: const Duration(seconds: 1),
                fadeOutDuration: const Duration(milliseconds: 500),
                onDismiss: () {
                  if (mounted) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),
            if (_errorMessage != null) const SizedBox(height: 16),

            // Username field
            TextField(
              controller: _usernameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 16),

            // Email field
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || !_isFormValid() ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
