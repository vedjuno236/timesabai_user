import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../model/news_item.dart';
import 'app_bar_icon.dart';

class NewsDetailsAppBar extends StatefulWidget {
     final NewsItem newItem;

  const NewsDetailsAppBar({super.key, required this.newItem});

  @override
  State<NewsDetailsAppBar> createState() => _NewsDetailsAppBarState();
}



class _NewsDetailsAppBarState extends State<NewsDetailsAppBar> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.newItem.isFavorite; // Initialize isFavorite from the passed newsItem
  }

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
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      expandedHeight: size.height * 0.4,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: AppBarIcon(
          icon: Icons.chevron_left,
          iconSize: 30,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      leadingWidth: 40,
      actions: [
        AppBarIcon(
          icon: isFavorite
              ? Icons.bookmark
              : Icons.bookmark_border_outlined,
          onTap: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
        const SizedBox(width: 6.0),
        const AppBarIcon(icon: Icons.menu),
        const SizedBox(width: 6.0),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                widget.newItem.imgUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 50,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          widget.newItem.category,
                          style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                color: Colors.white,
                              ))
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Text(
                      widget.newItem.title,
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${widget.newItem.author}${getTimeAgo(widget.newItem.time.toDate())}',
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
      ),
      pinned: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox(
          height: 30,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(36.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
