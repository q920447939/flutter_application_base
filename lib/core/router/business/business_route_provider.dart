/// 业务路由提供者接口
/// 
/// 定义业务模块路由扩展的标准接口
library;

import 'package:go_router/go_router.dart';
import '../base/route_registrar.dart';

/// 业务路由提供者抽象接口
abstract class BusinessRouteProvider {
  /// 业务名称
  String get businessName;
  
  /// 业务版本
  String get version => '1.0.0';
  
  /// 业务描述
  String get description => '';
  
  /// 提供路由列表
  List<RouteBase> provideRoutes();
  
  /// 获取路由元数据
  Map<String, dynamic> getRouteMetadata() {
    return {
      'businessName': businessName,
      'version': version,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// 验证业务路由
  bool validateBusinessRoutes() {
    try {
      final routes = provideRoutes();
      return routes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// 业务路由注册器
class BusinessRouteRegistrar extends MetadataRouteRegistrar {
  final BusinessRouteProvider _provider;
  final String _namespace;
  final List<String> _dependencies;
  
  BusinessRouteRegistrar({
    required BusinessRouteProvider provider,
    String? namespace,
    List<String> dependencies = const [],
  }) : _provider = provider,
       _namespace = namespace ?? 'business-${provider.businessName}',
       _dependencies = dependencies;
  
  @override
  String get namespace => _namespace;
  
  @override
  RouteLayer get layer => RouteLayer.business;
  
  @override
  List<String> get dependencies => _dependencies;
  
  @override
  RouteMetadata getMetadata() {
    return RouteMetadata(
      name: _provider.businessName,
      description: _provider.description,
      version: _provider.version,
      extra: _provider.getRouteMetadata(),
    );
  }
  
  @override
  List<RouteBase> getRoutes() {
    return _provider.provideRoutes();
  }
  
  @override
  bool validateRoutes() {
    return super.validateRoutes() && _provider.validateBusinessRoutes();
  }
}

/// 电商业务路由提供者示例
class ECommerceRouteProvider implements BusinessRouteProvider {
  @override
  String get businessName => 'ecommerce';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => '电商业务模块路由';
  
  @override
  List<RouteBase> provideRoutes() {
    return [
      // 商品相关路由
      GoRoute(
        path: '/shop',
        name: 'shop-home',
        builder: (context, state) => const ShopHomePage(),
        routes: [
          GoRoute(
            path: 'products',
            name: 'shop-products',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProductListPage(category: category);
            },
          ),
          GoRoute(
            path: 'products/:id',
            name: 'shop-product-detail',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetailPage(productId: productId);
            },
          ),
          GoRoute(
            path: 'cart',
            name: 'shop-cart',
            builder: (context, state) => const ShoppingCartPage(),
          ),
          GoRoute(
            path: 'checkout',
            name: 'shop-checkout',
            builder: (context, state) => const CheckoutPage(),
          ),
        ],
      ),
      
      // 订单相关路由
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderListPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'order-detail',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderDetailPage(orderId: orderId);
            },
          ),
        ],
      ),
    ];
  }
}

/// 示例页面组件
class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商城首页')),
      body: const Center(child: Text('商城首页内容')),
    );
  }
}

class ProductListPage extends StatelessWidget {
  final String? category;
  
  const ProductListPage({super.key, this.category});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('商品列表${category != null ? ' - $category' : ''}')),
      body: const Center(child: Text('商品列表')),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final String productId;
  
  const ProductDetailPage({super.key, required this.productId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: Center(child: Text('商品详情 - ID: $productId')),
    );
  }
}

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: const Center(child: Text('购物车内容')),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('结算')),
      body: const Center(child: Text('结算页面')),
    );
  }
}

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单列表')),
      body: const Center(child: Text('订单列表')),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  
  const OrderDetailPage({super.key, required this.orderId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情')),
      body: Center(child: Text('订单详情 - ID: $orderId')),
    );
  }
}
