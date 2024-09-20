import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'dart:io';

void main() {
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? _dateTime;
  final ImagePicker _picker = ImagePicker();

  // 写真を撮る
  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _getExifData(File(pickedFile.path));
    }
  }

  // ギャラリーから選択する
  Future<void> _chooseFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _getExifData(File(pickedFile.path));
    }
  }

  // Exifデータを取得する（撮影日時のみ）
  Future<void> _getExifData(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);

      if (data.isEmpty) {
        print("Exifデータが見つかりません");
        setState(() {
          _dateTime = 'データなし';
        });
        return;
      }

      // 撮影日時を取得する
      if (data.containsKey('Image DateTime')) {
        setState(() {
          _dateTime = data['Image DateTime']?.printable ?? 'データなし';
        });
      } else if (data.containsKey('EXIF DateTimeOriginal')) {
        setState(() {
          _dateTime = data['EXIF DateTimeOriginal']?.printable ?? 'データなし';
        });
      } else {
        setState(() {
          _dateTime = 'データなし';
        });
      }
    } catch (e) {
      print('Error reading Exif data: $e');
      setState(() {
        _dateTime = 'データなし';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera App"),
      ),
      body: Center(
        child: SingleChildScrollView( // 画面が小さい場合のスクロール対応
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text("画像が選択されていません")
                  : Image.file(_image!),
              SizedBox(height: 10),
              Text('撮影日時: ${_dateTime ?? 'データなし'}'),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _takePhoto,
            tooltip: "写真を撮る",
            child: Icon(Icons.camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _chooseFromGallery,
            tooltip: "ギャラリーから選択",
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
