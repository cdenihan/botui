import 'dart:typed_data';

class LcmMessage {
  final String topic;

  final int utime;
  final Uint8List data;

  const LcmMessage({
    required this.topic,
    required this.utime,
    required this.data,
  });

  factory LcmMessage.fromMap(Map<dynamic, dynamic> m) {
    final topic = (m['topic'] ?? '') as String;
    final utime = (m['timestamp'] ?? 0) as int;
    final List<dynamic> raw = (m['data'] as List<dynamic>? ?? const []);
    return LcmMessage(
      topic: topic,
      utime: utime,
      data: Uint8List.fromList(raw.cast<int>()),
    );
  }

  @override
  String toString() => 'LcmMessage($topic, utime=$utime, ${data.length}B)';
}