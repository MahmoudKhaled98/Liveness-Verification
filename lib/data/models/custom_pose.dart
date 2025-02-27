class CustomPose {
  final double yaw;
  final double pitch;
  final double roll;

  CustomPose({required this.yaw, required this.pitch, required this.roll});

  Map<String, dynamic> toJson() {
    return {
      'yaw': yaw,
      'pitch': pitch,
      'roll': roll,
    };
  }
} 