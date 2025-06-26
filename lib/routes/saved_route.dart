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
  final TextEditingController _renameController = TextEditingController();

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
    await Share.shareFiles(
      [zipFilePath],
      text: 'Shared ZIP File',
      subject: 'Shared ZIP File',
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

  String _formatFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '---';
    }
  }

  String _formatDate(File file) {
    try {
      final date = file.lastModifiedSync();
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '---';
    }
  }

  Future<void> _deleteZipFile(String zipFilePath) async {
    final fileName = zipFilePath.split('/').last;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('ファイルを削除'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('以下のファイルを削除しますか？'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.archive,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'この操作は元に戻すことができません。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final file = File(zipFilePath);
        await file.delete();
        setState(() {
          zipFiles.remove(zipFilePath);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('ファイルを削除しました'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('ファイルの削除に失敗しました'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存済みファイル'),
        centerTitle: true,
      ),
      body: zipFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '保存されたファイルがありません',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ホームでZIPファイルを作成してみましょう',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: zipFiles.length,
              itemBuilder: (context, index) {
                final zipFile = zipFiles[index];
                final zipFileName = zipFile.split('/').last;
                final file = File(zipFile);

                if (_renameZipFile == zipFile) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ファイル名を編集',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _renameController..text = zipFileName.replaceAll('.zip', ''),
                            onChanged: (value) => _newZipFileName = value,
                            onSubmitted: (_) => _updateZipFileName(),
                            decoration: const InputDecoration(
                              labelText: '新しいファイル名',
                              suffixText: '.zip',
                              prefixIcon: Icon(Icons.edit),
                            ),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _renameZipFile = null),
                                child: const Text('キャンセル'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _updateZipFileName,
                                child: const Text('保存'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _shareZipFile(zipFile),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.archive,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        zipFileName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(file),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.storage,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatFileSize(file),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _shareZipFile(zipFile),
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text('共有'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _renameZipFileDialog(zipFile),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('名前変更'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _deleteZipFile(zipFile),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('削除'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.error,
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
