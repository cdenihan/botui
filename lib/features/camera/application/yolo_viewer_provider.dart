import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/lcm/types/yolo_frame_t.g.dart' as yolo;

part 'yolo_viewer_provider.g.dart';

const String kYoloFrameChannel = 'libstp/yolo/frame';

/// Wrapper class for YOLO frame data
class YoloFrame {
  final yolo.YoloFrameT data;
  
  YoloFrame(this.data);
}

/// Provider that streams YOLO detection frames from LCM
@riverpod
class YoloFrameStream extends _$YoloFrameStream {
  StreamSubscription<LcmDecoded<yolo.YoloFrameT>>? _subscription;
  YoloFrame? _currentFrame;

  @override
  YoloFrame? build() {
    ref.onDispose(_dispose);
    _startSubscription();
    return _currentFrame;
  }

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);
    _subscription = lcm
        .subscribeAs<yolo.YoloFrameT>(kYoloFrameChannel, yolo.YoloFrameT.decode)
        .listen(
      (decoded) {
        _currentFrame = YoloFrame(decoded.value);
        state = _currentFrame;
      },
      onError: (error) {
        print('Error in YOLO frame subscription: $error');
      },
    );
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
