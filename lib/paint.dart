import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  List funList = [];
  List<Draw> drawList;
  Painter({required this.drawList}) {
    Paint paintLine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    Paint paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    Paint paintArc = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    for (var element in drawList) {
      if (element.type == DrawType.line) {
        Line line = element.line;
        funList.add((Canvas canvas, Size size) {
          canvas.drawLine(
              Offset(size.width * line.coordinateX1,
                  size.height * line.coordinateY1),
              Offset(size.width * line.coordinateX2,
                  size.height * line.coordinateY2),
              paintLine);
          canvas.drawPoints(
              PointMode.points,
              [
                Offset(size.width * line.pointX1, size.height * line.pointY1),
                Offset(size.width * line.pointX2, size.height * line.pointY2)
              ],
              paintPoint);
        });
      } else if (element.type == DrawType.arc) {
        Arc arc = element.arc;
        funList.add((Canvas canvas, Size size) {
          canvas.drawArc(
              Rect.fromCenter(
                  center: Offset(size.width * arc.coordinateX,
                      size.height * arc.coordinateY),
                  width: arc.radius(size),
                  height: arc.radius(size)),
              arc.angleForArc1,
              arc.angleForArc2,
              false,
              paintArc);
          canvas.drawPoints(
              PointMode.points,
              [
                Offset(
                    size.width * arc.coordinateX, size.height * arc.coordinateY)
              ],
              paintPoint);
        });
      }
    }
  }
  void prepare(Canvas canvas, Size size) {
    Paint paintBlack = Paint()
      ..strokeWidth = 10
      ..color = Colors.black;
    Paint paintRed = Paint()
      ..strokeWidth = 20
      ..color = Colors.red;
    for (int x = 1; x < 20; x++) {
      canvas.drawLine(
          Offset(size.width * x / 20, size.height * 0),
          Offset(size.width * x / 20, size.height * 1),
          x == 10 ? paintRed : paintBlack);
    }
    for (int y = 1; y < 20; y++) {
      canvas.drawLine(
          Offset(size.width * 0, size.height * y / 20),
          Offset(size.width * 1, size.height * y / 20),
          y == 10 ? paintRed : paintBlack);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    prepare(canvas, size);
    for (var element in funList) {
      element(canvas, size);
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    return drawList != oldDelegate.drawList;
  }
}

enum DrawType { line, arc }

class Draw {
  late Line line;
  late Arc arc;
  DrawType type;
  Draw({required this.type});
}

class Line {
  double x1;
  double y1;
  double x2;
  double y2;
  int lineType;
  Line(this.x1, this.y1, this.x2, this.y2, {required this.lineType});
  Map<String, double> typeCoordinate() {
    late Map<String, double> coordinate = {
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2
    };
    switch (lineType) {
      case 0:
        coordinate = {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};
        if (((y1 - y2) / (x1 - x2) * (((x1 < x2) ? -1 : 1) - x2) + y2).abs() <=
            1) {
          if (x1 < x2) {
            coordinate['x1'] = -1;
            coordinate['y1'] = (y1 - y2) / (x1 - x2) * (-1 - x2) + y2;
          } else {
            coordinate['x1'] = 1;
            coordinate['y1'] = (y1 - y2) / (x1 - x2) * (1 - x2) + y2;
          }
        } else {
          if (y1 < y2) {
            coordinate['x1'] = (x1 - x2) / (y1 - y2) * (-1 - y2) + x2;
            coordinate['y1'] = -1;
          } else {
            coordinate['x1'] = (x1 - x2) / (y1 - y2) * (1 - y2) + x2;
            coordinate['y1'] = 1;
          }
        }
        if (((y2 - y1) / (x2 - x1) * (((x1 < x2) ? 1 : -1) - x1) + y1).abs() <=
            1) {
          if (x1 < x2) {
            coordinate['x2'] = 1;
            coordinate['y2'] = (y2 - y1) / (x2 - x1) * (1 - x1) + y1;
          } else {
            coordinate['x2'] = -1;
            coordinate['y2'] = (y2 - y1) / (x2 - x1) * (-1 - x1) + y1;
          }
        } else {
          if (y1 < y2) {
            coordinate['x2'] = (x2 - x1) / (y2 - y1) * (1 - y1) + x1;
            coordinate['y2'] = 1;
          } else {
            coordinate['x2'] = (x2 - x1) / (y2 - y1) * (-1 - y1) + x1;
            coordinate['y2'] = -1;
          }
        }
        break;
      case 1:
        if (((y2 - y1) / (x2 - x1) * (((x1 < x2) ? 1 : -1) - x1) + y1).abs() <=
            1) {
          if (x1 < x2) {
            coordinate['x2'] = 1;
            coordinate['y2'] = (y2 - y1) / (x2 - x1) * (1 - x1) + y1;
          } else {
            coordinate['x2'] = -1;
            coordinate['y2'] = (y2 - y1) / (x2 - x1) * (-1 - x1) + y1;
          }
        } else {
          if (y1 < y2) {
            coordinate['x2'] = (x2 - x1) / (y2 - y1) * (1 - y1) + x1;
            coordinate['y2'] = 1;
          } else {
            coordinate['x2'] = (x2 - x1) / (y2 - y1) * (-1 - y1) + x1;
            coordinate['y2'] = -1;
          }
        }
        break;
      case 2:
        break;
    }
    return coordinate;
  }

  get coordinateX1 => (typeCoordinate()['x1']! + 1) / 2;
  get coordinateY1 => (-typeCoordinate()['y1']! + 1) / 2;
  get coordinateX2 => (typeCoordinate()['x2']! + 1) / 2;
  get coordinateY2 => (-typeCoordinate()['y2']! + 1) / 2;

  get pointX1 => (x1 + 1) / 2;
  get pointY1 => (-y1 + 1) / 2;
  get pointX2 => (x2 + 1) / 2;
  get pointY2 => (-y2 + 1) / 2;
}

class Arc {
  double x1;
  double y1;
  double x2;
  double y2;
  int angle1;
  int angle2;
  Arc(this.x1, this.y1, this.x2, this.y2, this.angle1, this.angle2);

  get coordinateX => (x1 + 1) / 2;
  get coordinateY => (-y1 + 1) / 2;
  double radius(Size size) =>
      sqrt(pow(size.width * (x1 - x2), 2) + pow(size.height * (y1 - y2), 2));
  get angleForArc1 => (2 * pi) * angle1 / 360;
  get angleForArc2 => (2 * pi) * angle2 / 360;
}
