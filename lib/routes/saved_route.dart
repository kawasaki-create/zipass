// saved_route.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share/share.dart';

class Saved extends StatefulWidget {
  final String? zipFilePath;

  const Saved({super.key, this.zipFilePath});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<String> zipFiles = [];
  String? _renameZipFile;
  String? _newZipFileName;

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

  Future<void> _shareZipFile(String zipFilePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final zipFileName = zipFilePath.split('/').last;
    final shareFilePath = '${directory.path}/$zipFileName';
    await File(zipFilePath).copy(shareFilePath);

    await Share.shareFiles(
      [shareFilePath],
      text: 'Shared ZIP File',
    );
  }

  void _renameZipFileDialog(String zipFilePath) {
    setState(() {
      _renameZipFile = zipFilePath;
    });
  }

  Future<void> _updateZipFileName() async {
    try {
      if (_newZipFileName == null || _renameZipFile == null) {
        setState(() {
          _renameZipFile = null;
          _newZipFileName = null;
        });
        return;
      }

      final index = zipFiles.indexOf(_renameZipFile!);
      if (index == -1) {
        setState(() {
          _renameZipFile = null;
          _newZipFileName = null;
        });
        return;
      }

      final oldFile = File(_renameZipFile!);
      final oldName = oldFile.path.split('/').last;
      final newFileName = _newZipFileName!.endsWith('.zip') ? _newZipFileName! : '${_newZipFileName!}.zip';
      final newPath = '${oldFile.parent.path}/$newFileName';

      if (oldName != newFileName) {
        await oldFile.rename(newPath);

        setState(() {
          final index = zipFiles.indexOf(_renameZipFile!);
          zipFiles[index] = newPath;
          _renameZipFile = null;
          _newZipFileName = null;
        });
      } else {
        setState(() {
          _renameZipFile = null;
          _newZipFileName = null;
        });
      }
    } catch (e) {
      print('Error updating zip file name: $e');
      // エラーメッセージを表示するなどの適切な処理を行う
    }
  }

  Future<void> _deleteZipFile(String zipFilePath) async {
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('このZIPファイルを削除しますか？（元に戻せません）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (shouldDelete) {
      final file = File(zipFilePath);
      await file.delete();
      setState(() {
        zipFiles.remove(zipFilePath);
      });
    }
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
          final zipFileName = zipFile.split('/').last;

          if (_renameZipFile == zipFile) {
            return ListTile(
              title: TextField(
                controller: TextEditingController(text: zipFileName.replaceAll('.zip', '')),
                onChanged: (value) => _newZipFileName = value,
                onSubmitted: (_) => _updateZipFileName(),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _renameZipFile = null),
                    icon: const Icon(Icons.cancel),
                  ),
                  IconButton(
                    onPressed: _updateZipFileName,
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
            );
          } else {
            return ListTile(
              title: Text(zipFileName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _shareZipFile(zipFile),
                    icon: const Icon(Icons.share),
                  ),
                  IconButton(
                    onPressed: () => _renameZipFileDialog(zipFile),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _deleteZipFile(zipFile),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
