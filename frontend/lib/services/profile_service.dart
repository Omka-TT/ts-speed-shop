import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dio_client.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._internal();

  ProfileService._internal();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await DioClient.instance.get('/profile/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      final response = await DioClient.instance.patch('/profile/', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>> uploadAvatarBytes(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          bytes,
          filename: filename,
        ),
      });

      final response = await DioClient.instance.patch(
        '/profile/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return uploadAvatarBytes(bytes, imageFile.name);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}