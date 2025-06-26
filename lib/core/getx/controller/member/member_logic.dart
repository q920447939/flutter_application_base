import 'dart:convert';

import 'package:flutter_application_base/core/app/framework_module_manager.dart';
import 'package:flutter_application_base/model/auth/MemberRespVO.dart';
import 'package:flutter_application_base/utils/str_json_translate.dart';
import 'package:get/get.dart';

class MemberLogic extends GetxController {
  //未登录可能为空
  final memberInfo = Rxn<MemberRespVo>();
  static const String _Key = 'member_key';

  @override
  void onInit() {
    super.onInit();
    loadSp();
  }

  Future<void> loadSp() async {
    final spValue = SP.getString(_Key);
    if (null != spValue) {
      memberInfo.value = jsonStrToObj(spValue, MemberRespVo.fromJson);
    }
  }

  Future<void> updateMemberInfo(MemberRespVo newInfo) async {
    memberInfo.value = newInfo;
    await saveSp();
  }

  saveSp() async {
    await SP.setString(_Key, objToJsonStr(memberInfo.value));
  }

  MemberRespVo? get() {
    return memberInfo.value;
  }

  Future<void> clean() async {
    memberInfo.value = null;
    await SP.remove('token');
    await SP.remove('isLogin');
    await SP.remove(_Key);
  }
}
