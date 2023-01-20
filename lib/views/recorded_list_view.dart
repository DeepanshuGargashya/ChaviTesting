import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class RecordListView extends StatefulWidget {
  final String records;
  final Function onRecordsClear;
  const RecordListView({
    Key? key,
    required this.records,
    required this.onRecordsClear,
  }) : super(key: key);

  @override
  _RecordListViewState createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  late int totalDuration;
  late int currentDuration;
  double completedPercentage = 0.0;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    print("record length ");
    print(widget.records.length);
    return widget.records.length == 0
        ? SizedBox(
            height: 10,
          )
        : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFFFEDF3),
                      Color(0xFFFFFFFF),
                    ]),
                borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Stack(children: [
                      Positioned(
                        // top: -1,
                        // right: -1,
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.onRecordsClear();
                            });
                          },
                        ),
                      ),
                    ])
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    value: completedPercentage,
                  ),
                ),
                IconButton(
                    icon:
                        isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    onPressed: () {
                      onPlay(filePath: widget.records);
                    })
              ],
            ),
          );
  }

  Future<void> onPlay({required String filePath}) async {
    AudioPlayer audioPlayer = AudioPlayer();

    if (!isPlaying) {
      audioPlayer.play(UrlSource(filePath));
      print("filePath2");
      print(filePath);
      setState(() {
        completedPercentage = 0.0;
        isPlaying = true;
      });

      audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          isPlaying = false;
          completedPercentage = 0.0;
        });
      });
      audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          totalDuration = duration.inMicroseconds;
        });
      });

      audioPlayer.onPositionChanged.listen((duration) {
        setState(() {
          currentDuration = duration.inMicroseconds;
          completedPercentage =
              currentDuration.toDouble() / totalDuration.toDouble();
        });
      });
    }
  }
}
