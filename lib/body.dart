import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:draw_graph/paint.dart';
import 'package:draw_graph/compute.dart';

class GraphCanva extends StatefulWidget {
  final GlobalKey<GraphCanvaState> _key;

  const GraphCanva(this._key) : super(key: _key);

  void clear() {
    _key.currentState?.clearList();
  }

  String exportData() {
    return _key.currentState!.exportGraph();
  }

  void importData(List<Draw> importDrawList) {
    _key.currentState!.importGraph(importDrawList);
  }

  @override
  State<GraphCanva> createState() => GraphCanvaState();
}

enum DoType { canva, list }

class GraphCanvaState extends State<GraphCanva> {
  int zoom = 1;
  int dropdownValue = 0;
  DrawType drawMenuChoose = DrawType.line;
  DoType doMenuChoose = DoType.canva;

  //line
  TextEditingController lineControllerX1 = TextEditingController();
  TextEditingController lineControllerY1 = TextEditingController();
  TextEditingController lineControllerX2 = TextEditingController();
  TextEditingController lineControllerY2 = TextEditingController();
  //arc
  TextEditingController arcControllerCenterX = TextEditingController();
  TextEditingController arcControllerCenterY = TextEditingController();
  TextEditingController arcControllerCircumferenceX = TextEditingController();
  TextEditingController arcControllerCircumferenceY = TextEditingController();
  TextEditingController arcControllerAngleA = TextEditingController();
  TextEditingController arcControllerAngleB = TextEditingController();

