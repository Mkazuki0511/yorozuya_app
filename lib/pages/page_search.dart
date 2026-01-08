import 'package:flutter/material.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  int _selectedDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色は以前のコードを継承
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 検索バーとフィルタリング
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'キーワードで検索',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // フィルタリングボタン
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // 2. 6日分の日付リスト
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _selectedDateIndex == index ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${index + 7}日',
                            style: TextStyle(
                              color: _selectedDateIndex == index ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ['水', '木', '金', '土', '日', '月'][index],
                            style: TextStyle(
                              color: _selectedDateIndex == index ? Colors.white70 : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 3. 2列のカードデザインリスト
            // Expandedで包むことで「高さ無限エラー」を防ぎます
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2列表示
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75, // カードの縦横比を調整
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 画像部分
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            width: double.infinity,
                            child: const Icon(Icons.image, color: Colors.white, size: 40),
                          ),
                        ),
                        // テキスト部分
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'タイトル $index',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text('¥3,000',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}