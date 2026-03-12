import 'package:flutter/material.dart';
import '../widgets/step_progress_indicator.dart';
import 'first_screen.dart';
import 'selection_view.dart';
import 'onboarding_page.dart';
import 'home_view.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  int currentIndex = 0;
  static const int totalSteps = 5;

  void _nextScreen() {
    setState(() {
      currentIndex++;
    });
  }

  Widget _buildScreen() {
    return switch (currentIndex) {
      0 => FirstScreen(key: const ValueKey(0), onContinue: _nextScreen),
      1 => SelectionView(key: const ValueKey(1), onContinue: _nextScreen),
      2 => OnboardingPage(
          key: const ValueKey(2),
          icon: Icons.lightbulb,
          title: "Boost your creativity",
          subtitle: "Stay calm and mindful while exploring habits",
          onContinue: _nextScreen,
        ),
      3 => OnboardingPage(
          key: const ValueKey(3),
          icon: Icons.emoji_events,
          title: "Build lasting routines",
          subtitle: "Boost your creativity with daily inspiration",
          onContinue: _nextScreen,
        ),
      4 => OnboardingPage(
          key: const ValueKey(4),
          icon: Icons.emoji_events,
          title: "Boost your creativity",
          subtitle: "Build lasting routines",
          buttonTitle: "Get started",
          onContinue: _nextScreen,
        ),
      _ => const HomeView(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex > totalSteps) {
      return const HomeView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (currentIndex > 0 && currentIndex <= totalSteps)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80)
                    .copyWith(top: 20),
                child: StepProgressIndicator(
                  steps: totalSteps,
                  currentStep: currentIndex - 1,
                ),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final slideIn = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: slideIn,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _buildScreen(),
            ),
          ),
        ],
      ),
    );
  }
}
