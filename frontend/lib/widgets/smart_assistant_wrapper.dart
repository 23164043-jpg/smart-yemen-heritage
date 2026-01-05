import 'package:flutter/material.dart';

class SmartAssistantWrapper extends StatefulWidget {
  final Widget child;

  const SmartAssistantWrapper({super.key, required this.child});

  @override
  State<SmartAssistantWrapper> createState() => SmartAssistantWrapperState();

  static SmartAssistantWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<SmartAssistantWrapperState>();
  }
}

class SmartAssistantWrapperState extends State<SmartAssistantWrapper> {
  bool _isAssistantVisible = false;

  void toggleAssistant() {
    setState(() {
      _isAssistantVisible = !_isAssistantVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isAssistantVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    "المساعد الذكي",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "مرحبًا! أنا المساعد الذكي الخاص بك 🌟 يمكنك سؤالي عن تاريخ المكان أو أي تفاصيل أخرى تود معرفتها.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اكتب سؤالك هنا...",
                        prefixIcon: const Icon(Icons.mic, color: Colors.brown),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: toggleAssistant,
                      child: const Text("إغلاق",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
