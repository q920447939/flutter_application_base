import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/config/server_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeIndexPage extends StatefulWidget {
  const HomeIndexPage({super.key});

  @override
  State<HomeIndexPage> createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.withOpacity(0.2)],
            ),
          ),
        ),
        //加载assess 图片
        Image.asset(
          "assets/img/home_backaground.jpg",
          fit: BoxFit.cover,
          height: ServerConfig().height.toDouble() * 0.275,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [],
          ),
        ),
      ],
    );
  }
}
