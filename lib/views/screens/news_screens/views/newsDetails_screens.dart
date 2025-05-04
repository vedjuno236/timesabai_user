import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/news_item.dart';
import '../widgets/news_details_body.dart';
import '../widgets/news_title_widget.dart';
class NewDetailsScreens extends StatelessWidget {
  final NewsItem newsItem;
  final String newsItemId; // Declare the newsItemId field

  const NewDetailsScreens({
    super.key,
    required this.newsItem,
    required this.newsItemId, // Accept the newsItemId
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print("News Item ID: $newsItemId");
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                NewsDetailsAppBar(
                  newItem: newsItem,
                ),
                SliverToBoxAdapter(
                  child: NewsDetailsBody(
                    newsItem: newsItem,
                    newsItemId: newsItemId, // Pass the newsItemId here
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: size.width,
              height: size.height * 0.25,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
