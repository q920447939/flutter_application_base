/// 框架模块管理器
///
/// 负责管理所有框架模块的生命周期，包括：
/// - 模块注册
/// - 依赖解析
/// - 初始化顺序管理
/// - 健康检查
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_base/core/app/app_init_info.dart';
import 'package:flutter_application_base/core/router/app_route_manager.dart';
import 'framework_module.dart';
import '../modules/module_registry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tdesign_flutter/src/util/log.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 框架模块管理器
class FrameworkModuleManager {
  static final Map<String, ModuleRuntimeInfo> _modules = {};
  static bool _initialized = false;

  /// 注册模块
  static void registerModule(FrameworkModule module) {
    if (_initialized) {
      debugPrint('警告: 模块管理器已初始化，无法注册新模块: ${module.name}');
      return;
    }

    if (_modules.containsKey(module.name)) {
      debugPrint('警告: 模块 ${module.name} 已存在，将被覆盖');
    }

    _modules[module.name] = ModuleRuntimeInfo(module: module);
    debugPrint('模块已注册: ${module.name}');
  }

  /// 批量注册模块
  static void registerModules(List<FrameworkModule> modules) {
    for (final module in modules) {
      registerModule(module);
    }
  }

  /// 初始化所有模块
  static Future<void> initialize(AppInitInfo initInfo) async {
    // 确保Flutter绑定初始化
    WidgetsFlutterBinding.ensureInitialized();
    await ScreenUtil.ensureScreenSize();
    await EasyLocalization.ensureInitialized();
    Log.setCustomLogPrinter(
      (level, tag, msg) => print('[$level] $tag ==> $msg'),
    );

    try {
      debugPrint('开始初始化框架模块...');

      // 初始化路由管理器
      await AppRouteManager.instance.initialize(
        routes: [],
        routeGroups: [],
        validateRoutes: true,
      );

      // 自动注册内置模块
      await _registerBuiltinModules();

      // 验证依赖关系
      /*       final dependencyValidation = _validateDependencies();
      if (!dependencyValidation.isValid) {
        throw Exception('模块依赖验证失败: ${dependencyValidation.errors.join(', ')}');
      } */

      // 按依赖关系和优先级排序
      final sortedModules = _sortModulesByDependency();

      // 初始化模块
      final results = <ModuleInitializationResult>[];
      for (final moduleInfo in sortedModules) {
        if (!moduleInfo.module.enabled) {
          debugPrint('跳过已禁用的模块: ${moduleInfo.module.name}');
          continue;
        }

        final result = await _initializeModule(moduleInfo);
        results.add(result);

        if (!result.success) {
          debugPrint('模块初始化失败: ${result.moduleName}, 错误: ${result.error}');
          // 根据配置决定是否继续初始化其他模块
        }
      }

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      Widget child = EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('zh')],
        path: 'assets/translations',
        fallbackLocale: Locale('zh'),
        startLocale: Locale('zh'),
        saveLocale: true,
        useOnlyLangCode: true, // <-- change the path of the translation files
        child: initInfo.child,
      );
      /* if (initInfo.openDevicePreview) {
        child = DevicePreview(enabled: true, builder: (context) => child);
      } */
      if (initInfo.screenRatio.aspectRatio > -1) {
        child = AspectRatio(
          aspectRatio: initInfo.screenRatio.aspectRatio,
          child: child,
        );
      }
      //强制竖屏
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then((_) => runApp(SafeArea(child: child)));
    } catch (e) {
      debugPrint('框架模块初始化失败: $e');
      rethrow;
    } finally {}
  }

  /// 自动注册内置模块
  static Future<void> _registerBuiltinModules() async {
    // 这里会自动发现和注册内置模块
    debugPrint('自动注册内置模块...');

    // 使用模块注册器注册核心模块
    ModuleRegistry.registerCoreModules();
  }

  /// 验证模块依赖关系
  static DependencyValidationResult _validateDependencies() {
    final errors = <String>[];

    for (final moduleInfo in _modules.values) {
      final module = moduleInfo.module;

      // 检查依赖的模块是否存在
      for (final dependency in module.dependencies) {
        if (!_modules.containsKey(dependency)) {
          errors.add('模块 ${module.name} 依赖的模块 $dependency 不存在');
        }
      }
    }

    // 检查循环依赖
    final circularDependencies = _detectCircularDependencies();
    if (circularDependencies.isNotEmpty) {
      errors.add('检测到循环依赖: ${circularDependencies.join(' -> ')}');
    }

    return DependencyValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// 检测循环依赖
  static List<String> _detectCircularDependencies() {
    // 使用深度优先搜索检测循环依赖
    final visited = <String>{};
    final recursionStack = <String>{};

    for (final moduleName in _modules.keys) {
      if (_hasCycleDFS(moduleName, visited, recursionStack)) {
        return recursionStack.toList();
      }
    }

    return [];
  }

  /// 深度优先搜索检测循环依赖
  static bool _hasCycleDFS(
    String moduleName,
    Set<String> visited,
    Set<String> recursionStack,
  ) {
    if (recursionStack.contains(moduleName)) {
      return true;
    }

    if (visited.contains(moduleName)) {
      return false;
    }

    visited.add(moduleName);
    recursionStack.add(moduleName);

    final module = _modules[moduleName]?.module;
    if (module != null) {
      for (final dependency in module.dependencies) {
        if (_hasCycleDFS(dependency, visited, recursionStack)) {
          return true;
        }
      }
    }

    recursionStack.remove(moduleName);
    return false;
  }

  /// 按依赖关系和优先级排序模块
  static List<ModuleRuntimeInfo> _sortModulesByDependency() {
    final sorted = <ModuleRuntimeInfo>[];
    final visited = <String>{};

    void visit(String moduleName) {
      if (visited.contains(moduleName)) return;

      final moduleInfo = _modules[moduleName];
      if (moduleInfo == null) return;

      visited.add(moduleName);

      // 先访问依赖的模块
      for (final dependency in moduleInfo.module.dependencies) {
        visit(dependency);
      }

      sorted.add(moduleInfo);
    }

    // 按优先级排序模块名称
    final moduleNames =
        _modules.keys.toList()..sort((a, b) {
          final moduleA = _modules[a]!.module;
          final moduleB = _modules[b]!.module;
          return moduleA.priority.compareTo(moduleB.priority);
        });

    // 访问所有模块
    for (final moduleName in moduleNames) {
      visit(moduleName);
    }

    return sorted;
  }

  /// 初始化单个模块
  static Future<ModuleInitializationResult> _initializeModule(
    ModuleRuntimeInfo moduleInfo,
  ) async {
    final module = moduleInfo.module;
    final startTime = DateTime.now();

    try {
      debugPrint('初始化模块: ${module.name}');
      moduleInfo.status = ModuleStatus.initializing;

      await module.initialize();

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      moduleInfo.status = ModuleStatus.initialized;
      final result = ModuleInitializationResult.success(
        moduleName: module.name,
        duration: duration,
      );

      moduleInfo.initializationResult = result;
      debugPrint('模块 ${module.name} 初始化成功，耗时: ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      moduleInfo.status = ModuleStatus.failed;
      final result = ModuleInitializationResult.failure(
        moduleName: module.name,
        duration: duration,
        error: e.toString(),
      );

      moduleInfo.initializationResult = result;
      debugPrint('模块 ${module.name} 初始化失败: $e');

      return result;
    }
  }

  /// 打印初始化摘要
  static void _printInitializationSummary(
    List<ModuleInitializationResult> results,
  ) {
    final successful = results.where((r) => r.success).length;
    final failed = results.where((r) => !r.success).length;

    debugPrint('=== 模块初始化摘要 ===');
    debugPrint('总模块数: ${results.length}');
    debugPrint('成功: $successful');
    debugPrint('失败: $failed');

    if (failed > 0) {
      debugPrint('失败的模块:');
      for (final result in results.where((r) => !r.success)) {
        debugPrint('  - ${result.moduleName}: ${result.error}');
      }
    }
  }

  /// 获取所有模块信息
  static Map<String, ModuleRuntimeInfo> getAllModules() {
    return Map.unmodifiable(_modules);
  }

  /// 获取模块信息
  static ModuleRuntimeInfo? getModule(String name) {
    return _modules[name];
  }

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;

  /// 销毁所有模块
  static Future<void> disposeAll() async {
    if (!_initialized) return;

    debugPrint('开始销毁所有模块...');

    // 按相反顺序销毁模块
    final sortedModules = _sortModulesByDependency().reversed.toList();

    for (final moduleInfo in sortedModules) {
      try {
        await moduleInfo.module.dispose();
        moduleInfo.status = ModuleStatus.disposed;
        debugPrint('模块 ${moduleInfo.module.name} 已销毁');
      } catch (e) {
        debugPrint('模块 ${moduleInfo.module.name} 销毁失败: $e');
      }
    }

    _modules.clear();
    _initialized = false;
    debugPrint('所有模块已销毁');
  }
}

/// 依赖验证结果
class DependencyValidationResult {
  final bool isValid;
  final List<String> errors;

  const DependencyValidationResult({
    required this.isValid,
    required this.errors,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? locale = const Locale('zh');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final initSmartDialog = FlutterSmartDialog.init();
    /* double width = ServerConfig().width.toDouble();
    double height = ServerConfig().height.toDouble();
    //填入设计稿中设备的屏幕尺寸,单位dp
    return ScreenUtilInit(
      designSize: Size(width, height),
      builder: (context, child) {
        // 设置文案代理,国际化需要在MaterialApp初始化完成之后才生效,而且需要每次更新context
        /* TDTheme.setResourceBuilder((context) => delegate..updateContext(context),
          needAlwaysBuild: true);*/
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: MaterialApp.router(
            /* supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,*/
            locale: locale,
            debugShowCheckedModeBanner: false,
            title: ServerConfig().appName,
            theme: ThemeData(
              extensions: [themeData],
              colorScheme: ColorScheme.light(
                primary: themeData.brandNormalColor,
              ),
            ),
            routerConfig: router,
            builder: initSmartDialog,
          ),
        );
      },
    ); */
    return Container();
  }
}
