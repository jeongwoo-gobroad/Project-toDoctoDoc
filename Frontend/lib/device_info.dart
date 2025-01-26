import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future<String> initPlatformState() async {
  var deviceID = 'null';

  var deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    var webInfo = await deviceInfo.webBrowserInfo;
    deviceID = webInfo.vendor! +
        webInfo.userAgent! +
        webInfo.hardwareConcurrency.toString();
  }
  else {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceID = androidInfo.id!;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceID = iosInfo.identifierForVendor!;
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceID = linuxInfo.machineId!;
    }
  }

  print("DEVICE ID --------- $deviceID");
  return deviceID;
}
