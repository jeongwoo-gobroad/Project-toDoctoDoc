import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';


Future<String?> initPlatformState() async {
  String? deviceID = 'null';


  if (kIsWeb) {
    return null;
  }
  else {
    var UUID = await MobileDeviceIdentifier().getDeviceId();
    if (UUID == null){
      print('DEVICE GET ERROR');
      return null;
    }
    deviceID = UUID;
  }

  print("DEVICE ID --------- $deviceID");
  return deviceID;
}
