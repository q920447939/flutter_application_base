/// 动态WebView页面组件
library;

import 'package:flutter/material.dart';
import '../../core/router/models/route_config.dart';

/// 动态WebView页面
class DynamicWebViewPage extends StatefulWidget {
  final String title;
  final WebViewConfig webView;
  final Map<String, dynamic>? arguments;

  const DynamicWebViewPage({
    super.key,
    required this.title,
    required this.webView,
    this.arguments,
  });

  @override
  State<DynamicWebViewPage> createState() => _DynamicWebViewPageState();
}

class _DynamicWebViewPageState extends State<DynamicWebViewPage> {
  bool _isLoading = true;
  String? _error;
  late String _url;

  @override
  void initState() {
    super.initState();
    _initializeUrl();
  }

  void _initializeUrl() {
    _url = widget.webView.url;
    
    // 如果URL包含参数占位符，则替换为实际参数值
    if (widget.arguments != null) {
      widget.arguments!.forEach((key, value) {
        _url = _url.replaceAll('{$key}', value.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.webView.showNavigationBar
          ? AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: _openInBrowser,
                ),
              ],
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 这里应该使用webview_flutter包来显示WebView
        // 由于示例中没有添加该依赖，这里用一个占位符
        _buildWebViewPlaceholder(),
        
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildWebViewPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.web, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'WebView 占位符',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'URL: $_url',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '要使用真实的WebView，请添加webview_flutter依赖',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _openInBrowser,
            child: const Text('在浏览器中打开'),
          ),
        ],
      ),
    );
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // 模拟加载完成
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _openInBrowser() {
    // 这里应该使用url_launcher包来打开外部浏览器
    // 由于示例中没有添加该依赖，这里只是显示一个提示
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('打开外部浏览器'),
        content: Text('将在外部浏览器中打开:\n$_url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 这里应该调用 url_launcher 来打开URL
              // await launchUrl(Uri.parse(_url));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/*
要使用真实的WebView功能，需要：

1. 在pubspec.yaml中添加依赖：
dependencies:
  webview_flutter: ^4.4.2
  url_launcher: ^6.2.1

2. 替换_buildWebViewPlaceholder()方法：

Widget _buildWebView() {
  return WebView(
    initialUrl: _url,
    javascriptMode: widget.webView.javascriptEnabled 
        ? JavascriptMode.unrestricted 
        : JavascriptMode.disabled,
    userAgent: widget.webView.userAgent,
    onWebViewCreated: (WebViewController webViewController) {
      // WebView创建完成
    },
    onPageStarted: (String url) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    },
    onPageFinished: (String url) {
      setState(() {
        _isLoading = false;
      });
    },
    onWebResourceError: (WebResourceError error) {
      setState(() {
        _isLoading = false;
        _error = '加载失败: ${error.description}';
      });
    },
  );
}

3. 在_openInBrowser()方法中使用url_launcher：

Future<void> _openInBrowser() async {
  final uri = Uri.parse(_url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开链接')),
      );
    }
  }
}
*/
