class CustomLandmark {
  final String type;
  final double x;
  final double y;

  CustomLandmark({required this.type, required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
    };
  }
} 