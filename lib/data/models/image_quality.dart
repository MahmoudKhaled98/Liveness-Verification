class ImageQuality {
  final double brightness;
  final double sharpness;

  ImageQuality({required this.brightness, required this.sharpness});

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'sharpness': sharpness,
    };
  }
} 