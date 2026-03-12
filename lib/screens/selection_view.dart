import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/chip_data.dart';
import '../physics/chip_physics.dart';
import '../widgets/micro_animation.dart';
import '../widgets/primary_button.dart';

class SelectionView extends StatefulWidget {
  final VoidCallback onContinue;

  const SelectionView({super.key, required this.onContinue});

  @override
  State<SelectionView> createState() => _SelectionViewState();
}

class _SelectionViewState extends State<SelectionView>
    with SingleTickerProviderStateMixin {
  final ChipPhysicsEngine _engine = ChipPhysicsEngine();
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  bool _spawned = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTime == Duration.zero
        ? 0.0
        : (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    if (_engine.chips.isNotEmpty || _spawned) {
      _engine.update(dt);
      setState(() {});
    }
  }

  void _spawnIfNeeded(BoxConstraints constraints) {
    if (_spawned) return;
    _spawned = true;

    _engine.setContainerBounds(
      0,
      0,
      constraints.maxWidth,
      constraints.maxHeight,
    );
    _engine.spawnChips(chipDataList, () {
      if (mounted) setState(() {});
    });
  }

  void _handleTap(Offset localPosition) {
    final chip = _engine.hitTest(localPosition);
    if (chip != null) {
      setState(() {
        chip.isSelected = !chip.isSelected;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          MicroAnimation(
            delay: 0.5,
            child: const Text(
              "Build Around\nWhat You Love \u{1F4A1}",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          MicroAnimation(
            delay: 0.8,
            child: Text(
              "Select the activities that interest you",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _spawnIfNeeded(constraints);
                });

                return GestureDetector(
                  onTapDown: (details) => _handleTap(details.localPosition),
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final chip in _engine.chips)
                          Positioned(
                            left: chip.position.dx - chip.size.width / 2,
                            top: chip.position.dy - chip.size.height / 2,
                            child: Opacity(
                              opacity: chip.alpha,
                              child: IgnorePointer(
                                child: _ChipWidget(chip: chip),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          MicroAnimation(
            delay: 1.2,
            child: PrimaryButton(title: "Continue", onPressed: widget.onContinue),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final PhysicsChip chip;

  const _ChipWidget({required this.chip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: chip.data.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(chip.size.height / 2),
        border: Border.all(
          color: chip.isSelected ? Colors.black : Colors.transparent,
          width: chip.isSelected ? 2 : 0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.data.icon, size: 20, color: chip.data.color),
          const SizedBox(width: 12),
          Text(
            chip.data.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
