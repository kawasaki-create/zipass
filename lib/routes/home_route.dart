import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:zipass/routes/saved_route.dart';
import 'package:flutter/services.dart';

class ZipService {
  static const MethodChannel _channel = MethodChannel('com.example.app/zip');

  static Future<bool> createPasswordProtectedZip(List<String> filePaths, String password, String outputPath) async {
    final success = await _channel.invokeMethod('createPasswordProtectedZip', {
      'filePaths': filePaths,
      'password': password,
      'outputPath': outputPath,
    });
    return success;
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<File> selectedFiles = [];
  String password = '';
  List<String> selectedFileNames = [];

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      selectedFiles = result.paths.map((path) => File(path!)).toList();
      setState(() {
        selectedFileNames = result.names.map((name) => name!).toList();
      });
    }
  }

  Future<void> _createZipFile() async {
    if (selectedFiles.isEmpty) return;

    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final zipFileName = 'archive_$timestamp.zip';
    final outputPath = '${directory.path}/$zipFileName';

    final filePaths = selectedFiles.map((file) => file.path).toList();
    final success = await ZipService.createPasswordProtectedZip(filePaths, password, outputPath);

    if (success) {
      // ZIPファイルの作成に成功した場合の処理
      print('ZIPファイルの作成に成功しました');
    } else {
      // ZIPファイルの作成に失敗した場合の処理
      print('ZIPファイルの作成に失敗しました');
    }

    // 選択ファイルとパスワードをクリア
    setState(() {
      selectedFiles = [];
      selectedFileNames = [];
      password = '';
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Saved(zipFilePath: outputPath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: _selectFiles,
            child: const Text('ファイルを選択'),
          ),
          const SizedBox(height: 10),
          Text(selectedFileNames.join(', ')),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => password = value,
            decoration: const InputDecoration(
              labelText: 'パスワード',
            ),
            obscureText: true, // パスワード入力を伏字にする
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createZipFile,
            child: const Text('ZIPファイルを作成'),
          ),
        ],
      ),
    );
  }
}
