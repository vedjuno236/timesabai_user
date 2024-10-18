import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String title;
  final String imgUrl;
  final String videoUrl;
  final String category;
  final String author;
  final Timestamp time;
  final bool isFavorite;
  final int likeCount;
  final List<String> images;
  Color? textColor;

  NewsItem({
    required this.id,
    required this.likeCount,
    required this.title,
    required this.imgUrl,
    required this.category,
    required this.author,
    required this.videoUrl,
    required this.images,
    this.isFavorite = false,
    Timestamp? time,
  }) : time = time ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imgUrl': imgUrl,
      'category': category,
      'author': author,
      'time': time,
      'isFavorite': isFavorite,
      'likeCount': likeCount,
      'images': images,  // Now saved as a list
    };
  }

  factory NewsItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NewsItem(
      id: doc.id,
      images: List<String>.from(data['images'] ?? []),  // Converts dynamic list to List<String>
      likeCount: data['likeCount'] ?? 0,
      title: data['title'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      category: data['category'] ?? '',
      author: data['author'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      time: data['time'] ?? Timestamp.now(),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  NewsItem copyWith({bool? isFavorite}) {
    return NewsItem(
      likeCount: likeCount,
      id: id,
      title: title,
      images: images,
      category: category,
      imgUrl: imgUrl,
      time: time,
      author: author,
      videoUrl: videoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
