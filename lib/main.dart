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
              /*switch (val) {
                case 0:
                  clear(context, body);
                  break;
                case 1:
                  export(context, body);
                  break;
                case 2:
                  import(context, body);
                  break;
              }*/
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
}
