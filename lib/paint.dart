import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  List funList = [];
  List<Draw> drawList;
  int editIdx;
  bool showGrid;
  Painter(
      {required this.showGrid, required this.drawList, required this.editIdx}) {
    //paint
    Paint paintLine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    Paint paintArc = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    Paint paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    //paint editting
    Paint paintEditLine = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    Paint paintEditArc = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    Paint paintEditPoint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;
    //paint compass
    Paint paintCompass = Paint()
      ..color = const Color.fromARGB(158, 12, 57, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < drawList.length; i++) {
      Draw element = drawList[i];
      if (element.type == DrawType.line) {
        Line line = element.line;
        funList.add((Canvas canvas, Size size) {
          canvas.drawLine(Offset(line.x1, line.y1), Offset(line.x2, line.y2),
              i == editIdx ? paintEditLine : paintLine);
        });
        if (i == editIdx) {
          funList.add((Canvas canvas, Size size) {
            canvas.drawPoints(
                PointMode.points,
                [Offset(line.x1, line.y1), Offset(line.x2, line.y2)],
                paintEditPoint);
          });
        }
      } else if (element.type == DrawType.arc) {
        Arc arc = element.arc;
        if (i == editIdx) {
          funList.add((Canvas canvas, Size size) {
            canvas.drawCircle(Offset(arc.x, arc.y), arc.radius, paintCompass);
          });
        }
        funList.add((Canvas canvas, Size size) {
          canvas.drawArc(
              Rect.fromCircle(center: Offset(arc.x, arc.y), radius: arc.radius),
              arc.angleForArc1,
              arc.angleForArc2,
              false,
              i == editIdx ? paintEditArc : paintArc);
        });
        funList.add((Canvas canvas, Size size) {
          canvas.drawPoints(PointMode.points, [Offset(arc.x, arc.y)],
              i == editIdx ? paintEditPoint : paintPoint);
        });
      }
    }
  }
  void prepare(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 10
      ..color = Colors.blue;
    for (int x = 1; x < 20; x++) {
      canvas.drawLine(Offset(size.width * x / 20, size.height * 0),
          Offset(size.width * x / 20, size.height * 1), paint);
    }
    for (int y = 1; y < 20; y++) {
      canvas.drawLine(Offset(size.width * 0, size.height * y / 20),
          Offset(size.width * 1, size.height * y / 20), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      prepare(canvas, size);
    }
    for (var element in funList) {
      element(canvas, size);
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return true; // drawList != oldDelegate.drawList;
  }
}

enum DrawType { line, arc }

class Draw {
  late Line line;
  late Arc arc;
  DrawType type;
  Draw({required this.type});
  Draw copy() {
    if (type == DrawType.line) {
      return Draw(type: type)..line = line;
    } else {
      return Draw(type: type)..arc = arc;
    }
  }
}

class Line {
  double x1;
  double y1;
  double x2;
  double y2;
  Line(this.x1, this.y1, this.x2, this.y2);
}

class Arc {
  double x;
  double y;
  double radius;
  int angle1;
  int angle2;
  Arc(this.x, this.y, this.radius, this.angle1, this.angle2);

  get angleForArc1 => (2 * pi) * angle1 / 360;
  get angleForArc2 => (2 * pi) * angle2 / 360;
}
