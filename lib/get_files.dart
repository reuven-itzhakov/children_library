import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchSpecificFiles(String fileType, String ageGroup) async {
  List<Map<String, dynamic>> filesData = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('materials')
        .where('file_type', isEqualTo: fileType)
        .where('age_group', isEqualTo: ageGroup)
        .get();

    for (var doc in querySnapshot.docs) {
      filesData.add(doc.data() as Map<String, dynamic>);
    }

    return filesData;
  } catch (e) {
    print('Error retrieving data: $e');
    return [];
  }
}