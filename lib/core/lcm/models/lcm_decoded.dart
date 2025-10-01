import 'dart:typed_data';

typedef LcmDecoder<T> = T Function(Uint8List bytes);

class LcmDecoded<T> {
  final String topic;
  final int utime;
  final Uint8List raw;
  final T value;

  const LcmDecoded({
    required this.topic,
    required this.utime,
    required this.raw,
    required this.value,
  });

  @override
  String toString() =>
      'LcmDecoded<$T>(topic: $topic, utime: $utime, value: $value)';
}
