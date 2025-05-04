import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:palette_generator/palette_generator.dart';
import '../model/news_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({Key? key}) : super(key: key);

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  late Future<List<NewsItem>> _newsItems;

  @override
  void initState() {
    super.initState();
    _newsItems = fetchNews();
  }

  Future<List<NewsItem>> fetchNews() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('news').get();
    final newsItems = snapshot.docs.map((doc) => NewsItem.fromFirestore(doc)).toList();

    for (var item in newsItems) {
      final dominantColor = await getImageDominantColor(item.imgUrl);
      item.textColor = isLightColor(dominantColor) ? Colors.black : Colors.white;
    }
    return newsItems;
  }

  bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5; // Bright colors are considered "light".
  }

  Future<Color> getImageDominantColor(String imageUrl) async {
    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
    );
    return palette.dominantColor?.color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsItem>>(
      future: _newsItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return   Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              size: 50,
              color:const  Color(0xFFEA3799),
            ),);
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No news available'));
        }

        List<NewsItem> news = snapshot.data!;
        final List<Widget> imageSliders = news.map((item) {
          return Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              child: Stack(
                children: <Widget>[
                  Image.network(
                    item.imgUrl,
                    fit: BoxFit.cover,
                    width: 1000.0,
                  ),
                  Positioned(
                    top: 10,
                    left: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.category,
                          style: GoogleFonts.notoSansLao(
                            textStyle: TextStyle(
                              color: item.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            '${item.author}',
                            style: GoogleFonts.notoSansLao(
                              textStyle: TextStyle(
                                color: item.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            DateFormat('dd: MM: yyyy HH:mm').format(item.time.toDate()),
                            style: GoogleFonts.notoSansLao(
                              textStyle: TextStyle(
                                color: item.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

        return Column(
          children: [
            CarouselSlider(
              items: imageSliders,
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: news.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _current == entry.key ? 25.0 : 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: _current == entry.key
                          ? BorderRadius.circular(8.0)
                          : null,
                      shape: _current == entry.key
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      color: _current == entry.key
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
