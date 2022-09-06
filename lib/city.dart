/// 城市
class City implements Comparable<City> {
  /// 省
  String province;

  /// 市
  String name;

  /// 代码
  String id;

  City({
    required this.province,
    required this.name,
    required this.id,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      province: json["province"] as String,
      name: json["name"] as String,
      id: json["id"] as String,
    );
  }

  @override
  int compareTo(City other) => id.compareTo(other.id);

  @override
  String toString() {
    return "{\"province\":$province,\"name\":$name,\"id\":$id}";
  }
}
