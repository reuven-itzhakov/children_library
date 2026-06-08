import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // הוספנו את הייבוא הזה

Future<void> uploadFileAndSaveMetadata({
  required File file,
  required String fileName,
  required String fileType, // 'word', 'pdf'
  required String ageGroup, // '0-4', '4-8', '8-12'
}) async {
  try {
    String storagePath = 'files/$fileType/$ageGroup/$fileName';

    // שולפים את כתובת ה-Bucket מההגדרות ומשתמשים בה במפורש
    String? bucketUrl = DefaultFirebaseOptions.currentPlatform.storageBucket;
    FirebaseStorage storage = bucketUrl != null
        ? FirebaseStorage.instanceFor(bucket: bucketUrl)
        : FirebaseStorage.instance;

    Reference storageRef = storage.ref().child(storagePath);

    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('materials').add({
      'file_name': fileName,
      'file_type': fileType,
      'age_group': ageGroup,
      'download_url': downloadUrl,
      'uploaded_at': FieldValue.serverTimestamp(),
    });

    print('File was uploaded successfully!');
  } catch (e) {
    print('Error uploading file: $e');
  }
}