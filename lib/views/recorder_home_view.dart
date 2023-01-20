import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_voice/views/recorded_list_view.dart';
import 'package:flutter_voice/views/recorder_view.dart';

class RecorderHomeView extends StatefulWidget {
  final String _title;

  const RecorderHomeView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _RecorderHomeViewState createState() => _RecorderHomeViewState();
}

class _RecorderHomeViewState extends State<RecorderHomeView> {
  late Directory appDirectory;
  String records = "";

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      appDirectory.list().listen((onData) {
        if (onData.path.contains('.aac'))
          setState(() {
            records = onData.path;
          });
      }).onDone(() {
        // records = records.reversed.toList();
        setState(() {});
        print(appDirectory.path);
        print("appDirectory.path");
      });
    });
  }

  @override
  void dispose() {
    appDirectory.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Hello"),
            Text("Hello2"),
            Container(
              width: 50,
              height: 50,
              child: Center(
                child: RecorderView(
                  onSaved: onRecordComplete,
                ),
              ),
            )
          ]),
          RecordListView(
            records: records,
            onRecordsClear: () {
              setState(() {
                records = "";
              });
            },
          ),
        ],
      ),
    );
  }

  onRecordComplete() {
    // records.clear();
    appDirectory.list().listen((onData) {
      if (onData.path.contains('.aac'))
        setState(() {
          records = onData.path;
        });
    }).onDone(() {
      setState(() {});
    });
    print("records");
    print(records);
  }
}
