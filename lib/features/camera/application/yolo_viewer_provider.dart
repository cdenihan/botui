import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/lcm/models/lcm_decoded.dart';
import 'package:stpvelox/core/logging/logging.dart';
import 'package:stpvelox/lcm/types/yolo_frame_t.g.dart' as yolo;

part 'yolo_viewer_provider.g.dart';

const String kYoloFrameChannel = 'libstp/yolo/frame';

final _log = getLogger('YoloViewer');

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
    _log.info('YoloFrameStream build() called');
    ref.onDispose(_dispose);
    _startSubscription();
    return _currentFrame;
  }

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);
    _log.info('Starting subscription to channel: $kYoloFrameChannel');
    _log.info('LCM service initialized: ${lcm.isInitialized}');
    
    _subscription = lcm
        .subscribeAs<yolo.YoloFrameT>(kYoloFrameChannel, yolo.YoloFrameT.decode)
        .listen(
      (decoded) {
        _log.fine('Received YOLO frame: ${decoded.value.frame_width}x${decoded.value.frame_height}, ${decoded.value.num_boxes} boxes');
        _currentFrame = YoloFrame(decoded.value);
        state = _currentFrame;
      },
      onError: (error, stackTrace) {
        _log.severe('Error in YOLO frame subscription: $error', stackTrace);
      },
    );
    _log.info('Subscription created successfully');
  }

  void _dispose() {
    _log.info('Disposing YoloFrameStream subscription');
    _subscription?.cancel();
    _subscription = null;
  }
}
