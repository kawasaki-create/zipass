import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:zipass/routes/saved_route.dart';
import 'package:flutter/services.dart';
import 'package:zipass/utils/review_manager.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  bool _isCreatingZip = false;

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
    if (selectedFiles.isEmpty || _isCreatingZip) return;

    setState(() {
      _isCreatingZip = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final zipFileName = 'archive_$timestamp.zip';
      final outputPath = '${directory.path}/$zipFileName';

      final filePaths = selectedFiles.map((file) => file.path).toList();
      final success = await ZipService.createPasswordProtectedZip(filePaths, password.trim(), outputPath);

      if (success) {
        print('ZIPファイルの作成に成功しました');
        await ReviewManager.onZipCreated();
        
        // 成功のスナックバーを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('ZIPファイルを作成しました'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        
        // 選択ファイルとパスワードをクリア
        setState(() {
          selectedFiles = [];
          selectedFileNames = [];
          password = '';
          _passwordController.clear();
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Saved(zipFilePath: outputPath)),
          );
        }
      } else {
        print('ZIPファイルの作成に失敗しました');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('ZIPファイルの作成に失敗しました'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingZip = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zipass'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'ZIPファイルを作成',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ファイルを選択してパスワード付きZIPを作成できます',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // ファイル選択カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_open,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ファイル選択',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (selectedFileNames.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ファイルが選択されていません',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${selectedFileNames.length}個のファイルを選択中',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...selectedFileNames.map((name) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _selectFiles,
                        icon: const Icon(Icons.add),
                        label: Text(selectedFileNames.isEmpty ? 'ファイルを選択' : 'ファイルを変更'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // パスワード設定カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'パスワード設定',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'パスワードを空にすると通常のZIPファイルが作成されます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      onChanged: (value) => password = value,
                      decoration: const InputDecoration(
                        labelText: 'パスワード（任意）',
                        hintText: 'パスワードを入力してください',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 作成ボタン
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: selectedFiles.isNotEmpty && !_isCreatingZip ? _createZipFile : null,
                child: _isCreatingZip
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('作成中...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.archive),
                          SizedBox(width: 8),
                          Text('ZIPファイルを作成'),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
