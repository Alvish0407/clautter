import 'package:flutter/material.dart';
import '../models/feature_data.dart';

class FeatureView extends StatelessWidget {
  final Feature feature;

  const FeatureView({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: feature.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(feature.icon, size: 20, color: feature.color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                feature.subtitle,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
