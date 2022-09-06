/// 城市-街道
class Street implements Comparable<Street> {
  /// 区
  String area;

  /// 街道
  String name;

  /// 代码
  String id;

  Street({
    required this.area,
    required this.name,
    required this.id,
  });

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(
      area: json["city"] as String,
      name: json["name"] as String,
      id: json["id"] as String,
    );
  }

  @override
  int compareTo(Street other) => id.compareTo(other.id);

  @override
  String toString() {
    return "{\"area\":$area,\"name\":$name,\"id\":$id}";
  }
}
