import 'package:flutter/material.dart';

class ChipData {
  final String title;
  final IconData icon;
  final Color color;

  const ChipData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

final List<ChipData> chipDataList = [
  ChipData(title: "Write", icon: Icons.edit_outlined, color: Colors.teal),
  ChipData(title: "Cook", icon: Icons.restaurant, color: Colors.green),
  ChipData(title: "Work", icon: Icons.laptop_mac, color: Colors.indigo),
  ChipData(title: "Exercise", icon: Icons.directions_run, color: Colors.blue),
  ChipData(title: "Podcast", icon: Icons.mic, color: const Color(0xFF98FF98)),
  ChipData(title: "Explore", icon: Icons.explore, color: Colors.cyan),
  ChipData(title: "Learn", icon: Icons.menu_book, color: Colors.orange),
  ChipData(title: "Code", icon: Icons.code, color: Colors.pink),
  ChipData(title: "Design", icon: Icons.palette, color: Colors.yellow),
  ChipData(title: "Research", icon: Icons.search, color: Colors.purple),
  ChipData(
    title: "Meditate",
    icon: Icons.self_improvement,
    color: Colors.indigo,
  ),
  ChipData(title: "Travel", icon: Icons.flight, color: Colors.brown),
  ChipData(
    title: "Finance",
    icon: Icons.account_balance_wallet,
    color: const Color(0xFFFF00FF),
  ),
  ChipData(title: "Garden", icon: Icons.eco, color: const Color(0xFF32CD32)),
  ChipData(title: "Music", icon: Icons.music_note, color: Colors.deepOrange),
  ChipData(title: "Photo", icon: Icons.camera_alt, color: Colors.grey),
  ChipData(
    title: "Shop",
    icon: Icons.shopping_cart,
    color: const Color(0xFFA67B5B),
  ),
];
