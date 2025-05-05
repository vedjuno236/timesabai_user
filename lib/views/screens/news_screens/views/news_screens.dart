import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timesabai/views/screens/news_screens/model/news_item.dart';
import 'package:timesabai/views/screens/news_screens/widgets/app_bar_icon.dart';
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
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

                      return Column(
                        children: [
                          // Carousel for featured news (optional)
                          if (newsItems.isNotEmpty)
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: true,
                                autoPlay: true,
                              ),
                              items: newsItems
                                  .where((item) => item.images.isNotEmpty)
                                  .map<Widget>((newsItem) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          CupertinoPageRoute(
                                            builder: (_) => NewDetailsScreens(
                                              newsItem: newsItem,
                                              newsItemId: newsItem.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: newsItem.images[0],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
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
                          const SizedBox(height: 20),
                          ...newsItems.map((newsItem) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    CupertinoPageRoute(
                                      builder: (_) => NewDetailsScreens(
                                        newsItem: newsItem,
                                        newsItemId: newsItem.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          child: newsItem.images.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: newsItem.images[0],
                                                  height: 150,
                                                  width: 150,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                )
                                              : Container(
                                                  height: 120,
                                                  width: 150,
                                                  color: Colors.grey,
                                                  child: const Icon(Icons
                                                      .image_not_supported),
                                                ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                newsItem.category,
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    color: Colors.black,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                newsItem.title,
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                newsItem.author,
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                getTimeAgo(
                                                    newsItem.time.toDate()),
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getTimeAgo(DateTime newsTime) {
    final now = DateTime.now();
    final difference = now.difference(newsTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ວັນ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ຊົ່ວໂມງ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ນາທີ';
    } else {
      return 'Just now';
    }
  }
}
