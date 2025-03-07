/// Represents a point on the face related to eye position.
///
/// Used for tracking eye movements during liveness detection.
class EyePoint {
  /// The x-coordinate of the eye point.
  final double x;

  /// The y-coordinate of the eye point.
  final double y;

  /// The type of eye point (e.g., 'left_eye', 'right_eye').
  final String type;

  /// Creates a new [EyePoint] instance.
  const EyePoint({
    required this.x, 
    required this.y, 
    required this.type
  });

  /// Creates a copy of this [EyePoint] with optional new values.
  EyePoint copyWith({
    double? x,
    double? y,
    String? type,
  }) {
    return EyePoint(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
    );
  }
} 