import 'package:flutter/material.dart';

//import '../../features/landmarks/details/details_bab_yemen.dart';
//import '../Kingdoms/details/details_maeen.dart';
import '../landmarks/schedule_screen.dart';

const Color _primaryColor = Color(0xFFCD853F);
const Color _backgroundColor = Colors.white;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allItems = [
    {
      "title": "باب اليمن",
      "image": "assets/images/bab_yemen.jpg",
      // "page": const DetailsBabYemen(),
    },
    {
      "title": "دار الحجر",
      "image": "assets/images/dar_alhajar.jpg",
      "page": const LandmarksScreen(),
    },
    {
      "title": "مملكة معين",
      "image": "assets/images/maeen.jpg",
      "page": null,
    },
  ];

  List<Map<String, dynamic>> searchResults = [];

  void search(String text) {
    setState(() {
      searchResults = allItems
          .where((item) =>
              item["title"].toString().contains(text.trim()) ||
              item["title"].toString().startsWith(text.trim()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.40,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                textAlign: TextAlign.right,
                onChanged: search,
                decoration: InputDecoration(
                  hintText: "ابحث عن معلم أو مملكة",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.search, color: _primaryColor),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: searchResults.isEmpty
                    ? Center(
                        child: Text(
                          "لا توجد نتائج",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: _primaryColor.withOpacity(0.3)),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              trailing: Text(
                                item["title"],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item["image"],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                if (item["page"] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => item["page"]),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
