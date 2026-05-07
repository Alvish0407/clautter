import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback? onBack;

  const EmptyState({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Color(0xFF1A1A1A)),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.settings_outlined,
                          size: 20, color: Color(0xFF1A1A1A)),
                      SizedBox(width: 8),
                      Icon(Icons.grid_view_outlined,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Flashback',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 48, color: Color(0xFFBBBBBB)),
                SizedBox(height: 12),
                Text('No Photo',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  'You can start adding photos by pressing\nthe add button at the right top.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF999999), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
