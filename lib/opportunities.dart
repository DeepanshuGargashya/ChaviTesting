import 'dart:collection';

// import 'package:Credhub/Screens/Opportunities/create_opportunities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voice/create_opportunities.dart';
import 'package:page_transition/page_transition.dart';

import '../../constant.dart';
// import '../Profile/user_profile.dart';

class Opportunities extends StatefulWidget {
  final Map<String, dynamic> data;
  const Opportunities({Key? key, required this.data}) : super(key: key);

  @override
  State<Opportunities> createState() => _OpportunitiesState(data);
}

class _OpportunitiesState extends State<Opportunities>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = HashMap();
  _OpportunitiesState(this.data);
  late final AnimationController _animationController;
  late final Animation<double> _headerTextAnimation;
  late final Animation<double> _formElementAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(data);
    _animationController = AnimationController(
      vsync: this,
      duration: kLoginAnimationDuration,
    );

    final fadeSlideTween = Tween<double>(begin: 0.0, end: 1.0);
    _headerTextAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.6,
        curve: Curves.easeInOut,
      ),
    ));
    _formElementAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.7,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));
    _animationController.forward();
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
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Opportunities",
            style: TextStyle(
              // 'Work Sans',
              fontFamily: "ProductSansRegular",
              letterSpacing: 1,
              // fontSize: 12*ffem,
              fontWeight: FontWeight.w400,
              height: 1.1725 * ffem / fem,
              // color: Color(0xff959fba),
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFF6A92),
                    Color(0xFFFF5C5D),
                  ]),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: NewOpportunities()),
            );
          },
          tooltip: "Create Opportunity",
          child: Container(
            child: const Icon(
              Icons.add,
              size: 40,
            ),
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
            //child: Icon(Icons.menu, color: Colors.white), <-- You can give your icon here
          ),
        ),
      ),
    );
  }
}
