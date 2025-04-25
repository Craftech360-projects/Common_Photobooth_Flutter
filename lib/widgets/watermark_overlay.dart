import 'package:flutter/material.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final bool show;

  const WatermarkOverlay({
    super.key,
    required this.child,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (show)
          IgnorePointer(
            child: Stack(
              children: [
                // First diagonal strip (top-left to bottom-right)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DiagonalStripePainter(
                      color: Colors.orange.withValues(alpha: 0.15),
                      isTopLeftToBottomRight: true,
                      stripeWidth: 150,
                    ),
                  ),
                ),

                // Second diagonal strip (top-right to bottom-left)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DiagonalStripePainter(
                      color: Colors.orange.withValues(alpha: 0.15),
                      isTopLeftToBottomRight: false,
                      stripeWidth: 150,
                    ),
                  ),
                ),

                // Centered logo and text
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo representation (replace with actual logo image)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Image.asset(
                          'assets/images/cft_logo.png',
                          width: 100,
                          height: 100,
                          color: Colors.white.withValues(alpha: 0.8),
                        )),
                      ),
                      const SizedBox(height: 16),
                      // Watermark text
                      Text(
                        'CRAFTECH360 TRIAL VERSION',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.withValues(alpha: 0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Custom painter for diagonal stripes
class DiagonalStripePainter extends CustomPainter {
  final Color color;
  final bool isTopLeftToBottomRight;
  final double stripeWidth;

  DiagonalStripePainter({
    required this.color,
    required this.isTopLeftToBottomRight,
    this.stripeWidth = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTopLeftToBottomRight) {
      // Top-left to bottom-right diagonal
      path.moveTo(0, 0);
      path.lineTo(stripeWidth, 0);
      path.lineTo(size.width, size.height - stripeWidth);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - stripeWidth, size.height);
      path.lineTo(0, stripeWidth);
      path.close();
    } else {
      // Top-right to bottom-left diagonal
      path.moveTo(size.width, 0);
      path.lineTo(size.width, stripeWidth);
      path.lineTo(stripeWidth, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, size.height - stripeWidth);
      path.lineTo(size.width - stripeWidth, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DiagonalStripePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isTopLeftToBottomRight != isTopLeftToBottomRight ||
        oldDelegate.stripeWidth != stripeWidth;
  }
}
