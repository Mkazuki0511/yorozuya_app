import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PageRequestPost extends StatefulWidget {
  const PageRequestPost({super.key});

  @override
  State<PageRequestPost> createState() => _PageRequestPostState();
}

class _PageRequestPostState extends State<PageRequestPost> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 選択データ (null の場合は未選択)
  String? _selectedCategory;
  String? _selectedTime;
  String? _selectedBudget;
  String? _selectedLocation;
  XFile? _imageFile;

  // コントローラー
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 画像を選択する
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  // Firebaseに投稿する
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // バリデーションチェック
    if (_selectedCategory == null ||
        _selectedTime == null ||
        _selectedBudget == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('すべての項目を選択してください')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーがログインしていません');

      String? imageUrl;

      // 画像があればStorageにアップロード
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('request_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          await storageRef.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          await storageRef.putFile(
            File(_imageFile!.path),
            SettableMetadata(contentType: 'image/jpeg'),
          );
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      // Firestoreにデータを保存
      await FirebaseFirestore.instance.collection('requests').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'time': _selectedTime,
        'budget': _selectedBudget,
        'location': _selectedLocation,
        'imageUrl': imageUrl,
        'requesterId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('依頼を投稿しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('投稿に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '依頼する',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. 画像アップロード欄 (4:3)
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageFile == null
                            ? const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              )
                            : kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '依頼のイメージ画像',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // 2. タイトル
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'タイトル',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      TextFormField(
                        controller: _titleController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '入力してください' : null,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00C2CB)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. 内容説明
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '内容説明',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? '入力してください' : null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. カテゴリー選択
                  _buildDropdownField(
                    value: _selectedCategory,
                    hint: 'カテゴリーを選択',
                    items: ['家事代行', '買い物', '搬送・組立', 'スキル教養', '相談', 'その他'],
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                  const SizedBox(height: 16),

                  // 5. 時間選択
                  _buildDropdownField(
                    value: _selectedTime,
                    hint: '時間を選択',
                    items: ['30分以内', '1時間', '2時間', '3時間', '半日', '1日'],
                    onChanged: (val) => setState(() => _selectedTime = val),
                  ),
                  const SizedBox(height: 16),

                  // 6. 予算選択
                  _buildDropdownField(
                    value: _selectedBudget,
                    hint: '予算を選択',
                    items: [
                      '¥500〜1,000',
                      '¥1,000〜2,000',
                      '¥2,000〜3,000',
                      '¥3,000〜5,000',
                      '¥5,000〜10,000',
                    ],
                    onChanged: (val) => setState(() => _selectedBudget = val),
                  ),
                  const SizedBox(height: 16),

                  // 7. 場所選択
                  _buildDropdownField(
                    value: _selectedLocation,
                    hint: '場所を選択',
                    items: ['オンライン', '名古屋市', '東京都渋谷区', '大阪府梅田', 'その他'],
                    onChanged: (val) => setState(() => _selectedLocation = val),
                  ),
                  const SizedBox(height: 32),

                  // 8. 依頼ボタン
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 56,
                      width: 180,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C2CB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('依頼する'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          onChanged: _isLoading ? null : onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            );
          }).toList(),
          borderRadius: BorderRadius.circular(20),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
