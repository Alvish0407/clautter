import 'package:flutter/material.dart';
import '../widgets/micro_animation.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonTitle;
  final VoidCallback onContinue;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonTitle = "Continue",
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Spacer(flex: 3),
          MicroAnimation(
            delay: 0.3,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 40),
          MicroAnimation(
            delay: 0.6,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          MicroAnimation(
            delay: 0.9,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const Spacer(flex: 4),
          MicroAnimation(
            delay: 1.1,
            child: PrimaryButton(title: buttonTitle, onPressed: onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
