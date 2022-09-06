/// 城市-下属区
class Area implements Comparable<Area> {
  /// 市
  String city;

  /// 区
  String name;

  /// 代码
  String id;

  Area({
    required this.city,
    required this.name,
    required this.id,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      city: json["city"] as String,
      name: json["name"] as String,
      id: json["id"] as String,
    );
  }

  @override
  int compareTo(Area other) => id.compareTo(other.id);

  @override
  String toString() {
    return "{\"city\":$city,\"name\":$name,\"id\":$id}";
  }
}
