import 'package:flutter/material.dart';
import 'board-widget.dart';

abstract class PainterBase extends CustomPainter {
  //
  final double width;

  final thePaint = Paint();
  final gridWidth, squareSide;

  PainterBase({@required this.width})
      : gridWidth = (width - BoardWidget.Padding * 2) * 8 / 9,
        squareSide = (width - BoardWidget.Padding * 2) / 9;
}
