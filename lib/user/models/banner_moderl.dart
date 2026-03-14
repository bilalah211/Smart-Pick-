import 'package:flutter/cupertino.dart';

class BannerItem {
  final String imageUrl;
  final String? title;
  final String? description;
  final String? route;

  BannerItem({
    required this.imageUrl,
    this.title,
    this.description,
    this.route,
  });
}
