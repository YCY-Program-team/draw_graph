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

class GraphCanvaState extends State<GraphCanva> {
  List<Draw> drawList = [];
  int editIdx = -1;
  LinePoint editLinePoint = LinePoint.p1;

  @override
  Widget build(BuildContext context) {
    final doCanva = Expanded(
        child: FittedBox(
      child: Container(
        margin: const EdgeInsets.all(100),
        child: GestureDetector(
          child: Container(
            width: 2000,
            height: 2000,
            color: Colors.blue,
            child: CustomPaint(
                foregroundPainter:
                    Painter(drawList: drawList, editIdx: editIdx),
                child: Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      ' by YCY Program',
                      style: TextStyle(
                          fontSize: 100,
                          color: Color.fromARGB(200, 120, 120, 120)),
                    ))),
          ),
          onPanDown: (DragDownDetails dragDownDetails) {
            if (editIdx >= 0) {
              double x = dragDownDetails.localPosition.dx;
              double y = dragDownDetails.localPosition.dy;
              if (x >= 0 && x <= 2000 && y >= 0 && y <= 2000) {
                Line line = drawList[editIdx].line;
                if ((line.x1 - x).abs() < 100 && (line.y1 - y).abs() < 100) {
                  editLinePoint = LinePoint.p1;
                } else if ((line.x2 - x).abs() < 100 &&
                    (line.y2 - y).abs() < 100) {
                  editLinePoint = LinePoint.p2;
                } else {
                  editLinePoint = LinePoint.pn;
                }
              }
            }
          },
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            if (editIdx >= 0) {
              double x = dragUpdateDetails.localPosition.dx;
              double y = dragUpdateDetails.localPosition.dy;
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
            }
          },
        ),
      ),
    ));

    final doList = Expanded(
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
                  '(${line.x1.round()},${line.y1.round()}) to (${line.x2.round()},${line.y2.round()})',
                  style: const TextStyle(fontSize: 20),
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
