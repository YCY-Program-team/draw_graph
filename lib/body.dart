import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:draw_graph/paint.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class GraphCanva extends StatefulWidget {
  final GlobalKey<GraphCanvaState> _key;

  const GraphCanva(this._key) : super(key: _key);

  void clear() => _key.currentState?._clearList();
  List<Draw> drawList() => _key.currentState!.drawList;
  String exportData() => _key.currentState!._exportGraph();
  void importData(List<Draw> importDrawList) =>
      _key.currentState!._importGraph(importDrawList);

  @override
  State<GraphCanva> createState() => GraphCanvaState();
}

enum DoType { canva, list }

enum LinePoint { p1, p2, all }

enum ArcPoint { pC, pR, angle }

enum ArcDir { clockwise, counterclockwise, undecided }

class GraphCanvaState extends State<GraphCanva> {
  List<Draw> drawList = [];
  int editIdx = -1;
  LinePoint editLinePoint = LinePoint.p1;
  ArcPoint editArcPoint = ArcPoint.pC;
  int startingAngle = 0;
  ArcDir editArcDir = ArcDir.undecided;

  bool showGrid = true;

  @override
  Widget build(BuildContext context) {
    final doCanva = Container(
      margin: const EdgeInsets.all(10),
      child: FittedBox(
        child: GestureDetector(
          child: Container(
            width: 2000,
            height: 2000,
            color: Colors.grey[400],
            child: CustomPaint(
                painter: Painter(
                    showGrid: showGrid, drawList: drawList, editIdx: editIdx),
                child: Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      ' by YCY Program',
                      style: TextStyle(fontSize: 100, color: Colors.white),
                    ))),
          ),
          onPanDown: (DragDownDetails dragDownDetails) {
            if (editIdx >= 0) {
              double x = dragDownDetails.localPosition.dx;
              double y = dragDownDetails.localPosition.dy;
              if (drawList[editIdx].type == DrawType.line) {
                Line line = drawList[editIdx].line;

                if ((line.x1 - x).abs() < 100 && (line.y1 - y).abs() < 100) {
                  editLinePoint = LinePoint.p1;
                } else if ((line.x2 - x).abs() < 100 &&
                    (line.y2 - y).abs() < 100) {
                  editLinePoint = LinePoint.p2;
                } else {
                  editLinePoint = LinePoint.all;
                }
              } else if (drawList[editIdx].type == DrawType.arc) {
                Arc arc = drawList[editIdx].arc;
                final halfDis = arc.radius / 2;
                if ((arc.x - x).abs() < halfDis &&
                    (arc.y - y).abs() < halfDis) {
                  editArcPoint = ArcPoint.pC;
                } else if ((sqrt(pow(x - arc.x, 2) + pow(y - arc.y, 2)) -
                            arc.radius)
                        .abs() <
                    100) {
                  editArcPoint = ArcPoint.pR;
                } else {
                  editArcPoint = ArcPoint.angle;
                  editArcDir = ArcDir.undecided;
                  startingAngle =
                      (atan2(x - arc.x, -(y - arc.y)) / pi * 180).round() - 90;
                  if (startingAngle < 0) startingAngle += 360;
                }
              }
            }
          },
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            if (editIdx >= 0) {
              double x = dragUpdateDetails.localPosition.dx;
              double y = dragUpdateDetails.localPosition.dy;
              double dx = dragUpdateDetails.delta.dx;
              double dy = dragUpdateDetails.delta.dy;
              if (drawList[editIdx].type == DrawType.line) {
                Line line = drawList[editIdx].line;
                if (editLinePoint == LinePoint.p1) {
                  setState(() {
                    drawList[editIdx].line =
                        Line(_limitLoc(x), _limitLoc(y), line.x2, line.y2);
                  });
                } else if (editLinePoint == LinePoint.p2) {
                  setState(() {
                    drawList[editIdx].line =
                        Line(line.x1, line.y1, _limitLoc(x), _limitLoc(y));
                  });
                } else {
                  if (_checkLoc(line.x1 + dx) &&
                      _checkLoc(line.y1 + dy) &&
                      _checkLoc(line.x2 + dx) &&
                      _checkLoc(line.y2 + dy)) {
                    setState(() {
                      drawList[editIdx].line = Line(line.x1 + dx, line.y1 + dy,
                          line.x2 + dx, line.y2 + dy);
                    });
                  }
                }
              } else if (drawList[editIdx].type == DrawType.arc) {
                Arc arc = drawList[editIdx].arc;
                if (editArcPoint == ArcPoint.pC) {
                  setState(() {
                    drawList[editIdx].arc = Arc(_limitLoc(x), _limitLoc(y),
                        arc.radius, arc.angle1, arc.angle2);
                  });
                } else if (editArcPoint == ArcPoint.pR) {
                  double radius = sqrt(pow(x - arc.x, 2) + pow(y - arc.y, 2));
                  setState(() {
                    drawList[editIdx].arc = Arc(arc.x, arc.y,
                        radius <= 750 ? radius : 750, arc.angle1, arc.angle2);
                  });
                } else if (editArcPoint == ArcPoint.angle) {
                  int endingAngle =
                      (atan2(x - arc.x, -(y - arc.y)) / pi * 180).round() - 90;
                  if (endingAngle < 0) endingAngle += 360;
                  if (editArcDir == ArcDir.undecided) {
                    editArcDir = _dragDir(x - arc.x, y - arc.y,
                        dragUpdateDetails.delta.dx, dragUpdateDetails.delta.dy);
                  }
                  if (editArcDir == ArcDir.clockwise) {
                    int drawingAngle =
                        360 - ((startingAngle + 360 - endingAngle) % 360);
                    setState(() {
                      drawList[editIdx].arc = Arc(arc.x, arc.y, arc.radius,
                          startingAngle, drawingAngle);
                    });
                  } else if (editArcDir == ArcDir.counterclockwise) {
                    int drawingAngle =
                        -1 - ((startingAngle + 360 - endingAngle) % 360);
                    setState(() {
                      drawList[editIdx].arc = Arc(arc.x, arc.y, arc.radius,
                          startingAngle, drawingAngle);
                    });
                  }
                }
              }
            }
          },
        ),
      ),
    );

    final doList = ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: drawList.length,
        itemBuilder: (context, idx) {
          Draw data = drawList[idx];
          String title = '';
          String subtitle = '';
          if (data.type == DrawType.line) {
            Line line = data.line;
            title =
                'A(${line.x1.round()},${line.y1.round()}) B(${line.x2.round()},${line.y2.round()})';
            subtitle = 'Line';
          } else if (data.type == DrawType.arc) {
            Arc arc = data.arc;
            title =
                'Center(${arc.x.round()},${arc.y.round()}) Radius: ${arc.radius.round()} Starting: ${arc.angle1}° Drawing: ${arc.angle2}°';
            subtitle = 'Arc';
          }
          return ListTile(
            selected: idx == editIdx,
            selectedColor: Colors.white,
            selectedTileColor: Colors.blue,
            onTap: () {
              setState(() {
                editIdx = idx == editIdx ? -1 : idx;
              });
            },
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 18),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.color_lens,
                color: data.color,
              ),
              onPressed: () {
                ColorPicker(
                  color: data.color,
                  onColorChanged: (Color color) =>
                      setState(() => data.color = color),
                  width: 40,
                  height: 40,
                  borderRadius: 4,
                  spacing: 5,
                  runSpacing: 5,
                  wheelDiameter: 155,
                  heading: Text(
                    'Select color',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  subheading: Text(
                    'Select color shade',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  wheelSubheading: Text(
                    'Selected color and its shades',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  showMaterialName: true,
                  showColorName: true,
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    longPressMenu: true,
                  ),
                  enableOpacity: true,
                  materialNameTextStyle: Theme.of(context).textTheme.caption,
                  colorNameTextStyle: Theme.of(context).textTheme.caption,
                  colorCodeTextStyle: Theme.of(context).textTheme.bodyText2,
                  colorCodePrefixStyle: Theme.of(context).textTheme.caption,
                  selectedPickerTypeColor:
                      Theme.of(context).colorScheme.primary,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.wheel: true,
                  },
                ).showPickerDialog(
                  context,
                  constraints: const BoxConstraints(
                      minHeight: 480, minWidth: 300, maxWidth: 320),
                );
              },
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry>[
                popupMenuItemWithIcon(
                    value: 0,
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.black,
                    ),
                    text: 'Copy'),
                const PopupMenuDivider(),
                popupMenuItemWithIcon(
                    value: 1,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    text: 'Remove'),
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              offset: const Offset(0, 50),
              onSelected: (val) {
                switch (val) {
                  case 0:
                    setState(() {
                      drawList.add(drawList[idx].copy());
                      editIdx = drawList.length - 1;
                    });
                    break;
                  case 1:
                    setState(() {
                      drawList.removeAt(idx);
                      editIdx = drawList.length - 1;
                    });
                    break;
                }
              },
            ),
          );
        });

    final drawButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  drawList.add(Draw(type: DrawType.line, color: Colors.white)
                    ..line = Line(500, 1000, 1500, 1000));
                  editIdx = drawList.length - 1;
                });
              },
              icon: const Icon(Icons.draw),
              label: const Text('Line')),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  drawList.add(Draw(type: DrawType.arc, color: Colors.white)
                    ..arc = Arc(1000, 1000, 500, 0, 90));
                  editIdx = drawList.length - 1;
                });
              },
              icon: const Icon(Icons.draw),
              label: const Text('Arc')),
        ),
        Expanded(
            child: SwitchListTile(
          value: showGrid,
          onChanged: (value) {
            setState(() {
              showGrid = value;
            });
          },
          title: const Text('Show Grid'),
        ))
      ],
    );

    final deviceSize = MediaQuery.of(context).size;

    final verticalLayout = Column(
      children: <Widget>[
        drawButtons,
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Card(
              color: Colors.lightBlue[100],
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: doCanva,
              ),
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Card(color: Colors.lightBlue[100], child: doList),
            ))
      ],
    );

    final horizontalLayout = Row(
      children: <Widget>[
        Expanded(
            child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Card(
              color: Colors.lightBlue[100],
              child: FractionallySizedBox(
                heightFactor: 1.0,
                child: doCanva,
              )),
        )),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Card(
              color: Colors.lightBlue[100],
              child: Column(children: <Widget>[
                drawButtons,
                const Divider(),
                Expanded(child: doList)
              ]),
            ),
          ),
        )
      ],
    );

    return deviceSize.height > deviceSize.width
        ? verticalLayout
        : horizontalLayout;
  }

  void _clearList() {
    setState(() {
      drawList.clear();
    });
  }

  double _limitLoc(double i) {
    if (i < 0) {
      return 0;
    } else if (i > 2000) {
      return 2000;
    } else {
      return i;
    }
  }

  bool _checkLoc(double i) => i >= 0 && i <= 2000;

  ArcDir _dragDir(double x, double y, double moveX, double moveY) {
    if (x != 0 && y != 0 && moveX != 0 && moveY != 0) {
      if (x >= 0) {
        if (y >= 0) {
          return (moveX < 0 && moveY > 0)
              ? ArcDir.clockwise
              : ArcDir.counterclockwise;
        } else {
          return (moveX > 0 && moveY > 0)
              ? ArcDir.clockwise
              : ArcDir.counterclockwise;
        }
      } else {
        if (y >= 0) {
          return (moveX < 0 && moveY < 0)
              ? ArcDir.clockwise
              : ArcDir.counterclockwise;
        } else {
          return (moveX > 0 && moveY < 0)
              ? ArcDir.clockwise
              : ArcDir.counterclockwise;
        }
      }
    } else {
      //Can't decide
      return ArcDir.undecided;
    }
  }

  String _exportGraph() {
    Map<String, dynamic> exportData = {};
    List<Map<String, dynamic>> darwListData = [];
    for (var element in drawList) {
      if (element.type == DrawType.line) {
        Line line = element.line;
        darwListData.add({
          'type': 'line',
          'color': {
            'a': element.color.alpha,
            'r': element.color.red,
            'g': element.color.green,
            'b': element.color.blue
          },
          'data': {
            'x1': line.x1.round(),
            'y1': line.y1.round(),
            'x2': line.x2.round(),
            'y2': line.y2.round(),
          }
        });
      } else if (element.type == DrawType.arc) {
        Arc arc = element.arc;
        darwListData.add({
          'type': 'arc',
          'color': {
            'a': element.color.alpha,
            'r': element.color.red,
            'g': element.color.green,
            'b': element.color.blue,
          },
          'data': {
            'x': arc.x.round(),
            'y': arc.y.round(),
            'radius': arc.radius.round(),
            'angle1': arc.angle1,
            'angle2': arc.angle2
          }
        });
      }
    }
    exportData = {'graph': 'drawGraph', 'data': darwListData};
    return jsonEncode(exportData);
  }

  void _importGraph(List<Draw> importDrawList) {
    setState(() {
      drawList = importDrawList;
      editIdx = -1;
    });
  }
}

PopupMenuItem popupMenuItemWithIcon(
    {required value, required Icon icon, required String text}) {
  return PopupMenuItem(
      value: value,
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(
            width: 5,
          ),
          Expanded(child: Text(text))
        ],
      ));
}
