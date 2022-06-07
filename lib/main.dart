import 'dart:convert';
import 'package:draw_graph/paint.dart';
import 'package:flutter/material.dart';
import 'package:draw_graph/body.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:draw_graph/qrcode_scan.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppView(),
      color: Colors.blue,
      title: 'Draw Graph',
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var body = GraphCanva(GlobalKey<GraphCanvaState>());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Graph'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry>[
              popupMenuItemWithIcon(
                  value: 0,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                  text: 'Clear'),
              const PopupMenuDivider(),
              popupMenuItemWithIcon(
                  value: 1,
                  icon: const Icon(
                    Icons.output,
                    color: Colors.black,
                  ),
                  text: 'Export'),
              const PopupMenuDivider(),
              popupMenuItemWithIcon(
                  value: 2,
                  icon: const Icon(
                    Icons.input,
                    color: Colors.black,
                  ),
                  text: 'Import'),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            offset: const Offset(0, 50),
            onSelected: (val) {
              switch (val) {
                case 0:
                  clear(context, body);
                  break;
                case 1:
                  export(context, body);
                  break;
                case 2:
                  import(context, body);
                  break;
              }
            },
          )
        ],
      ),
      body: Center(child: body),
    );
  }

  void clear(context, GraphCanva body) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Clear the Graph'),
            content: const Text('Once cleared, it cannot be restored.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'))
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        }).then((value) {
      if (value) {
        body.clear();
      }
    });
  }

  final serverUrl =
      'https://script.google.com/macros/s/AKfycbxyRPmjUKUk0rIzttjfikrGxWWiKHGuiA1WM5xxkRkZ6Tdxe4icABaIT6oI4b1FNjnwPw/exec';

  Future<String> _createCode(String data, List<Draw> drawList) async {
    if (drawList.isNotEmpty) {
      var res = await http
          .post(Uri.parse(serverUrl), body: {'action': 'csc', 'data': data});
      return jsonDecode(res.body)['code'];
    } else {
      return '';
    }
  }

  void export(context, GraphCanva body) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder(
              future: _createCode(body.exportData(), body.drawList()),
              builder: ((context, snapshot) {
                Widget content;
                if (snapshot.hasData) {
                  if (snapshot.data != '') {
                    content = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: QrImage(
                            data: snapshot.data.toString(),
                            version: QrVersions.auto,
                            embeddedImage: const AssetImage('assets/icon.png'),
                            embeddedImageStyle:
                                QrEmbeddedImageStyle(size: const Size(40, 40)),
                            errorStateBuilder: (cxt, err) {
                              return const Text('QR code error');
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            'Export code: "${snapshot.data}", will expire in 24 hours.')
                      ],
                    );
                  } else {
                    content = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          Icons.data_array,
                          color: Colors.red,
                          size: 60,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('There are no graph to export.')
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  content = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Error setting up code, please make sure you are connected to the Internet.')
                    ],
                  );
                } else {
                  content = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Loading...')
                    ],
                  );
                }
                return AlertDialog(
                  title: const Text('Export Graph'),
                  content: SizedBox(
                    height: 300,
                    width: 300,
                    child: content,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'))
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                );
              }));
        });
  }

  void import(context, GraphCanva body) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String inputData = '';
          return AlertDialog(
            title: const Text('Import Graph'),
            content: FractionallySizedBox(
              widthFactor: 1,
              child: SizedBox(
                height: 120,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Note: The current graph will be cleared after importing.',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      maxLength: 6,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          counterText: '',
                          labelText: 'Sharing code',
                          hintText: 'xxxxxx'),
                      onChanged: (value) => inputData = value,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(inputData),
                  child: const Text(
                    'Import',
                  )),
              TextButton(
                  onPressed: () => {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QRcodeScannerWithController(),
                              ),
                            )
                            .then((scanData) =>
                                Navigator.of(context).pop(scanData))
                      },
                  child: const Text(
                    'Scan QR Code',
                  )),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(''),
                  child: const Text('Cancel'))
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        }).then(
      (value) {
        if (value.runtimeType == String && value.toString().length == 6) {
          try {
            http.post(Uri.parse(serverUrl),
                body: {'action': 'gsd', 'code': value}).then((res) {
              var importData = jsonDecode(res.body)['data'];
              if (importData != 'error') {
                List drawListData = importData['data'];
                List<Draw> drawList = [];
                for (var element in drawListData) {
                  switch (element['type']) {
                    case 'line':
                      Map data = element['data'];
                      drawList.add(Draw(type: DrawType.line)
                        ..line = Line(
                            data['x1'].toDouble(),
                            data['y1'].toDouble(),
                            data['x2'].toDouble(),
                            data['y2'].toDouble()));
                      break;
                    case 'arc':
                      Map data = element['data'];
                      drawList.add(Draw(type: DrawType.arc)
                        ..arc = Arc(
                            data['x'].toDouble(),
                            data['y'].toDouble(),
                            data['radius'].toDouble(),
                            data['angle1'],
                            data['angle2']));
                      break;
                  }
                }
                body.importData(drawList);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import successful!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid code.')));
              }
            }).onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Error getting graph data, please make sure the network is connected.')));
            });
          } catch (error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Import failed.')));
          }
        }
      },
    );
  }
}
