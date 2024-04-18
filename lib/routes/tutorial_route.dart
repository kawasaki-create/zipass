import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:zipass/main.dart';

class Tutorial extends StatelessWidget {
  const Tutorial({super.key});

  static final pages = [
    PageViewModel(
      pageColor: const Color(0xFF4CAF50),
      body: const Text('ホーム画面で「ファイルを選択」ボタンをタップして、ZIP化するファイルを選択します。'),
      title: const Text('ファイルの選択'),
      mainImage: Image.asset(
        'assets/images/select_files.png',
        fit: BoxFit.contain,
      ),
      titleTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
      bodyTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
    ),
    PageViewModel(
      pageColor: const Color(0xFF2196F3),
      body: const Text('選択したファイルをZIP化するには、「ZIPファイルを作成」ボタンをタップします。必要に応じて、パスワードを設定することもできます。'),
      title: const Text('ZIPファイルの作成'),
      mainImage: Image.asset(
        'assets/images/create_zip.png',
        fit: BoxFit.contain,
      ),
      titleTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
      bodyTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
    ),
    PageViewModel(
      pageColor: const Color(0xFFF44336),
      body: const Text('作成したZIPファイルは「保存済み」タブで確認できます。各アイコンの意味は以下の通りです。\n\n共有：ZIPファイルを他のアプリと共有します。\n編集：ZIPファイルの名前を変更します。\n削除：ZIPファイルを削除します。'),
      title: const Text('保存済みタブ'),
      mainImage: Image.asset(
        'assets/images/saved_tab.png',
        fit: BoxFit.contain,
      ),
      titleTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
      bodyTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.greenAccent,
      mainImage: const Center(
        child: Text(
          'さっそく始めましょう！',
          style: TextStyle(fontFamily: 'Noto Sans JP', fontSize: 32, color: Colors.white),
        ),
      ),
      titleTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
      bodyTextStyle: const TextStyle(fontFamily: 'Noto Sans JP', color: Colors.white),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroViewsFlutter(
        pages,
        showNextButton: true,
        showBackButton: true,
        onTapDoneButton: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        },
        pageButtonTextStyles: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
