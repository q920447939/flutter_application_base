/// 间距设计令牌
///
/// 定义应用中使用的所有间距值，包括：
/// - 基础间距单位
/// - 内边距
/// - 外边距
/// - 组件间距
/// - 布局间距
library;

import 'package:flutter/material.dart';

/// 应用间距系统
class AppSpacing {
  AppSpacing._();

  // ==================== 基础间距单位 ====================

  /// 基础间距单位 (4px)
  static const double unit = 4.0;

  /// 超小间距 (2px)
  static const double xs = unit * 0.5;

  /// 小间距 (4px)
  static const double sm = unit;

  /// 中等间距 (8px)
  static const double md = unit * 2;

  /// 大间距 (12px)
  static const double lg = unit * 3;

  /// 超大间距 (16px)
  static const double xl = unit * 4;

  /// 超超大间距 (20px)
  static const double xxl = unit * 5;

  /// 巨大间距 (24px)
  static const double xxxl = unit * 6;

  // ==================== 具体间距值 ====================

  /// 2px
  static const double space2 = 2.0;

  /// 4px
  static const double space4 = 4.0;

  /// 6px
  static const double space6 = 6.0;

  /// 8px
  static const double space8 = 8.0;

  /// 10px
  static const double space10 = 10.0;

  /// 12px
  static const double space12 = 12.0;

  /// 14px
  static const double space14 = 14.0;

  /// 16px
  static const double space16 = 16.0;

  /// 18px
  static const double space18 = 18.0;

  /// 20px
  static const double space20 = 20.0;

  /// 24px
  static const double space24 = 24.0;

  /// 28px
  static const double space28 = 28.0;

  /// 32px
  static const double space32 = 32.0;

  /// 36px
  static const double space36 = 36.0;

  /// 40px
  static const double space40 = 40.0;

  /// 48px
  static const double space48 = 48.0;

  /// 56px
  static const double space56 = 56.0;

  /// 64px
  static const double space64 = 64.0;

  /// 72px
  static const double space72 = 72.0;

  /// 80px
  static const double space80 = 80.0;

  /// 96px
  static const double space96 = 96.0;

  // ==================== 页面级间距 ====================

  /// 页面水平内边距
  static const double pageHorizontal = space16;

  /// 页面垂直内边距
  static const double pageVertical = space20;

  /// 页面顶部间距
  static const double pageTop = space24;

  /// 页面底部间距
  static const double pageBottom = space24;

  /// 安全区域间距
  static const double safeArea = space16;

  // ==================== 组件级间距 ====================

  /// 卡片内边距
  static const double cardPadding = space16;

  /// 卡片间距
  static const double cardMargin = space12;

  /// 列表项内边距
  static const double listItemPadding = space16;

  /// 列表项间距
  static const double listItemSpacing = space8;

