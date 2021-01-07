import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../StringeeClient.dart';
import '../StringeeConstants.dart';

class StringeeCall2 {
  String _id;
  String _from;
  String _to;
  String _fromAlias;
  String _toAlias;
  StringeeCallType _callType;
  String _customDataFromYourServer;
  bool _isVideoCall = false;
  StreamController<dynamic> _eventStreamController = StreamController();
  StreamSubscription<dynamic> _subscriber;

  String get id => _id;

  String get from => _from;

  String get to => _to;

  String get fromAlias => _fromAlias;

  String get toAlias => _toAlias;

  bool get isVideoCall => _isVideoCall;

  StringeeCallType get callType => _callType;

  String get customDataFromYourServer => _customDataFromYourServer;

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  StringeeCall2() {
    _subscriber = StringeeClient().eventStreamController.stream.listen(this._listener);
  }

  StringeeCall2.fromCallInfo(Map<dynamic, dynamic> info) {
    this.initCallInfo(info);
    _subscriber = StringeeClient().eventStreamController.stream.listen(this._listener);
  }

  void initCallInfo(Map<dynamic, dynamic> callInfo) {
    if (callInfo == null) {
      return;
    }

    this._id = callInfo['callId'];
    this._from = callInfo['from'];
    this._to = callInfo['to'];
    this._fromAlias = callInfo['fromAlias'];
    this._toAlias = callInfo['toAlias'];
    this._isVideoCall = callInfo['isVideoCall'];
    this._customDataFromYourServer = callInfo['customDataFromYourServer'];
    this._callType = StringeeCallType.values[callInfo['callType']];
  }

  void _listener(dynamic event) {
    assert(event != null);
    final Map<dynamic, dynamic> map = event;
    if (map['typeEvent'] == StringeeType.StringeeCall2.index) {
      switch (map['event']) {
        case 'didChangeSignalingState':
          handleSignalingStateChange(map['body']);
          break;
        case 'didChangeMediaState':
          handleMediaStateChange(map['body']);
          break;
        case 'didReceiveCallInfo':
          handleCallInfoDidReceive(map['body']);
          break;
        case 'didHandleOnAnotherDevice':
          handleAnotherDeviceHadHandle(map['body']);
          break;
        case 'didReceiveLocalStream':
          handleReceiveLocalStream(map['body']);
          break;
        case 'didReceiveRemoteStream':
          handleReceiveRemoteStream(map['body']);
          break;
        case 'didChangeAudioDevice':
          handleChangeAudioDevice(map['body']);
          break;
      }
    } else {
      eventStreamController.add(event);
    }
  }

