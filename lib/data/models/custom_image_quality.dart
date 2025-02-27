class CustomImageQuality {
  final double brightness;
  final double sharpness;

  CustomImageQuality({required this.brightness, required this.sharpness});

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'sharpness': sharpness,
    };
  }
} 