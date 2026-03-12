import 'package:flutter/material.dart';

class Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

final List<Feature> featureList = [
  Feature(
    icon: Icons.search,
    title: "Find new activities",
    subtitle: "Discover fresh ideas that spark your interest",
    color: Colors.blue,
  ),
  Feature(
    icon: Icons.self_improvement,
    title: "Stay calm and mindful",
    subtitle: "Find new activities that spark your interest",
    color: Colors.green,
  ),
  Feature(
    icon: Icons.lightbulb,
    title: "Boost your creativity",
    subtitle: "Stay calm and mindful while exploring habits",
    color: Colors.orange,
  ),
  Feature(
    icon: Icons.emoji_events,
    title: "Build lasting routines",
    subtitle: "Boost your creativity with daily inspiration",
    color: Colors.purple,
  ),
];
