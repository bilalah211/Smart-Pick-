import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../constants/api_urls.dart';
import '../../constants/my_keys.dart';

class CloudinaryServices {
  ImagePicker _imagePicker = ImagePicker();

  File? file;

  Future<File?> pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Reduce quality for faster upload
        maxWidth: 512, // Limit image size
        maxHeight: 512,
      );
      if (image != null) {
        file = File(image.path);
        return file;
        print("Picked image path: ${file!.path}");
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  Future<String?> uploadImageToCloudinary(File _imageFile) async {
    final url = Uri.parse(ApiUrls.uploadImage(MyKeys.cloudName));

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = MyKeys.uploadPreset
      ..fields['folder'] = 'Products'
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final dataRequest = await response.stream.bytesToString();
      final data = jsonDecode(dataRequest);
      return data['secure_url'];
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }
}
