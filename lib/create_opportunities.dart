import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:flutter_voice/fade_slide_transition.dart';
import 'package:flutter_voice/views/recorded_list_view.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../Validator/ValidateData.dart';
import '../../constant.dart';
// import '../../login/widgets/fade_slide_transition.dart';

class NewOpportunities extends StatefulWidget {
  // final Animation<double> animation;
  const NewOpportunities({Key? key}) : super(key: key);

  @override
  State<NewOpportunities> createState() => _NewOpportunitiesState();
}

enum RecordingState {
  UnSet,
  Set,
  Recording,
  Stopped,
}

class _NewOpportunitiesState extends State<NewOpportunities>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _headerTextAnimation;
  late final Animation<double> _formElementAnimation;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final loanController = TextEditingController();
  final tenureController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  FlutterSound flutterSound = FlutterSound();
  bool isRecorderInit = false;
  bool isRecording = false;
  IconData _recordIcon = Icons.mic_none;

  RecordingState _recordingState = RecordingState.UnSet;

  // Recorder properties
  late FlutterAudioRecorder2 audioRecorder;
  late Directory appDirectory;
  String records = "";
  @override
  void initState() {
    // TODO: implement initState
    // print(data);
    super.initState();
    checkPermission();
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      appDirectory.list().listen((onData) {
        if (onData.path.contains('.aac')) {}
        // setState(() {
        //   records = onData.path;
        // });
      }).onDone(() {
        // records = records.reversed.toList();
        setState(() {});
        print(appDirectory.path);
        print("appDirectory.path");
      });
    });
    setState(() {});
    _soundRecorder = FlutterSoundRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: kLoginAnimationDuration,
    );

    final fadeSlideTween = Tween<double>(begin: 0.0, end: 1.0);
    _headerTextAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.4,
        curve: Curves.easeInOut,
      ),
    ));
    _formElementAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.4,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));
    _animationController.forward();
    // recordInitialise();
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    _recordingState = RecordingState.Set;
    _recordIcon = Icons.mic;

    return true;
  }

  void recordInitialise() async {}

  void startRecord() async {
    print("record start");
    // recordInitialise();

    var tempDir = await getTemporaryDirectory();
    var path = "${tempDir.path}/flutter_sound.aac";
    if (!isRecorderInit) {
      print("return record");
      return;
    }
    if (isRecording) {
      print("stop recording");
      await _soundRecorder!.stopRecorder();
    } else {
      print("start recording");
      await _soundRecorder!.startRecorder(
        toFile: path,
      );
    }
    setState(() {
      isRecording = !isRecording;
      print(File(path));
    });
  }

  Future<void> _onRecordButtonPressed() async {
    switch (_recordingState) {
      case RecordingState.Set:
        setState(() {
          records = "";
        });
        await _recordVoice();
        break;

      case RecordingState.Recording:
        await _stopRecording();
        _recordingState = RecordingState.Stopped;
        _recordIcon = Icons.mic;

        break;

      case RecordingState.Stopped:
        setState(() {
          records = "";
        });
        await _recordVoice();
        break;

      case RecordingState.UnSet:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please allow recording from settings '),
        ));
        break;
    }
  }

  _initRecorder() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String filePath =
        '${appDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    audioRecorder =
        FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.AAC);
    await audioRecorder.initialized;
  }

  _startRecording() async {
    await audioRecorder.start();
    setState(() {
      isRecording = !isRecording;
      // print(File(path));
    });
    // var recording = await audioRecorder.current(channel: 0);
    // var currente = recording!.audioFormat;
    // print("currente");
    // print(currente);
  }

  onRecordComplete() {
    print("on complete record");
    // records.clear();
    appDirectory.list().listen((onData) {
      if (onData.path.contains('.aac')) {
        setState(() {
          records = onData.path;
        });
      }
    }).onDone(() {
      setState(() {});
    });
  }

  _stopRecording() async {
    await audioRecorder.stop();
    setState(() {
      isRecording = false;
    });
    onRecordComplete();
  }

  Future<void> _recordVoice() async {
    final hasPermission = await checkPermission();
    print("hasPermission ");
    print(hasPermission);
    if (hasPermission) {
      await _initRecorder();

      await _startRecording();
      _recordingState = RecordingState.Recording;
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please allow recording from settings.'),
      ));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _recordingState = RecordingState.UnSet;

    setState(() {
      records = "";
    });
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
    appDirectory.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final space = height > 650 ? kSpaceM : kSpaceS;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // title: Text("New Opportunities",
          //   style: TextStyle (
          //     // 'Work Sans',
          //     fontFamily: "ProductSansRegular",
          //     letterSpacing: 1,
          //     // fontSize: 12*ffem,
          //     fontWeight: FontWeight.w400,
          //     height: 1.1725*ffem/fem,
          //     // color: Color(0xff959fba),
          //
          //   ),
          // ),
          centerTitle: true,
          // flexibleSpace: Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: <Color>[
          //           Color(0xFFFF6A92),
          //           Color(0xFFFF5C5D),
          //         ]),
          //   ),
          // ),
          leading: IconButton(
            onPressed: () {
              setState(() {
                records = "";
              });
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(25 * fem, 0 * fem, 25 * fem, 0 * fem),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _headerTextAnimation,
                        additionalOffset: 2 * space,
                        child: Text(
                          'Add Opportunity',
                          style: TextStyle(
                            // 'Work Sans',
                            fontFamily: "ProductSans",
                            letterSpacing: 0.5,
                            fontSize: 30 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.1725 * ffem / fem,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // Text('Loan Info',
                      // style: TextStyle(
                      //     fontSize: 20,
                      //     fontFamily: 'ProductSansRegular',
                      //     fontWeight: FontWeight.w200)),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 15 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Username ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: usernameController,
                              // maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Username',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Username is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Email Id ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: emailController,
                              // maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter Email Id',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Email Id is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Mobile Number ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: mobileController,
                              maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter Mobile Number',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Mobile Number is Required';
                                } else if (value.length < 10) {
                                  return 'Enter Valid Mobile Number';
                                } else if (RegExp(r'^[1-9]{1}[0-9]{9}$')
                                    .hasMatch(value!)) {
                                  return null;
                                }
                                return 'Mobile Number Invalid';
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Loan Amount ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: loanController,
                              maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter Loan amount',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Loan amount is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Tenure (in months)',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: tenureController,
                              // maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter Tenure',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Tenure is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              6 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Pincode ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: pincodeController,
                              maxLength: 6,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Pincode',
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Pincode is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'State ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: stateController,
                              // maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter State',
                                enabled: false,
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Color(0xff959fba),
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'State is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              6 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'City ',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1.5 * fem),
                            child: TextFormField(
                              controller: cityController,
                              // maxLength: 10,
                              // autofocus: true,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.all(15),
                                fillColor: Color(0xffe9ecf5),
                                filled: true,
                                hintText: 'Enter City',
                                enabled: false,
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Color(0xff959fba),
                                    letterSpacing: 0.5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none),
                              ),
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'City is Required';
                                } else {
                                  return null;
                                }
                              },
                              // onChanged: (value){
                              //   setState(() {
                              //     otpSentStatus = false;
                              //   });
                              // },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // group167cge (455:270)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * fem),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        // additionalOffset: fem,
                        additionalOffset: 0.0,
                        child: Container(
                          // emailidwU2 (455:267)
                          margin: EdgeInsets.fromLTRB(
                              6 * fem, 0 * fem, 0 * fem, 3 * fem),
                          child: Text(
                            'Description',
                            style: TextStyle(
                              // 'Work Sans',
                              fontFamily: "ProductSansRegular",
                              letterSpacing: 0.5,
                              fontSize: 12 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff959fba),
                            ),
                          ),
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: 2 * space,
                        child: Form(
                          // key: _formKeyMob,
                          child: Container(
                            // autogroupgcsrc6J (ToMwY2n2sKacfe6UTxGCSr)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 0 * fem),
                            padding: EdgeInsets.fromLTRB(
                                17 * fem, 15.5 * fem, 17 * fem, 15.5 * fem),
                            width: double.infinity,
                            height: 188 * fem,
                            decoration: BoxDecoration(
                              color: Color(0xffe9ecf5),
                              borderRadius: BorderRadius.circular(12 * fem),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x3f000000),
                                  offset: Offset(0 * fem, 4 * fem),
                                  blurRadius: 2 * fem,
                                ),
                              ],
                            ),
                            child: TextFormField(
                              maxLength: 500,
                              minLines: 8,
                              // any number you need (It works as the rows for the textarea)
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: descriptionController,
                              validator: (value) {
                                // if(!ValidateData.validateText(value)){
                                //   return null ;
                                // }else if(value!.trim().isEmpty){
                                //   return null;
                                // }
                                return null;
                              },
                              // onSaved: (value) {
                              //   setState((){
                              //     reason = value!;
                              //   });
                              // },
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter Description here",
                                hintStyle: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Colors.black54,
                                    letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        // group167cge (455:270)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 20 * fem, 0 * fem, 20 * fem),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12 * fem),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideTransition(
                              animation: _formElementAnimation,
                              // additionalOffset: fem,
                              additionalOffset: 0.0,
                              child: Container(
                                // emailidwU2 (455:267)
                                margin: EdgeInsets.fromLTRB(
                                    6 * fem, 20 * fem, 0 * fem, 3 * fem),
                                child: Text(
                                  'If you want to record the Opportunity',
                                  style: TextStyle(
                                    // 'Work Sans',
                                    fontFamily: "ProductSansRegular",
                                    letterSpacing: 0.5,
                                    fontSize: 13 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1725 * ffem / fem,
                                    color: Color(0xff959fba),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            FadeSlideTransition(
                              animation: _formElementAnimation,
                              // additionalOffset: fem,
                              additionalOffset: 0.0,
                              child: Container(
                                // emailidwU2 (455:267)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 0 * fem),
                                child: FloatingActionButton(
                                  onPressed: () async {
                                    await _onRecordButtonPressed();
                                    setState(() {});

                                    // Navigator.push(
                                    //   context,
                                    //   PageTransition(type: PageTransitionType.rightToLeftWithFade, child: NewOpportunities()),
                                    // );
                                  },
                                  tooltip: "Create Opportunity",
                                  child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              Color(0xFFFF6A92),
                                              Color(0xFFFF5C5D),
                                            ])),
                                    child: Icon(
                                      isRecording
                                          ? Icons.send
                                          : Icons.keyboard_voice,
                                      size: 30,
                                    ),
                                    //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: RecordListView(
                          records: records,
                          onRecordsClear: () {
                            setState(() {
                              records = "";
                            });
                          },
                        ),
                      ),
                      FadeSlideTransition(
                        animation: _formElementAnimation,
                        additionalOffset: space,
                        child: Container(
                          // frame5mG2 (380:71)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 10 * fem),
                          width: double.infinity,
                          height: 50 * fem,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5 * fem),
                            gradient: LinearGradient(
                              begin: Alignment(-1, -0.02),
                              end: Alignment(1, -0.02),
                              colors: <Color>[
                                Color(0xffff6a92),
                                Color(0xffff5c5d)
                              ],
                              stops: <double>[0, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3f000000),
                                offset: Offset(0 * fem, 4 * fem),
                                blurRadius: 2 * fem,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              onSurface: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () async {
                              // if (!_formKeyEmail.currentState!.validate()) {
                              //   return null;
                              // }
                              // _formKeyEmail.currentState!.save();
                              // var accountType = await _preferencesService.getSettings('userType');
                              // CredHubLoader().fetchData(context);
                            },
                            child: Center(
                              child: Text(
                                'Submit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // 'Work Sans',
                                  fontSize: 18 * ffem,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1725 * ffem / fem,
                                  color: Color(0xffffffff),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // Navigator.push(
        //     //   context,
        //     //   PageTransition(type: PageTransitionType.rightToLeftWithFade, child: NewOpportunities()),
        //     // );
        //   },
        //   tooltip: "Create Opportunity",
        //   child: Container(
        //     child:const Icon(
        //       Icons.keyboard_voice,
        //       size: 40,
        //     ),
        //     height: double.infinity,
        //     width: double.infinity,
        //     decoration: const BoxDecoration(
        //         shape: BoxShape.circle,
        //         gradient: LinearGradient(
        //             begin: Alignment.topRight,
        //             end: Alignment.bottomRight,
        //             colors: <Color>[
        //               Color(0xFFFF6A92),
        //               Color(0xFFFF5C5D),
        //             ])),
        //     //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
        //   ),
        // ),
      ),
    );
  }
}
