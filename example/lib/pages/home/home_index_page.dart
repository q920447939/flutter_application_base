import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class HomeIndexPage extends StatefulWidget {
  const HomeIndexPage({super.key});

  @override
  State<HomeIndexPage> createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TDButton(
              onTap: () {
                context.push('/index2');
              },
              text: '去index2',
              size: TDButtonSize.large,
              type: TDButtonType.fill,
              shape: TDButtonShape.rectangle,
              theme: TDButtonTheme.primary,
            ),
            TDButton(
              onTap: () {
                context.push('/index3');
              },
              text: '去index3',
              size: TDButtonSize.large,
              type: TDButtonType.fill,
              shape: TDButtonShape.rectangle,
              theme: TDButtonTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInde2Page extends StatelessWidget {
  const HomeInde2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('index2'),
        actions: [
          //返回
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Center(child: TDText('HELLO WORLD2')),
    );
  }
}

class HomeInde3Page extends StatelessWidget {
  const HomeInde3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('index3'),
        actions: [
          //返回
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            TDButton(
              onTap: () {
                context.push('/');
              },
              text: '去首页',
              size: TDButtonSize.large,
              type: TDButtonType.fill,
              shape: TDButtonShape.rectangle,
              theme: TDButtonTheme.primary,
            ),
            TDButton(
              onTap: () {
                context.push('/index2');
              },
              text: '去index2',
              size: TDButtonSize.large,
              type: TDButtonType.fill,
              shape: TDButtonShape.rectangle,
              theme: TDButtonTheme.primary,
            ),
            TDButton(
              onTap: () {
                context.push('/index3');
              },
              text: '去index3',
              size: TDButtonSize.large,
              type: TDButtonType.fill,
              shape: TDButtonShape.rectangle,
              theme: TDButtonTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
