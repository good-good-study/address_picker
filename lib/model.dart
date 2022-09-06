import 'dart:convert';

import 'package:flutter/services.dart';

import 'area.dart';
import 'city.dart';
import 'province.dart';
import 'street.dart';

typedef Transform<T> = T Function(Map<String, dynamic> json);

const name = 'packages/address_picker';

///将[dynamic]转换成指定对象[T]
Future<T> transform<T>({
  Map<String, dynamic>? json,
  required Transform<T> transform,
}) async {
  return transform(json ?? <String, dynamic>{});
}

///将[Map]<[String],[dynamic]>转换成指定类型的数组[List]<[T]>
Future<List<T>> transformList<T>({
  List<dynamic>? json,
  required Transform<T> transform,
}) async {
  return (json ?? <T>[]).map((json) => transform(json)).toList();
}

/// 获取省份列表
Future<List<Province>?> loadProvinces() async {
  var json = await rootBundle.loadString('$name/json/province.json');
  var provinces = await transformList(
    json: jsonDecode(json),
    transform: (json) => Province.fromJson(json),
  );
  return provinces;
}

/// 获取城市列表
Future<List<City>?> loadCities(String provinceId) async {
  var json = await rootBundle.loadString('$name/json/city.json');
  var map = jsonDecode(json);
  return await transformList(
    json: map[provinceId],
    transform: (json) => City.fromJson(json),
  );
}

/// 获取区列表
Future<List<Area>?> loadAreas(String cityId) async {
  var json = await rootBundle.loadString('$name/json/area.json');
  var map = jsonDecode(json);
  return await transformList(
    json: map[cityId],
    transform: (json) => Area.fromJson(json),
  );
}

/// 获取街道列表
Future<List<Street>?> loadStreets(String areaId) async {
  var json = await rootBundle.loadString('$name/json/street.json');
  var map = jsonDecode(json);
  return await transformList(
    json: map[areaId],
    transform: (json) => Street.fromJson(json),
  );
}
