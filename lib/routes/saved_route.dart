import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Saved extends StatefulWidget {
  final String? zipFilePath;

  const Saved({super.key, this.zipFilePath});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<String> zipFiles = [];

  @override
  void initState() {
    super.initState();
    _getSavedZipFiles();
    _addNewZipFile();
  }

  Future<void> _getSavedZipFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    setState(() {
      zipFiles = files.where((file) => file.path.endsWith('.zip')).map((file) => file.path).toList();
    });
  }

  void _addNewZipFile() {
    if (widget.zipFilePath != null && !zipFiles.contains(widget.zipFilePath)) {
      setState(() {
        zipFiles.add(widget.zipFilePath!);
      });
    }
  }

  void _openZipFile(String zipFilePath) {
    // TODO: ZIPファイルを開く処理を実装
    print('Opening ZIP file: $zipFilePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存済み'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: zipFiles.length,
        itemBuilder: (context, index) {
          final zipFile = zipFiles[index];
          return ListTile(
            title: Text(zipFile.split('/').last),
            onTap: () => _openZipFile(zipFile),
          );
        },
      ),
    );
  }
}
