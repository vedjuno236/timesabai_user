import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/news_item.dart';


final likeCountProvider = StreamProvider.family<int, String>((ref, newsItemId) {
  final docRef = FirebaseFirestore.instance.collection('news').doc(newsItemId);
  return docRef.snapshots().map((snapshot) => snapshot.exists ? snapshot['likeCount'] ?? 0 : 0);
});

final favoriteStateProvider = StateNotifierProvider.family<FavoriteNotifier, bool, String>((ref, newsItemId) {
  return FavoriteNotifier(newsItemId);
});

class FavoriteNotifier extends StateNotifier<bool> {
  final String newsItemId;

  FavoriteNotifier(this.newsItemId) : super(false) {
    _initialize();
  }

  Future<void> _initialize() async {
    final docSnapshot = await FirebaseFirestore.instance.collection('news').doc(newsItemId).get();
    state = docSnapshot.exists ? (docSnapshot['isFavorite'] ?? false) : false;
  }

  Future<void> toggleFavorite() async {
    final docRef = FirebaseFirestore.instance.collection('news').doc(newsItemId);
    final docSnapshot = await docRef.get();

    final newFavoriteStatus = !state;
    state = newFavoriteStatus;

    if (docSnapshot.exists) {
      final currentLikeCount = docSnapshot['likeCount'] ?? 0;
      final newLikeCount = newFavoriteStatus ? currentLikeCount + 1 : currentLikeCount - 1;

      await docRef.update({
        'isFavorite': newFavoriteStatus,
        'likeCount': newLikeCount,
      });
    } else {
      await docRef.set({
        'isFavorite': newFavoriteStatus,
        'likeCount': newFavoriteStatus ? 1 : 0,
      });
    }
  }
}

class NewsDetailsBody extends ConsumerWidget {
  final NewsItem newsItem;
  final String newsItemId;

  const NewsDetailsBody({
    super.key,
    required this.newsItem,
    required this.newsItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteStateProvider(newsItemId));
    final likeCountAsyncValue = ref.watch(likeCountProvider(newsItemId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(newsItem.imgUrl),
              ),
              Text(
                newsItem.author,
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(color: Colors.black),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isFavorite ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () => ref.read(favoriteStateProvider(newsItemId).notifier).toggleFavorite(),
                  ),
                  const SizedBox(width: 2),
                  likeCountAsyncValue.when(
                    data: (likeCount) => Text(
                      "ຖືກໃຈ $likeCount",
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stackTrace) => Text("Error: $error"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            newsItem.title,
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 16.0),
          StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: newsItem.images.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
