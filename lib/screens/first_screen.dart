import 'package:flutter/material.dart';
import '../models/feature_data.dart';
import '../widgets/feature_view.dart';
import '../widgets/micro_animation.dart';
import '../widgets/primary_button.dart';

class FirstScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const FirstScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final delays = [0.2, 0.4, 0.7, 1.0, 1.3, 1.5];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Spacer(flex: 2),
          MicroAnimation(
            delay: delays[0],
            child: const FlutterLogo(size: 150),
          ),
          const SizedBox(height: 48),
          ...List.generate(featureList.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < featureList.length - 1 ? 36 : 0,
              ),
              child: MicroAnimation(
                delay: delays[i + 1],
                child: FeatureView(feature: featureList[i]),
              ),
            );
          }),
          const Spacer(flex: 3),
          MicroAnimation(
            delay: delays[5],
            child: PrimaryButton(title: "Continue", onPressed: onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
