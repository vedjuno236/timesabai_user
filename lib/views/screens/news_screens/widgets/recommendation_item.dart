import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../model/news_item.dart';
class RecommendationItem extends StatelessWidget {
  final NewsItem newsItem;
  const RecommendationItem({super.key, required this.newsItem});
  String getTimeAgo(DateTime newsTime) {
    final now = DateTime.now();
    final difference = now.difference(newsTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ວັນທີ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ຊົ່ວໂມງ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ນາທີ';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.network(
            newsItem.imgUrl,
            height: 120,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newsItem.category,
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),),
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
                getTimeAgo(newsItem.time.toDate()),

                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
              )

    ],
          ),
        ),
      ],
    );
  }
}