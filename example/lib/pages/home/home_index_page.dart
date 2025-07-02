import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../test/captcha_test_page.dart';

List<CollapseDataItem> router_list = [
  CollapseDataItem(
    headerValue: 'go_route路由测试',
    items: [
      Item(title: '去index2', page: '/index2', targetPage: HomeInde2Page()),
      Item(title: '去index3', page: '/index3', targetPage: HomeInde3Page()),
    ],
  ),
  CollapseDataItem(
    headerValue: '用户认证',
    items: [
      Item(title: '验证码服务', page: '/captcha', targetPage: CaptchaTestPage()),
    ],
  ),
];

class HomeIndexPage extends StatefulWidget {
  const HomeIndexPage({super.key});

  @override
  State<HomeIndexPage> createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [_buildBasicCollapse(context)]));
  }

  Widget _buildBasicCollapse(BuildContext context) {
    return TDCollapse(
      style: TDCollapseStyle.block,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          router_list[index].isExpanded = !isExpanded;
        });
      },
      children:
          router_list.map((CollapseDataItem item) {
            return TDCollapsePanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Text(item.headerValue);
              },
              isExpanded: item.isExpanded,
              body: _buildItems(item.items),
            );
          }).toList(),
    );
  }

  Wrap _buildItems(List<Item> items) {
    return Wrap(
      children:
          items.map((e) {
            return Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: TDButton(
                text: e.title,
                size: TDButtonSize.large,
                type: TDButtonType.fill,
                shape: TDButtonShape.rectangle,
                theme: TDButtonTheme.primary,
                onTap: () {
                  context.push(e.page);
                },
              ),
            );
          }).toList(),
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

class CollapseDataItem {
  CollapseDataItem({
    required this.headerValue,
    required this.items,
    this.isExpanded = false,
  });

  final String headerValue;
  final List<Item> items;
  bool isExpanded;
}

class Item {
  final String title;
  final String page;
  final Widget targetPage;
  Item({required this.title, required this.page, required this.targetPage});
}
