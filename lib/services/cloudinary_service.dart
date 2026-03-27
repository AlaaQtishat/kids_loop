import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kids_loop/utilities/app_keys.dart';

class CloudinaryService {
  static Future<String?> uploadToCloudinary(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppKeys.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = AppKeys.cloudinaryUploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    if (response.statusCode == 200) {
      return decoded['secure_url'];
    } else {
      throw Exception(decoded['error']['message']);
    }
  }
}
