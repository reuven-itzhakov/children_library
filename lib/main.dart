import 'package:children_library/download_page.dart';
import 'package:children_library/get_files.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated configuration
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Choose your child’s age:'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          padding: EdgeInsets.all(30.0),
          children: [
            Image.asset("../assets/wordfile.png"),
            Image.asset("../assets/pdffile.png"),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'word',
                  '0-4',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages0-4.png"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'pdf',
                  '0-4',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages0-4.png"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'word',
                  '4-8',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages4-8.png"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'pdf',
                  '4-8',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages4-8.png"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'word',
                  '8-12',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages8-12.png"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> myFiles = await fetchSpecificFiles(
                  'pdf',
                  '8-12',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExampleCupertinoDownloadButton(files: myFiles),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Image.asset("../assets/ages8-12.png"),
            ),
          ],
        ),
        // Column(
        //   mainAxisAlignment: .center,
        //   children: [ ],
        // ),
      ),
    );
  }
}
