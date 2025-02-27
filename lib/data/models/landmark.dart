class Landmark {
  final String type;
  final double x;
  final double y;

  Landmark({required this.type, required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
    };
  }
} 