import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

import 'package:dimipay_kiosk/app/services/auth/repository.dart';
import 'package:dimipay_kiosk/app/services/auth/model.dart';
import 'package:dimipay_kiosk/app/routes/routes.dart';

class AuthService extends GetxController {
  static AuthService get to => Get.find<AuthService>();

  final AuthRepository repository;
  final Rx<String?> _deviceName = Rx(null);
  final Rx<String?> _encryptionKey = Rx(null);
  final Rx<KeyPair> _rsaKey = Rx(KeyPair("", ""));
  final Rx<JWTToken> _jwtToken = Rx(JWTToken());
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService({AuthRepository? repository}) : repository = repository ?? AuthRepository();
  bool get isAuthenticated => _jwtToken.value.accessToken != null;
  String? get deviceName => _deviceName.value;
  String? get accessToken => _jwtToken.value.accessToken;

  Future<Uint8List?> get encryptionKey async {
    _rsaKey.value = await RSA.generate(2048);
    _rsaKey.value.publicKey = await RSA.convertPublicKeyToPKCS1(_rsaKey.value.publicKey);
    _rsaKey.value.privateKey = await RSA.convertPrivateKeyToPKCS8(_rsaKey.value.privateKey);
    _encryptionKey.value = await repository.authEncryptionKey(_rsaKey.value.publicKey.replaceAll('\n', '\\r\\n'));
    return await RSA.decryptOAEPBytes(base64.decode(_encryptionKey.value!), '', Hash.SHA1, _rsaKey.value.privateKey);
  }

  Future<AuthService> init() async {
    final String? refreshToken = await _storage.read(key: 'refreshToken');
    _deviceName.value = await _storage.read(key: 'deviceName');
    if (refreshToken == null || _deviceName.value == null) {
      return this;
    }

    try {
      _jwtToken.value = await repository.authRefresh(refreshToken);
    } catch (_) {
      await _storage.deleteAll();
    }
    return this;
  }

  Future<void> _storeLoginData(Login loginData) async {
    await _storage.write(key: "deviceName", value: loginData.name);
    await _storage.write(key: "refreshToken", value: loginData.tokens.refreshToken);
    _deviceName.value = loginData.name;
    _jwtToken.value = loginData.tokens;
  }

  Future<void> refreshAccessToken() async {
    _jwtToken.value = await repository.authRefresh(_jwtToken.value.refreshToken!);
  }

  Future<void> loginKiosk(String pin) async {
    try {
      await _storeLoginData(await repository.authLogin(pin));
      Get.offAndToNamed(Routes.ONBOARD);
    } catch (_) {
      return;
    }
  }
}