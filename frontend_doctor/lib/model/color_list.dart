import 'package:flutter/material.dart';

enum ColorType {
  red(num: 0, color: Colors.red),
  orange(num: 1, color: Colors.orange),
  yellow(num: 2, color: Colors.yellow),
  green(num: 3, color: Colors.green),
  blue(num: 4, color: Colors.blue),
  purple(num: 5, color: Colors.purple),
  brown(num: 6, color: Colors.brown),

  grey(num: 7, color: Colors.grey);

  final int num;
  final Color color;

  const ColorType({required this.num, required this.color});

  factory ColorType.getByCode(int code){
    return ColorType.values.firstWhere((value) => value.num == code);
  }

}