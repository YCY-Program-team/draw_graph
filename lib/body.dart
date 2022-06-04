import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:draw_graph/paint.dart';
import 'package:draw_graph/compute.dart';

class GraphCanva extends StatefulWidget {
  final GlobalKey<GraphCanvaState> _key;

  const GraphCanva(this._key) : super(key: _key);

  void clear() {
    _key.currentState?.clearList();
  }

  List<Draw> drawList() => _key.currentState!.drawList;

  @override
  State<GraphCanva> createState() => GraphCanvaState();
}

enum DoType { canva, list }

enum LinePoint { pn, p1, p2 }

enum ArcPoint { pn, pC, pR, angle }

class GraphCanvaState extends State<GraphCanva> {
  List<Draw> drawList = [];
  int editIdx = -1;
  LinePoint editLinePoint = LinePoint.p1;
  ArcPoint editArcPoint = ArcPoint.pn;

  @override
  Widget build(BuildContext context) {
    final doCanva = Expanded(
        flex: 3,
        child: FittedBox(
          child: Container(
            margin: const EdgeInsets.all(100),
            child: GestureDetector(
              child: Container(
                width: 2000,
                height: 2000,
                color: Colors.grey[400],
                child: CustomPaint(
                    foregroundPainter:
                        Painter(drawList: drawList, editIdx: editIdx),
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
                    if (x >= 0 && x <= 2000 && y >= 0 && y <= 2000) {
                      Line line = drawList[editIdx].line;
                      if ((line.x1 - x).abs() < 100 &&
                          (line.y1 - y).abs() < 100) {
                        editLinePoint = LinePoint.p1;
                      } else if ((line.x2 - x).abs() < 100 &&
                          (line.y2 - y).abs() < 100) {
                        editLinePoint = LinePoint.p2;
                      } else {
                        editLinePoint = LinePoint.pn;
                      }
                    }
                  } else if (drawList[editIdx].type == DrawType.arc) {
                    if (x >= 0 && x <= 2000 && y >= 0 && y <= 2000) {
                      Arc arc = drawList[editIdx].arc;
                      if ((arc.x - x).abs() < 100 && (arc.y - y).abs() < 100) {
                        editArcPoint = ArcPoint.pC;
                      } else if ((sqrt(pow(x - arc.x, 2) + pow(y - arc.y, 2)) -
                                  arc.radius)
                              .abs() <
                          100) {
                        editArcPoint = ArcPoint.pR;
                      } else {
                        editArcPoint = ArcPoint.pn;
                      }
                    }
                  }
                }
              },
              onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
                if (editIdx >= 0) {
                  double x = dragUpdateDetails.localPosition.dx;
                  double y = dragUpdateDetails.localPosition.dy;
                  if (drawList[editIdx].type == DrawType.line) {
                    if (x >= 0 && x <= 2000 && y >= 0 && y <= 2000) {
                      Line line = drawList[editIdx].line;
                      if (editLinePoint == LinePoint.p1) {
                        setState(() {
                          drawList[editIdx].line = Line(x, y, line.x2, line.y2);
                        });
                      } else if (editLinePoint == LinePoint.p2) {
                        setState(() {
                          drawList[editIdx].line = Line(line.x1, line.y1, x, y);
                        });
                      }
                    }
                  } else if (drawList[editIdx].type == DrawType.arc) {
                    if (x >= 0 && x <= 2000 && y >= 0 && y <= 2000) {
                      Arc arc = drawList[editIdx].arc;
                      if (editArcPoint == ArcPoint.pC) {
                        setState(() {
                          drawList[editIdx].arc =
                              Arc(x, y, arc.radius, arc.angle1, arc.angle2);
                        });
                      } else if (editArcPoint == ArcPoint.pR) {
                        double radius =
                            sqrt(pow(x - arc.x, 2) + pow(y - arc.y, 2));
                        if (radius <= 750) {
                          setState(() {
                            drawList[editIdx].arc = Arc(
                                arc.x, arc.y, radius, arc.angle1, arc.angle2);
                          });
                        }
                      }
                    }
                  }
                }
              },
            ),
          ),
        ));

    final doList = Expanded(
      flex: 2,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: drawList.length,
          itemBuilder: (context, idx) {
            Draw data = drawList[idx];
            if (data.type == DrawType.line) {
              Line line = data.line;
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
                  'A(${line.x1.round()},${line.y1.round()}) B(${line.x2.round()},${line.y2.round()})',
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: const Text(
                  'Line',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 0,
                      child: Text('Remove'),
                    )
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  offset: const Offset(0, 50),
                  onSelected: (val) {
                    switch (val) {
                      case 0:
                        setState(() {
                          drawList.removeAt(idx);
                          editIdx = drawList.length - 1;
                        });
                        break;
                    }
                  },
                ),
              );
            } else if (data.type == DrawType.arc) {
              Arc arc = data.arc;
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
                  'Center(${arc.x.round()},${arc.y.round()}) Radius: ${arc.radius.round()} Starting: ${arc.angle1}° Drawing: ${arc.angle2}°',
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: const Text(
                  'Arc',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 0,
                      child: Text('Remove'),
                    )
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  offset: const Offset(0, 50),
                  onSelected: (val) {
                    switch (val) {
                      case 0:
                        setState(() {
                          drawList.removeAt(idx);
                        });
                        break;
                    }
                  },
                ),
              );
            } else {
              return Container();
            }
          }),
    );
    final verticalLayout = Column(
      children: <Widget>[
        ElevatedButton(
            onPressed: () {
              setState(() {
                drawList.add(Draw(type: DrawType.line)
                  ..line = Line(500, 1000, 1500, 1000));
                editIdx = drawList.length - 1;
              });
            },
            child: const Text('add line')),
        ElevatedButton(
            onPressed: () {
              setState(() {
                drawList.add(Draw(type: DrawType.arc)
                  ..arc = Arc(1000, 1000, 500, 0, 90));
                editIdx = drawList.length - 1;
              });
            },
            child: const Text('add arc')),
        doCanva,
        doList
      ],
    );
    final horizontalLayout = Row(
      children: <Widget>[
        OutlinedButton(
            onPressed: () {
              setState(() {
                drawList.add(Draw(type: DrawType.line)
                  ..line = Line(500, 1000, 1500, 1000));
                editIdx = drawList.length - 1;
              });
            },
            child: const Text('add line')),
        doCanva,
        doList
      ],
    );

    final deviceSize = MediaQuery.of(context).size;
    return deviceSize.height > deviceSize.width
        ? verticalLayout
        : horizontalLayout;
  }

  void clearList() {
    setState(() {
      drawList.clear();
    });
  }
}
