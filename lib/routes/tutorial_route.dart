import 'package:flutter/material.dart';
import 'package:zipass/main.dart';

class Tutorial extends StatelessWidget {
  const Tutorial({super.key});

  static final List<Map<String, dynamic>> tutorialData = [
    {
      'title': 'ファイルの選択',
      'description': 'ホーム画面で「ファイルを選択」ボタンをタップして、ZIP化するファイルを選択します。',
    },
    {
      'title': 'ZIPファイルの作成',
      'description': '選択したファイルをZIP化するには、「ZIPファイルを作成」ボタンをタップします。',
    },
    {
      'title': 'パスワードの設定',
      'description': '必要に応じて、パスワードを設定することもできます。',
    },
    {
      'title': '保存済みタブ',
      'description': '作成したZIPファイルは「保存済み」タブで確認できます。',
    },
    {
      'title': '各アイコンの意味',
      'description': Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: const [
              Icon(Icons.share),
              Text('共有'),
            ],
          ),
          Column(
            children: const [
              Icon(Icons.edit),
              Text('編集'),
            ],
          ),
          Column(
            children: const [
              Icon(Icons.delete),
              Text('削除'),
            ],
          ),
        ],
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チュートリアル'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: tutorialData.length + 1,
        itemBuilder: (context, index) {
          if (index == tutorialData.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('さっそく始めましょう！'),
              ),
            );
          } else {
            final data = tutorialData[index];
            return Card(
              child: ListTile(
                title: Text(data['title']),
                subtitle: data['description'] is Widget ? data['description'] : Text(data['description']),
              ),
            );
          }
        },
      ),
    );
  }
}
