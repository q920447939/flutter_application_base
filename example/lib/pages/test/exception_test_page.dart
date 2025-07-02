import 'dart:async';
import 'package:flutter/material.dart';

/// 异常测试页面
/// 用于测试不同类型的异常处理机制
class ExceptionTestPage extends StatefulWidget {
  const ExceptionTestPage({super.key});

  @override
  State<ExceptionTestPage> createState() => _ExceptionTestPageState();
}

class _ExceptionTestPageState extends State<ExceptionTestPage> {
  String _lastError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('异常测试'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '测试不同类型的异常处理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 异步异常测试
            ElevatedButton(
              onPressed: _testAsyncException,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('测试异步异常 (runZonedGuarded)'),
            ),
            const SizedBox(height: 10),
            
            // Flutter 框架异常测试
            ElevatedButton(
              onPressed: _testFlutterException,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('测试Flutter框架异常 (FlutterError.onError)'),
            ),
            const SizedBox(height: 10),
            
            // 同步异常测试
            ElevatedButton(
              onPressed: _testSyncException,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('测试同步异常 (try-catch)'),
            ),
            const SizedBox(height: 10),
            
            // Future 异常测试
            ElevatedButton(
              onPressed: _testFutureException,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('测试Future异常'),
            ),
            const SizedBox(height: 10),
            
            // Timer 异常测试
            ElevatedButton(
              onPressed: _testTimerException,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('测试Timer异常'),
            ),
            const SizedBox(height: 20),
            
            const Text(
              '最后一次错误:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _lastError.isEmpty ? '暂无错误' : _lastError,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              '说明:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• 异步异常: 会被 runZonedGuarded 捕获\n'
              '• Flutter框架异常: 会被 FlutterError.onError 捕获\n'
              '• 同步异常: 需要 try-catch 处理\n'
              '• Future异常: 未处理的会被 runZonedGuarded 捕获\n'
              '• Timer异常: 会被 runZonedGuarded 捕获',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 测试异步异常 - 会被 runZonedGuarded 捕获
  void _testAsyncException() {
    print('触发异步异常测试...');
    Future.delayed(const Duration(milliseconds: 100), () {
      throw Exception('这是一个测试异步异常');
    });
  }

  /// 测试 Flutter 框架异常 - 会被 FlutterError.onError 捕获
  void _testFlutterException() {
    print('触发Flutter框架异常测试...');
    setState(() {
      // 这会导致 Widget 构建异常
      throw FlutterError('这是一个测试Flutter框架异常');
    });
  }

  /// 测试同步异常 - 需要 try-catch 处理
  void _testSyncException() {
    print('触发同步异常测试...');
    try {
      throw Exception('这是一个测试同步异常');
    } catch (e, stack) {
      setState(() {
        _lastError = '同步异常被捕获: $e';
      });
      print('同步异常被本地捕获: $e\n$stack');
    }
  }

  /// 测试 Future 异常
  void _testFutureException() {
    print('触发Future异常测试...');
    // 创建一个未处理的 Future 异常
    Future(() {
      throw Exception('这是一个测试Future异常');
    });
  }

  /// 测试 Timer 异常
  void _testTimerException() {
    print('触发Timer异常测试...');
    Timer(const Duration(milliseconds: 100), () {
      throw Exception('这是一个测试Timer异常');
    });
  }
}
