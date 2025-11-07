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
      child: CustomPaint(
        painter: IndexIconPainter(size),
      ),
    );
  }
}

class IndexIconPainter extends CustomPainter {
  final double iconSize;
  
  IndexIconPainter(this.iconSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Main folder background (red)
    final folderPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    // Create the folder shape similar to the image
    final folderPath = Path();
    
    // Main folder body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1, 
        size.height * 0.3, 
        size.width * 0.8, 
        size.height * 0.6
      ),
      Radius.circular(size.width * 0.08),
    );
    folderPath.addRRect(rect);
    
    // Folder tab
    final tabPath = Path();
    tabPath.moveTo(size.width * 0.1, size.height * 0.3);
    tabPath.lineTo(size.width * 0.4, size.height * 0.3);
    tabPath.lineTo(size.width * 0.45, size.height * 0.15);
    tabPath.lineTo(size.width * 0.75, size.height * 0.15);
    tabPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.15,
      size.width * 0.8, size.height * 0.2
    );
    tabPath.lineTo(size.width * 0.8, size.height * 0.3);
    tabPath.close();
    
    canvas.drawPath(folderPath, folderPaint);
    canvas.drawPath(tabPath, folderPaint);
    
    // Play button triangle (black)
    final trianglePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final trianglePath = Path();
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.6;
    final triangleSize = size.width * 0.15;
    
    trianglePath.moveTo(centerX - triangleSize * 0.5, centerY - triangleSize * 0.7);
    trianglePath.lineTo(centerX + triangleSize * 0.8, centerY);
    trianglePath.lineTo(centerX - triangleSize * 0.5, centerY + triangleSize * 0.7);
    trianglePath.close();
    
    canvas.drawPath(trianglePath, trianglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}