import 'package:flutter_application_base/core/app/framework_module_manager.dart';

bool isLogin() {
  /*var isLogin = SP.getBool('isLogin');
  return null != isLogin && isLogin == true;*/
  return true;
}

saveToken(token) async {
  await SP.setString('token', token);
  await SP.setBool('isLogin', true);
}

//TODO
bool _isFirstUse = false;
isFirstUse() {
  return _isFirstUse;
}

updateFirstUse() {
  _isFirstUse = false;
}
