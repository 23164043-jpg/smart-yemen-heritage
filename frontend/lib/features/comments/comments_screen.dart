import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final List<String> _comments = [];
  final TextEditingController _controller = TextEditingController();

  void _addComment() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _comments.add(_controller.text.trim());
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE9D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE9D0),
        elevation: 0,
        title: const Text(
          'إضافة تعليق',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('إضافة'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _comments.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد تعليقات بعد.',
                        style: TextStyle(color: Colors.brown, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            _comments[index],
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.brown),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
