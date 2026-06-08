import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadFileAndSaveMetadata({
  required File file,
  required String fileName,
  required String fileType, // 'word', 'pdf'
  required String ageGroup, // '0-4', '4-8', '8-12'
}) async {
  try {
    String storagePath = 'files/$fileType/$ageGroup/$fileName';
    Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);

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

    print('File was uploaded successfully.!');
  } catch (e) {
    print('Error uploading file: $e');
  }
}