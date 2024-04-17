import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:zipass/routes/saved_route.dart';

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
    final zipFile = File('${directory.path}/archive.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);

    for (final file in selectedFiles) {
      final fileName = file.path.split('/').last;
      final fileData = file.readAsBytesSync();

      final zipEntry = ArchiveFile(fileName, fileData.length, fileData);
      zipEntry.compress = true;

      if (password.isNotEmpty) {
        // パスワードまわりコメントアウト
        // zipEntry.password = password;
      }

      encoder.addFile(zipEntry as File);
    }

    encoder.close();

    // 「保存済み」画面に遷移し、作成したZIPファイルのパスを引数として渡す
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Saved(zipFilePath: zipFile.path)),
    );

    setState(() {
      selectedFiles = [];
      password = '';
    });
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
