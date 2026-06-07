import 'package:flutter/material.dart';

/// Slider that controls the chaos ↔ sphere morph blend.
///
/// [morphAmount] ranges from 0 (scattered chaos) to 100 (perfect sphere).
class MorphControls extends StatelessWidget {
  final double morphAmount;
  final ValueChanged<double> onChanged;

  const MorphControls({
    super.key,
    required this.morphAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Chaos',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text('Sphere',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 2),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white12,
              trackHeight: 2,
            ),
            child: Slider(
              value: morphAmount,
              min: 0,
              max: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
