class Pose {
  final double yaw;
  final double pitch;
  final double roll;

  Pose({required this.yaw, required this.pitch, required this.roll});

  Map<String, dynamic> toJson() {
    return {
      'yaw': yaw,
      'pitch': pitch,
      'roll': roll,
    };
  }
} 