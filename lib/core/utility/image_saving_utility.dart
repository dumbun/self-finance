import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:uuid/uuid.dart';

class ImageSavingUtility {
  static Future<XFile?> doPickImage({required bool camera}) async {
    final ImagePicker picker = ImagePicker();
    if (camera) {
      return await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
    } else {
      return await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    }
  }

  static Future<String> saveImage({
    required String location,
    XFile? image,
  }) async {
    // [captureAndSaveCustomerImage]
    /*
    This function:
    1.Opens camera
    2.Creates customers/{customerId} folder
    3.Saves image with timestamp
    4.Returns saved path
   */

    if (image == null) return "";

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory locationPath = Directory('${appDir.path}/Images/$location');

    if (!await locationPath.exists()) {
      await locationPath.create(recursive: true);
    }

    const uuid = Uuid();
    final String imageName =
        "photo_${DateTime.now().millisecondsSinceEpoch}_${uuid.v1()}_${DateTime.now()}.jpg";
    final String filePath = '${locationPath.path}/$imageName';
    await File(image.path).copy(filePath);
    return p.join("Images", location, imageName);
  }

  static Future<String> updateCustomerImage({
    required Customer customer,
    required bool camera,
  }) async {
    final XFile? newImage = await doPickImage(camera: camera);

    if (newImage == null) return customer.photo;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory customerDir = Directory('${appDir.path}/Images/customers');

    if (!await customerDir.exists()) {
      await customerDir.create(recursive: true);
    }

    /// 🔥 Delete old image if exists
    if (customer.photo.isNotEmpty) {
      final oldFile = File(customer.photo);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    /// 💾 Save new image
    const uuid = Uuid();
    final String imageName =
        "photo_${DateTime.now().millisecondsSinceEpoch}_${uuid.v1()}_${DateTime.now()}.jpg";
    final String newPath = '${customerDir.path}/$imageName';
    await File(newImage.path).copy(newPath);
    return p.join('Images', "customers", imageName);
  }

  static Future<String> updateCustomerProof({
    required Customer customer,
    required bool camera,
  }) async {
    final XFile? newImage = await doPickImage(camera: camera);

    if (newImage == null) return customer.proof;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory customerDir = Directory('${appDir.path}/Images/proof');

    if (!await customerDir.exists()) {
      await customerDir.create(recursive: true);
    }

    /// 🔥 Delete old image if exists
    if (customer.proof.isNotEmpty) {
      final File oldFile = File(customer.proof);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    /// 💾 Save new image
    const Uuid uuid = Uuid();
    final String imageName =
        "photo_${DateTime.now().millisecondsSinceEpoch}_${uuid.v1()}_${DateTime.now()}.jpg";
    final String newPath = '${customerDir.path}/$imageName';
    await File(newImage.path).copy(newPath);
    return p.join('Images', "proof", imageName);
  }

  static Future<String> updateUserImage({
    required String userImage,
    required bool camera,
  }) async {
    final XFile? newImage = await doPickImage(camera: camera);

    if (newImage == null) return userImage;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory customerDir = Directory('${appDir.path}/Images/user');

    if (!await customerDir.exists()) {
      await customerDir.create(recursive: true);
    }

    /// 🔥 Delete old image if exists
    if (userImage.isNotEmpty) {
      final File oldFile = File(userImage);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    /// 💾 Save new image
    const Uuid uuid = Uuid();
    final String newImageName =
        "photo_${DateTime.now().millisecondsSinceEpoch}_${uuid.v1()}_${DateTime.now()}.jpg";
    final String newPath = '${customerDir.path}/$newImageName';
    await File(newImage.path).copy(newPath);
    return p.join('Images', 'user', newPath);
  }
}
