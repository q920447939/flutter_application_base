@echo off
chcp 65001 >nul

echo 🚀 启动声明式权限配置演示应用...

REM 检查Flutter是否安装
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter未安装，请先安装Flutter
    echo 📖 安装指南: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM 检查Flutter版本
echo 📋 检查Flutter版本...
flutter --version

REM 安装依赖
echo 📦 安装依赖...
flutter pub get

REM 检查设备
echo 📱 检查可用设备...
flutter devices

REM 运行应用
echo 🎯 启动应用...
echo 💡 提示: 启动后点击'声明式权限配置'按钮体验功能
flutter run

echo ✅ 应用已启动完成！
pause
