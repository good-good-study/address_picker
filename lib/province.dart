/// 省/直辖市、特别行政区）
class Province implements Comparable<Province> {
  /// 名称
  String name;

  /// 代码
  String id;

  Province({
    required this.name,
    required this.id,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json["name"].toString(),
      id: json["id"].toString(),
    );
  }

  @override
  int compareTo(Province other) => id.compareTo(other.id);

  @override
  String toString() {
    return "{\"name\":$name,\"id\":$id}";
  }
}
