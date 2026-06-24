import 'package:flutter/material.dart';

/// Holds the colour/content for each book page.
class PageData {
  final Color color;
  final String label;
  final int pageNumber;

  const PageData({
    required this.color,
    required this.label,
    required this.pageNumber,
  });
}

/// The set of book pages used by the animation.
const List<PageData> kBookPages = [
  PageData(color: Color(0xFFFFF8E1), label: 'Once upon\na time…', pageNumber: 1),
  PageData(color: Color(0xFFE8F5E9), label: 'The forest\nawaited.', pageNumber: 2),
  PageData(color: Color(0xFFE3F2FD), label: 'A hero\nappeared.', pageNumber: 3),
  PageData(color: Color(0xFFFCE4EC), label: 'Danger\nlurkéd.', pageNumber: 4),
  PageData(color: Color(0xFFF3E5F5), label: 'Courage\nprevailed.', pageNumber: 5),
  PageData(color: Color(0xFFE0F7FA), label: 'Peace was\nrestored.', pageNumber: 6),
  PageData(color: Color(0xFFFFF9C4), label: 'The End.', pageNumber: 7),
];
