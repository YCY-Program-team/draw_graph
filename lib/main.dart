import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:draw_graph/body.dart';
import 'package:draw_graph/paint.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:draw_graph/qrcode_scan.dart';

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
              const PopupMenuItem(
                value: 0,
                child: Text('Clear'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 1,
                child: Text('Export'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 2,
                child: Text('Import'),
              )
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
          );
        }).then((value) {
      if (value) {
        body.clear();
      }
    });
  }

  void export(context, GraphCanva body) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 500,
              color: Colors.yellow[100],
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: QrImage(
                      data: body.exportData(),
                      version: QrVersions.auto,
                      embeddedImage: const AssetImage('assets/icon.png'),
                      embeddedImageStyle:
                          QrEmbeddedImageStyle(size: const Size(40, 40)),
                      errorStateBuilder: (cxt, err) {
                        return const Text('QR code error');
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))
                ],
              ));
        });
  }

  Future importCheck(context, GraphCanva body) async {
    if (body.drawList().isNotEmpty) {
      return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Import Graph'),
              content: const Text(
                  'After importing, all current graph will be cleared.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Import and Clear',
                      style: TextStyle(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'))
              ],
            );
          });
    } else {
      return true;
    }
  }

  void import(context, GraphCanva body) {
    importCheck(context, body).then((value) {
      if (value == true) {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const QRcodeScannerWithController(),
          ),
        )
            .then((value) {
          try {
            Map scanData = jsonDecode(value);
            List drawListData = scanData['data'];
            List<Draw> drawList = [];
            for (var element in drawListData) {
              switch (element['type']) {
                case 'line':
                  Map data = element['data'];
                  drawList.add(Draw(type: DrawType.line)
                    ..line = Line(
                        data['x1'], data['y1'], data['x2'], data['y2'],
                        lineType: data['type']));
                  break;
                case 'arc':
                  Map data = element['data'];
                  drawList.add(Draw(type: DrawType.arc)
                    ..arc = Arc(data['x1'], data['y1'], data['x2'], data['y2'],
                        data['angle1'], data['angle2']));
                  break;
              }
            }
            body.importData(drawList);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import successful!')));
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Import failed. Please check if this QR code is provided by this APP.')));
          }
        });
      }
    });
  }
}
