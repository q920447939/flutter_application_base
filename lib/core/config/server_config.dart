import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerConfig {
  String _host = dotenv.env['SERVER_HOST']!;
  String _port = dotenv.env['SERVER_PORT']!;

  bool _isDebug = bool.parse(dotenv.env['IS_DEBUG']!);
  String _appName = dotenv.env['APP_NAME']!;

  String get tenantId => dotenv.env['TENANT_ID']!;
  String get version => dotenv.env['V']!;
  String get _debugProxy => dotenv.env['DEBUG_PROXY']!;

  //允许支持的平台
  List<String> get allowPlatform {
    return dotenv.env['ALLOW_PLATFORMS']!.split(';');
  }

  String get host => _host;

  String get port => _port;

  bool get isDebug => _isDebug;

  String get appName => _appName;
  String get debugProxy => _debugProxy;

  int get width => int.parse(dotenv.env['SCREEN_WIDTH']!);
  int get height => int.parse(dotenv.env['SCREEN_HEIGHT']!);
}