  void handleSignalingStateChange(Map<dynamic, dynamic> map) {
    String callId = map['callId'];
    if (callId != this._id) return;

    StringeeSignalingState signalingState = StringeeSignalingState.values[map['code']];
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidChangeSignalingState,
      "body": signalingState
    });
  }

  void handleMediaStateChange(Map<dynamic, dynamic> map) {
    String callId = map['callId'];
    if (callId != this._id) return;

    StringeeMediaState mediaState = StringeeMediaState.values[map['code']];
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidChangeMediaState,
      "body": mediaState
    });
  }

  void handleCallInfoDidReceive(Map<dynamic, dynamic> map) {
    String callId = map['callId'];
    if (callId != this._id) return;

    Map<dynamic, dynamic> data = map['info'];
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidReceiveCallInfo,
      "body": data
    });
  }

  void handleAnotherDeviceHadHandle(Map<dynamic, dynamic> map) {
    StringeeSignalingState signalingState = StringeeSignalingState.values[map['code']];
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidHandleOnAnotherDevice,
      "body": signalingState
    });
  }

  void handleReceiveLocalStream(Map<dynamic, dynamic> map) {
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidReceiveLocalStream,
      "body": map['callId']
    });
  }

  void handleReceiveRemoteStream(Map<dynamic, dynamic> map) {
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidReceiveRemoteStream,
      "body": map['callId']
    });
  }

  void handleChangeAudioDevice(Map<dynamic, dynamic> map) {
    AudioDevice selectedAudioDevice = AudioDevice.values[map['code']];
    List<dynamic> codeList = List();
    codeList.addAll(map['codeList']);
    List<AudioDevice> availableAudioDevices = List();
    for (int i = 0; i < codeList.length; i++) {
      AudioDevice audioDevice = AudioDevice.values[codeList[i]];
      availableAudioDevices.add(audioDevice);
    }
    _eventStreamController.add({
      "typeEvent": StringeeCall2Events,
      "eventType": StringeeCall2Events.DidChangeAudioDevice,
      "selectedAudioDevice": selectedAudioDevice,
      "availableAudioDevices": availableAudioDevices
    });
  }

  /// Make a new coll with custom [parameters]
  Future<Map<dynamic, dynamic>> makeCall(Map<dynamic, dynamic> parameters) async {
    if (parameters == null ||
        !parameters.containsKey('from') ||
        (parameters['from'] as String).trim().isEmpty ||
        !parameters.containsKey('to') ||
        (parameters['to'] as String).trim().isEmpty)
      return await reportInvalidValue('MakeCallParams');

    var params = {};

    params['from'] = (parameters['from'] as String).trim();
    params['to'] = (parameters['to'] as String).trim();
    if (parameters.containsKey('customData')) if (parameters['customData'] != null)
      params['customData'] = (parameters['customData'] as String).trim();
    if (parameters.containsKey('isVideoCall')) {
      params['isVideoCall'] =
          (parameters['isVideoCall'] != null) ? parameters['isVideoCall'] : false;
      if (params['isVideoCall']) {
        if (parameters['videoQuality'] != null) {
          switch (parameters['videoQuality']) {
            case VideoQuality.NORMAL:
              params['videoQuality'] = "NORMAL";
              break;
            case VideoQuality.HD:
              params['videoQuality'] = "HD";
              break;
            case VideoQuality.FULLHD:
              params['videoQuality'] = "FULLHD";
              break;
          }
        } else {
          params['videoQuality'] = "NORMAL";
        }
      }
    }

    Map<dynamic, dynamic> results =
        await StringeeClient.methodChannel.invokeMethod('makeCall2', params);
    Map<dynamic, dynamic> callInfo = results['callInfo'];
    this.initCallInfo(callInfo);

    final Map<String, dynamic> resultDatas = {
      'status': results['status'],
      'code': results['code'],
      'message': results['message']
    };
    return resultDatas;
  }

  /// Make a new coll with [MakeCallParams]
  Future<Map<dynamic, dynamic>> makeCallFromParams(MakeCallParams params) async {
    if (params == null) return await reportInvalidValue('MakeCallParams');
    Map<dynamic, dynamic> parameters = {
      'from': params.from.trim(),
      'to': params.to.trim(),
      if (params.customData != null) 'customData': params.customData,
      'isVideoCall': params.isVideoCall,
      if (params.isVideoCall) 'videoQuality': params.videoQuality,
    };
    return await makeCall(parameters);
  }

  /// Init an answer from incoming call
  Future<Map<dynamic, dynamic>> initAnswer() async {
    return await StringeeClient.methodChannel.invokeMethod('initAnswer2', this._id);
  }

  /// Answer a call
  Future<Map<dynamic, dynamic>> answer() async {
    return await StringeeClient.methodChannel.invokeMethod('answer2', this._id);
  }

  /// Hang up a call
  Future<Map<dynamic, dynamic>> hangup() async {
    return await StringeeClient.methodChannel.invokeMethod('hangup2', this._id);
  }

  /// Reject a call
  Future<Map<dynamic, dynamic>> reject() async {
    return await StringeeClient.methodChannel.invokeMethod('reject2', this._id);
  }

  /// Send a [dtmf]
  Future<Map<dynamic, dynamic>> sendDtmf(String dtmf) async {
    if (dtmf == null || dtmf.trim().isEmpty) return await reportInvalidValue('dtmf');
    final params = {
      'callId': this._id,
      'dtmf': dtmf.trim(),
    };
    return await StringeeClient.methodChannel.invokeMethod('sendDtmf2', params);
  }

  /// Send a call info
  Future<Map<dynamic, dynamic>> sendCallInfo(Map<dynamic, dynamic> callInfo) async {
    if (callInfo == null) return await reportInvalidValue('callInfo');
    final params = {
      'callId': this._id,
      'callInfo': callInfo,
    };
    return await StringeeClient.methodChannel.invokeMethod('sendCallInfo2', params);
  }

  /// Get call stats
  Future<Map<dynamic, dynamic>> getCallStats() async {
    return await StringeeClient.methodChannel.invokeMethod('getCallStats2', this._id);
  }

  /// Mute/Unmute
  Future<Map<dynamic, dynamic>> mute(bool mute) async {
    if (mute == null) return await reportInvalidValue('mute');
    final params = {
      'callId': this._id,
      'mute': mute,
    };
    return await StringeeClient.methodChannel.invokeMethod('mute2', params);
  }

  /// Enable/ Disable video
  Future<Map<dynamic, dynamic>> enableVideo(bool enableVideo) async {
    if (enableVideo == null) return await reportInvalidValue('enableVideo');
    final params = {
      'callId': this._id,
      'enableVideo': enableVideo,
    };
    return await StringeeClient.methodChannel.invokeMethod('enableVideo2', params);
  }

  /// Set speaker phone on/off
  Future<Map<dynamic, dynamic>> setSpeakerphoneOn(bool speakerPhoneOn) async {
    if (speakerPhoneOn == null) return await reportInvalidValue('speakerPhoneOn');
    final params = {
      'callId': this._id,
      'speaker': speakerPhoneOn,
    };
    return await StringeeClient.methodChannel.invokeMethod('setSpeakerphoneOn2', params);
  }

  /// Switch camera
  Future<Map<dynamic, dynamic>> switchCamera(bool isMirror) async {
    if (isMirror == null) return await reportInvalidValue('isMirror');
    final params = {
      'callId': this._id,
      'isMirror': isMirror,
    };
    return await StringeeClient.methodChannel.invokeMethod('switchCamera2', params);
  }

  /// Resume local video
  Future<Map<dynamic, dynamic>> resumeVideo() async {
    if (Platform.isIOS) {
      final params = {
        'status': false,
        "code": '-4',
        "message": "This function work only for Android",
      };
      return params;
    } else {
      final params = {
        'callId': this._id,
      };
      return await StringeeClient.methodChannel.invokeMethod('resumeVideo2', params);
    }
  }

  /// close event stream
  void destroy() {
    if (_subscriber != null) {
      _subscriber.cancel();
      _eventStreamController.close();
    }
  }
}