  List<FilteringTextInputFormatter> textInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'((^[0-9])|(^-))[0-9]*\.?[0-9]*'))
  ];
  List<Draw> drawList = [];
  Widget coordinateInput(
      {required TextEditingController controller,
      required String hint,
      String suffix = ''}) {
    return TextField(
      inputFormatters: textInputFormatter,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 18),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          suffixStyle: const TextStyle(fontSize: 18)),
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawTypeMenu = Row(
      children: <Widget>[
        Expanded(
          child: RadioListTile<DrawType>(
              title: const Text(
                'Draw Line',
                style: TextStyle(fontSize: 18),
              ),
              value: DrawType.line,
              groupValue: drawMenuChoose,
              onChanged: (DrawType? newValue) {
                setState(() {
                  drawMenuChoose = newValue!;
                });
              }),
        ),
        Expanded(
          child: RadioListTile<DrawType>(
              title: const Text(
                'Draw Arc',
                style: TextStyle(fontSize: 18),
              ),
              value: DrawType.arc,
              groupValue: drawMenuChoose,
              onChanged: (DrawType? newValue) {
                setState(() {
                  drawMenuChoose = newValue!;
                });
              }),
        )
      ],
    );

    final doTypeMenu = Row(
      children: <Widget>[
        Expanded(
          child: RadioListTile<DoType>(
              title: const Text(
                'Show canva',
                style: TextStyle(fontSize: 18),
              ),
              value: DoType.canva,
              groupValue: doMenuChoose,
              onChanged: (DoType? newValue) {
                setState(() {
                  doMenuChoose = newValue!;
                });
              }),
        ),
        Expanded(
          child: RadioListTile<DoType>(
              title: const Text(
                'Show list',
                style: TextStyle(fontSize: 18),
              ),
              value: DoType.list,
              groupValue: doMenuChoose,
              onChanged: (DoType? newValue) {
                setState(() {
                  doMenuChoose = newValue!;
                });
              }),
        )
      ],
    );

    final drawLine = SizedBox(
        height: 200,
        child: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 400,
                height: 50,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 20,
                      child: Text(
                        'A(',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: lineControllerX1, hint: 'x')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ',',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: lineControllerY1, hint: 'y')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ')',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 135,
                      child: DropdownButton<int>(
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                        value: dropdownValue,
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Line', style: TextStyle(fontSize: 18)),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Ray', style: TextStyle(fontSize: 18)),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('Line segment',
                                style: TextStyle(fontSize: 18)),
                          )
                        ],
                        onChanged: (int? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                      ),
                    )
                  ],
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 400,
                height: 50,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 20,
                      child: Text(
                        'B(',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: lineControllerX2, hint: 'x')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ',',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: lineControllerY2, hint: 'y')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ')',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 135,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (lineControllerX1.text.isNotEmpty &&
                              lineControllerY1.text.isNotEmpty &&
                              lineControllerX2.text.isNotEmpty &&
                              lineControllerY2.text.isNotEmpty) {
                            if (double.parse(lineControllerX1.text) !=
                                    double.parse(lineControllerX2.text) ||
                                double.parse(lineControllerY1.text) !=
                                    double.parse(lineControllerY2.text)) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                drawList.add(Draw(type: DrawType.line)
                                  ..line = Line(
                                      roundToN(
                                          (double.parse(lineControllerX1.text) /
                                              pow(10, zoom)),
                                          5),
                                      roundToN(
                                          (double.parse(lineControllerY1.text) /
                                              pow(10, zoom)),
                                          5),
                                      roundToN(
                                          (double.parse(lineControllerX2.text) /
                                              pow(10, zoom)),
                                          5),
                                      roundToN(
                                          (double.parse(lineControllerY2.text) /
                                              pow(10, zoom)),
                                          5),
                                      lineType: dropdownValue));
                                lineControllerX1.clear();
                                lineControllerY1.clear();
                                lineControllerX2.clear();
                                lineControllerY2.clear();
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text(
                                    'A and B are in the same position.'),
                                action: SnackBarAction(
                                  label: 'Clear point B',
                                  onPressed: () {
                                    setState(() {
                                      lineControllerX2.clear();
                                      lineControllerY2.clear();
                                    });
                                  },
                                ),
                              ));
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'Both points A and B must be filled in.'),
                            ));
                          }
                        },
                        icon: const Icon(Icons.draw),
                        label: const Text('Draw'),
                      ),
                    )
                  ],
                )),
          ],
        ));

    final drawArc = SizedBox(
        height: 200,
        child: Column(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 400,
                height: 50,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Center (',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerCenterX, hint: 'x')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ',',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerCenterY, hint: 'y')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ')',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 400,
                height: 50,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Radius (',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerCircumferenceX,
                            hint: 'x')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ',',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerCircumferenceY,
                            hint: 'y')),
                    const SizedBox(
                      width: 20,
                      child: Text(
                        ')',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: 400,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerAngleA,
                            hint: 'Starting',
                            suffix: '°')),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: coordinateInput(
                            controller: arcControllerAngleB,
                            hint: 'Drawing',
                            suffix: '°')),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 135,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (arcControllerCenterX.text.isNotEmpty &&
                              arcControllerCenterY.text.isNotEmpty &&
                              arcControllerCircumferenceX.text.isNotEmpty &&
                              arcControllerCircumferenceY.text.isNotEmpty &&
                              arcControllerAngleA.text.isNotEmpty &&
                              arcControllerAngleB.text.isNotEmpty) {
                            if ((double.parse(arcControllerCenterX.text) !=
                                    double.parse(
                                        arcControllerCircumferenceX.text) ||
                                double.parse(arcControllerCenterY.text) !=
                                    double.parse(
                                        arcControllerCircumferenceY.text))) {
                              if (double.parse(arcControllerAngleB.text)
                                      .round() !=
                                  0) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  drawList.add(Draw(type: DrawType.arc)
                                    ..arc = Arc(
                                        roundToN(
                                            (double.parse(
                                                    arcControllerCenterX.text) /
                                                pow(10, zoom)),
                                            5),
                                        roundToN(
                                            (double.parse(
                                                    arcControllerCenterY.text) /
                                                pow(10, zoom)),
                                            5),
                                        roundToN(
                                            (double.parse(arcControllerCircumferenceX
                                                    .text) /
                                                pow(10, zoom)),
                                            5),
                                        roundToN(
                                            (double.parse(
                                                    arcControllerCircumferenceY
                                                        .text) /
                                                pow(10, zoom)),
                                            5),
                                        double.parse(arcControllerAngleA.text)
                                            .round(),
                                        double.parse(arcControllerAngleB.text)
                                            .round()));
                                  arcControllerCenterX.clear();
                                  arcControllerCenterY.clear();
                                  arcControllerCircumferenceX.clear();
                                  arcControllerCircumferenceY.clear();
                                  arcControllerAngleA.clear();
                                  arcControllerAngleB.clear();
                                });
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text(
                                      'The drawing angle cannot be 0°.'),
                                  action: SnackBarAction(
                                    label: 'Clear drawing angle',
                                    onPressed: () {
                                      setState(() {
                                        arcControllerAngleB.clear();
                                      });
                                    },
                                  ),
                                ));
                              }
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text(
                                    'A and B are in the same position.'),
                                action: SnackBarAction(
                                  label: 'Clear point B',
                                  onPressed: () {
                                    setState(() {
                                      lineControllerX2.clear();
                                      lineControllerY2.clear();
                                    });
                                  },
                                ),
                              ));
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'The center, radius and angle must all be filled in.'),
                            ));
                          }
                        },
                        icon: const Icon(Icons.draw),
                        label: const Text('Draw'),
                      ),
                    )
                  ],
                )),
          ],
        ));

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
                foregroundPainter: Painter(
                  drawList: drawList,
                ),
                child: Container(
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      ' by YCY Program',
                      style: TextStyle(
                          fontSize: 100,
                          color: Color.fromARGB(200, 120, 120, 120)),
                    ))),
          ),
          onTapDown: (TapDownDetails tapDownDetails) {
            int cX = (tapDownDetails.localPosition.dx / pow(10, 3 - zoom) -
                    pow(10, zoom))
                .round();
            int cY = -(tapDownDetails.localPosition.dy / pow(10, 3 - zoom) -
                    pow(10, zoom))
                .round();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                action: SnackBarAction(
                  label: 'Done',
                  onPressed: () {},
                ),
                duration: const Duration(milliseconds: 1500),
                content: Text(
                  '($cX , $cY)',
                  style: const TextStyle(fontSize: 18),
                )));
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
                title: Text(
                  '(${roundToN(line.x1 * pow(10, zoom), 5 - zoom)} , ${roundToN(line.y1 * pow(10, zoom), 5 - zoom)}) to (${roundToN(line.x2 * pow(10, zoom), 5 - zoom)} , ${roundToN(line.y2 * pow(10, zoom), 5 - zoom)})',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(['Line', 'Ray', 'Line segment'][line.lineType],
                    style: const TextStyle(fontSize: 16)),
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
            } else if (data.type == DrawType.arc) {
              Arc arc = data.arc;
              return ListTile(
                title: Text(
                  'Center (${roundToN(arc.x1 * pow(10, zoom), 5 - zoom)} , ${roundToN(arc.y1 * pow(10, zoom), 5 - zoom)}) Radius  (${roundToN(arc.x2 * pow(10, zoom), 5 - zoom)} , ${roundToN(arc.y2 * pow(10, zoom), 5 - zoom)})',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                    'Starting angle = ${arc.angle1}° Drawing angle = ${arc.angle2}°',
                    style: const TextStyle(fontSize: 16)),
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

    final zoomSlider = Row(
      children: <Widget>[
        IconButton(
            onPressed: () {
              if (zoom > 1) {
                setState(() {
                  zoom--;
                  setZoom(-1);
                });
              }
            },
            icon: const Icon(
              Icons.zoom_in,
              size: 30,
            )),
        Expanded(
          child: Slider(
              value: double.parse(zoom.toString()),
              min: 1,
              max: 5,
              divisions: 4,
              label: '${pow(10, zoom)}',
              onChanged: (double val) {
                int scaling = val.round() - zoom;
                setState(() {
                  zoom = val.round();
                  setZoom(scaling);
                });
              }),
        ),
        IconButton(
            onPressed: () {
              if (zoom < 5) {
                setState(() {
                  zoom++;
                  setZoom(1);
                });
              }
            },
            icon: const Icon(
              Icons.zoom_out,
              size: 30,
            ))
      ],
    );

    final verticalLayout = Column(
      children: <Widget>[
        drawTypeMenu,
        drawMenuChoose == DrawType.line ? drawLine : drawArc,
        doTypeMenu,
        doMenuChoose == DoType.canva ? zoomSlider : Container(),
        doMenuChoose == DoType.canva ? doCanva : doList
      ],
    );

    final horizontalLayout = Row(
      children: <Widget>[
        Expanded(
            child: Column(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Card(
                color: Colors.lightBlue[100],
                child: Column(children: <Widget>[
                  const Text(
                    'Draw Line',
                    style: TextStyle(fontSize: 25),
                  ),
                  Expanded(child: drawLine),
                ]),
              ),
            )),
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Card(
                color: Colors.lightBlue[100],
                child: Column(children: <Widget>[
                  const Text(
                    'Draw Arc',
                    style: TextStyle(fontSize: 25),
                  ),
                  Expanded(child: drawArc),
                ]),
              ),
            ))
          ],
        )),
        Expanded(
            child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Card(
            color: Colors.lightBlue[100],
            child: Column(children: <Widget>[
              doTypeMenu,
              const Divider(),
              doMenuChoose == DoType.canva ? zoomSlider : Container(),
              doMenuChoose == DoType.canva ? doCanva : doList
            ]),
          ),
        ))
      ],
    );

    final deviceSize = MediaQuery.of(context).size;

    return deviceSize.height > deviceSize.width
        ? verticalLayout
        : horizontalLayout;
  }

  void setZoom(int scaling) {
    for (int i = 0; i < drawList.length; i++) {
      Draw element = drawList[i];
      if (element.type == DrawType.line) {
        Line line = element.line;
        drawList[i].line = Line(
            roundToN(line.x1 / pow(10, scaling), 5),
            roundToN(line.y1 / pow(10, scaling), 5),
            roundToN(line.x2 / pow(10, scaling), 5),
            roundToN(line.y2 / pow(10, scaling), 5),
            lineType: line.lineType);
      } else if (element.type == DrawType.arc) {
        Arc arc = element.arc;
        drawList[i].arc = Arc(
            roundToN(arc.x1 / pow(10, scaling), 5),
            roundToN(arc.y1 / pow(10, scaling), 5),
            roundToN(arc.x2 / pow(10, scaling), 5),
            roundToN(arc.y2 / pow(10, scaling), 5),
            arc.angle1,
            arc.angle2);
      }
    }
  }

  void clearList() {
    setState(() {
      drawList.clear();
    });
  }

  String exportGraph() {
    Map<String, dynamic> exportData = {};
    List<Map<String, dynamic>> darwListData = [];
    for (var element in drawList) {
      if (element.type == DrawType.line) {
        Line line = element.line;
        darwListData.add({
          'type': 'line',
          'data': {
            'x1': line.x1,
            'y1': line.y1,
            'x2': line.x2,
            'y2': line.y2,
            'type': line.lineType
          }
        });
      } else if (element.type == DrawType.arc) {
        Arc arc = element.arc;
        darwListData.add({
          'type': 'arc',
          'data': {
            'x1': arc.x1,
            'y1': arc.y1,
            'x2': arc.x2,
            'y2': arc.y2,
            'angle1': arc.angle1,
            'angle2': arc.angle2
          }
        });
      }
    }
    exportData = {'graph': 'drawGraph', 'data': darwListData};
    return jsonEncode(exportData);
  }

  void importGraph(List<Draw> importDrawList) {
    setState(() {
      drawList = importDrawList;
    });
  }
}
