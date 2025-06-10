#!/bin/bash

# 声明式权限配置演示应用启动脚本

echo "🚀 启动声明式权限配置演示应用..."

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter"
    echo "📖 安装指南: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 检查Flutter版本
echo "📋 检查Flutter版本..."
flutter --version

# 安装依赖
echo "📦 安装依赖..."
flutter pub get

# 检查设备
echo "📱 检查可用设备..."
flutter devices

# 运行应用
echo "🎯 启动应用..."
echo "💡 提示: 启动后点击'声明式权限配置'按钮体验功能"
flutter run

echo "✅ 应用已启动完成！"
