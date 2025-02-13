import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class SelectionButton extends StatelessWidget {
  const SelectionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final buttonWidth = constraints.maxWidth * 0.85; // 90% of parent width
        final buttonHeight = buttonWidth * 0.14; // Maintain proportional height
        final textSize = buttonHeight * 0.35; // Proportional text size

        return Center(
          child: InkWell(
            onTap: () {
              onTap();
            },
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: ShapeDecoration(
                // color: Colors.white.withValues(alpha: 0.25),
                color: isSelected ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  // side: BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      // color: Colors.white,
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: textSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );




  }
}
