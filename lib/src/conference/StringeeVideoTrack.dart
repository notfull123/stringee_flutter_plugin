import '../../stringee_flutter_plugin.dart';

class StringeeVideoTrack {
  late final String _id;
  late final StringeeRoomUser _publisher;
  late bool _audioEnable;
  late bool _videoEnable;
  late bool _isScreenCapture;
  late bool _isLocal;
  late final StringeeClient _client;

  String get id => _id;

  StringeeRoomUser get publisher => _publisher;

  bool get audioEnable => _audioEnable;

  bool get videoEnable => _videoEnable;

  bool get isScreenCapture => _isScreenCapture;

  bool get isLocal => _isLocal;

  @override
  String toString() {
    return '{id: $_id, publisher: $_publisher, audioEnable: $_audioEnable, videoEnable: $_videoEnable, isScreenCapture: $_isScreenCapture, isLocal: $_isLocal}';
  }

  StringeeVideoTrack(
    StringeeClient client,
    Map<dynamic, dynamic> info,
  ) {
    this._client = client;
    this._id = info['id'];
    this._audioEnable = info['audio'];
    this._videoEnable = info['video'];
    this._isScreenCapture = info['screen'];
    this._isLocal = info['isLocal'];
  }

  /// Mute
  Future<Map<dynamic, dynamic>> mute(bool mute) async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
      'mute': mute,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.mute', params);
  }

  /// Mute
  Future<Map<dynamic, dynamic>> enableVideo(bool enable) async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
      'enable': enable,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.enableVideo', params);
  }

  /// Mute
  Future<Map<dynamic, dynamic>> switchCamera() async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.switchCamera', params);
  }

  /// Mute
  Future<Map<dynamic, dynamic>> attach() async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.attach', params);
  }

  /// Mute
  Future<Map<dynamic, dynamic>> detach() async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.detach', params);
  }

  /// Mute
  Future<Map<dynamic, dynamic>> close() async {
    final params = {
      'trackId': _id,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('track.close', params);
  }
}
