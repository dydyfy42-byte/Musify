/*
 *     Copyright (C) 2025 Valeri Gokadze
 *
 *     Billie is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Billie is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

class IndexAppIcon extends StatelessWidget {
  final double size;
  
  const IndexAppIcon({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F), // Red color similar to the image
        borderRadius: BorderRadius.circular(size * 0.15),
      ),
      child: Stack(
        children: [
          // Main play button shape
          Positioned.fill(
            child: CustomPaint(
              painter: IndexIconPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class IndexIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Create the play button triangle shape similar to the image
    final path = Path();
    
    // Main triangle (play button)
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final triangleSize = size.width * 0.3;
    
    path.moveTo(centerX - triangleSize * 0.3, centerY - triangleSize * 0.5);
    path.lineTo(centerX + triangleSize * 0.5, centerY);
    path.lineTo(centerX - triangleSize * 0.3, centerY + triangleSize * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add the curved line at the top (similar to the folder/container shape)
    final curvePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    
    final curvePath = Path();
    curvePath.moveTo(size.width * 0.2, size.height * 0.25);
    curvePath.quadraticBezierTo(
      size.width * 0.5, 
      size.height * 0.15, 
      size.width * 0.8, 
      size.height * 0.25
    );
    
    canvas.drawPath(curvePath, curvePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}