  /// 按钮内边距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: space12,
  );

  /// 小按钮内边距
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space8,
  );

  /// 大按钮内边距
  static const EdgeInsets buttonLargePadding = EdgeInsets.symmetric(
    horizontal: space32,
    vertical: space16,
  );

  /// 输入框内边距
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  /// 对话框内边距
  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);

  /// 底部弹窗内边距
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(space16);

  // ==================== 布局间距 ====================

  /// 栅格间距
  static const double gridSpacing = space12;

  /// 栅格行间距
  static const double gridRowSpacing = space16;

  /// 栅格列间距
  static const double gridColumnSpacing = space12;

  /// 表单字段间距
  static const double formFieldSpacing = space16;

  /// 表单组间距
  static const double formGroupSpacing = space24;

  /// 节间距
  static const double sectionSpacing = space32;

  /// 内容块间距
  static const double contentBlockSpacing = space20;

  // ==================== 导航间距 ====================

  /// AppBar高度
  static const double appBarHeight = 56.0;

  /// TabBar高度
  static const double tabBarHeight = 48.0;

  /// BottomNavigationBar高度
  static const double bottomNavHeight = 56.0;

  /// Drawer宽度
  static const double drawerWidth = 280.0;

  /// 导航项内边距
  static const EdgeInsets navItemPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  // ==================== 图标间距 ====================

  /// 图标与文本间距
  static const double iconTextSpacing = space8;

  /// 图标按钮内边距
  static const EdgeInsets iconButtonPadding = EdgeInsets.all(space8);

  /// 小图标按钮内边距
  static const EdgeInsets iconButtonSmallPadding = EdgeInsets.all(space4);

  // ==================== 预定义EdgeInsets ====================

  /// 全部间距
  static const EdgeInsets all2 = EdgeInsets.all(space2);
  static const EdgeInsets all4 = EdgeInsets.all(space4);
  static const EdgeInsets all8 = EdgeInsets.all(space8);
  static const EdgeInsets all12 = EdgeInsets.all(space12);
  static const EdgeInsets all16 = EdgeInsets.all(space16);
  static const EdgeInsets all20 = EdgeInsets.all(space20);
  static const EdgeInsets all24 = EdgeInsets.all(space24);
  static const EdgeInsets all32 = EdgeInsets.all(space32);

  /// 水平间距
  static const EdgeInsets horizontal4 = EdgeInsets.symmetric(
    horizontal: space4,
  );
  static const EdgeInsets horizontal8 = EdgeInsets.symmetric(
    horizontal: space8,
  );
  static const EdgeInsets horizontal12 = EdgeInsets.symmetric(
    horizontal: space12,
  );
  static const EdgeInsets horizontal16 = EdgeInsets.symmetric(
    horizontal: space16,
  );
  static const EdgeInsets horizontal20 = EdgeInsets.symmetric(
    horizontal: space20,
  );
  static const EdgeInsets horizontal24 = EdgeInsets.symmetric(
    horizontal: space24,
  );

  /// 垂直间距
  static const EdgeInsets vertical4 = EdgeInsets.symmetric(vertical: space4);
  static const EdgeInsets vertical8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets vertical12 = EdgeInsets.symmetric(vertical: space12);
  static const EdgeInsets vertical16 = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets vertical20 = EdgeInsets.symmetric(vertical: space20);
  static const EdgeInsets vertical24 = EdgeInsets.symmetric(vertical: space24);

  /// 顶部间距
  static const EdgeInsets top4 = EdgeInsets.only(top: space4);
  static const EdgeInsets top8 = EdgeInsets.only(top: space8);
  static const EdgeInsets top12 = EdgeInsets.only(top: space12);
  static const EdgeInsets top16 = EdgeInsets.only(top: space16);
  static const EdgeInsets top20 = EdgeInsets.only(top: space20);
  static const EdgeInsets top24 = EdgeInsets.only(top: space24);

  /// 底部间距
  static const EdgeInsets bottom4 = EdgeInsets.only(bottom: space4);
  static const EdgeInsets bottom8 = EdgeInsets.only(bottom: space8);
  static const EdgeInsets bottom12 = EdgeInsets.only(bottom: space12);
  static const EdgeInsets bottom16 = EdgeInsets.only(bottom: space16);
  static const EdgeInsets bottom20 = EdgeInsets.only(bottom: space20);
  static const EdgeInsets bottom24 = EdgeInsets.only(bottom: space24);

  /// 左侧间距
  static const EdgeInsets left4 = EdgeInsets.only(left: space4);
  static const EdgeInsets left8 = EdgeInsets.only(left: space8);
  static const EdgeInsets left12 = EdgeInsets.only(left: space12);
  static const EdgeInsets left16 = EdgeInsets.only(left: space16);
  static const EdgeInsets left20 = EdgeInsets.only(left: space20);
  static const EdgeInsets left24 = EdgeInsets.only(left: space24);

  /// 右侧间距
  static const EdgeInsets right4 = EdgeInsets.only(right: space4);
  static const EdgeInsets right8 = EdgeInsets.only(right: space8);
  static const EdgeInsets right12 = EdgeInsets.only(right: space12);
  static const EdgeInsets right16 = EdgeInsets.only(right: space16);
  static const EdgeInsets right20 = EdgeInsets.only(right: space20);
  static const EdgeInsets right24 = EdgeInsets.only(right: space24);

  // ==================== SizedBox间距 ====================

  /// 垂直间距SizedBox
  static const Widget verticalSpace2 = SizedBox(height: space2);
  static const Widget verticalSpace4 = SizedBox(height: space4);
  static const Widget verticalSpace8 = SizedBox(height: space8);
  static const Widget verticalSpace12 = SizedBox(height: space12);
  static const Widget verticalSpace16 = SizedBox(height: space16);
  static const Widget verticalSpace20 = SizedBox(height: space20);
  static const Widget verticalSpace24 = SizedBox(height: space24);
  static const Widget verticalSpace32 = SizedBox(height: space32);
  static const Widget verticalSpace48 = SizedBox(height: space48);

  /// 水平间距SizedBox
  static const Widget horizontalSpace2 = SizedBox(width: space2);
  static const Widget horizontalSpace4 = SizedBox(width: space4);
  static const Widget horizontalSpace8 = SizedBox(width: space8);
  static const Widget horizontalSpace12 = SizedBox(width: space12);
  static const Widget horizontalSpace16 = SizedBox(width: space16);
  static const Widget horizontalSpace20 = SizedBox(width: space20);
  static const Widget horizontalSpace24 = SizedBox(width: space24);
  static const Widget horizontalSpace32 = SizedBox(width: space32);

  // ==================== 工具方法 ====================

  /// 创建自定义间距
  static EdgeInsets custom({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }

    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }

  /// 创建对称间距
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  /// 创建垂直间距Widget
  static Widget verticalSpace(double height) {
    return SizedBox(height: height);
  }

  /// 创建水平间距Widget
  static Widget horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度调整间距
    if (screenWidth < 360) {
      return baseSpacing * 0.8;
    } else if (screenWidth > 600) {
      return baseSpacing * 1.2;
    }

    return baseSpacing;
  }
}
