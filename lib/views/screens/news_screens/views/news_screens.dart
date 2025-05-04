import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timesabai/views/screens/news_screens/model/news_item.dart';
import 'package:timesabai/views/screens/news_screens/widgets/app_bar_icon.dart';
import 'package:timesabai/views/screens/news_screens/widgets/carousel_slider.dart';
import 'package:timesabai/views/screens/news_screens/widgets/recommendation_item.dart';

import 'newsDetails_screens.dart';

class NewsScreens extends StatefulWidget {
  const NewsScreens({super.key});

  @override
  State<NewsScreens> createState() => _NewsScreensState();
}

class _NewsScreensState extends State<NewsScreens> {
  Stream<List<NewsItem>> fetchNews() {
    return FirebaseFirestore.instance
        .collection('news')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NewsItem.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Set the system overlay style
        child: Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBarIcon(
                      icon: Icons.arrow_back_ios,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Row(
                      children: [
                        AppBarIcon(icon: Icons.search),
                        SizedBox(width: 10.0),
                        AppBarIcon(icon: Icons.notifications),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ຂາວສານຕ່າງໆ ແລະ ແຈ້ງການ',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'ເບິ່ງທັງໝົດ',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const CustomCarouselSlider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ລາຍລະອຽດຂາວສານຕ່າງໆ ແລະ ແຈ້ງການ',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'ເບິ່ງທັງໝົດ',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<NewsItem>>(
                  stream: fetchNews(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading news'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No news available'));
                    }

                    final newsItems = snapshot.data!;
                    print(newsItems.length);
                    return Column(
                      children: newsItems.map((newsItem) {
                        print("NewsItem ID: ${newsItem.id}");

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (_) => NewDetailsScreens(
                                    newsItem: newsItem,
                                    newsItemId: newsItem.id,
                                  ),
                                ),
                              );
                            },
                            child: RecommendationItem(newsItem: newsItem),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )

              ],
            ),
          ),
        ),
      ),
        ));
  }
}
