import 'dart:async';

import 'package:colorify/backend/extensions/on_datetime.dart';
import 'package:colorify/backend/utils/minecraft/websocket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum WebSocketState { unactivated, activating, unconnected, connected, pausing }

enum WebSocketExecuteSyntaxVersion { executeOld, executeNew }

class Socketprov with ChangeNotifier {
  WebSocketExecuteSyntaxVersion _socketExecuteSyntaxVersion =
      WebSocketExecuteSyntaxVersion.executeOld;
  WebSocketState _socketState = WebSocketState.unactivated;
  int _socketDelay = 10;

  WebSocketExecuteSyntaxVersion get socketExecuteSyntaxVersion =>
      _socketExecuteSyntaxVersion;
  WebSocketState get socketState => _socketState;

  bool get unactivated => _socketState == WebSocketState.unactivated;
  bool get activating => _socketState == WebSocketState.activating;
  bool get unconnected => _socketState == WebSocketState.unconnected;
  bool get connected => _socketState == WebSocketState.connected;
  bool get pausing => _socketState == WebSocketState.pausing;

  int _speed = 0;
  List<String> _logs = [];

  int get speed => _speed;
  List<String> get logs => _logs;

  bool _onTask = false;
  List<int>? _virtualPlayerPos; // [ADD] 逻辑玩家位置追踪
  List<int>? _executeLoc;
  int _commandSent = 0;
  int _commandUnsend = 0;
  int _commandSentRecord = 0;
  List<String> _cachedCommands = [];

  bool get onTask => _onTask;
  int get commandSent => _commandSent;
  double get progress {
    if (!_onTask && !pausing) return 0.0;
    if (_commandSent == 0) return 0.0;
    return _commandSent / (_commandSent + _commandUnsend);
  }

  void updateExecuteSyntaxVersion(WebSocketExecuteSyntaxVersion v) {
    if (v == _socketExecuteSyntaxVersion) return;
    _socketExecuteSyntaxVersion = v;
    notifyListeners();
  }

  void updateDelay(int v) {
    if (v < 1) {
      throw Exception();
    }
    _socketDelay = v;
    notifyListeners();
  }

  void updateState(WebSocketState v) {
    _socketState = v;
    notifyListeners();
  }

  void updateSpeed(int v) {
    _speed = v;
    notifyListeners();
  }

  void appendLog(String log, {String? logHead}) {
    if (_logs.length == 20) {
      _logs.removeAt(0);
    }
    _logs.add('[${logHead ?? 'INFO'}][${DateTime.now().hmsOnly()}] $log');
    notifyListeners();
  }

  void clearLog() {
    _logs = [];
    notifyListeners();
  }

  void resetTaskRecords() {
    _commandSent = 0;
    _commandUnsend = 0;
    _commandSentRecord = 0;
    _cachedCommands = [];
    notifyListeners();
  }

  void recordExeLoc(List<int> loc) {
    _executeLoc = loc;
    notifyListeners();
  }

  Future<void> startTask(List<String> commands) async {
    if (!connected) return;

    resetTaskRecords();

    _onTask = true;
    _commandUnsend = commands.length;
    notifyListeners();

    await WebSocket().broadcastCommand('testforblock ~ ~ ~ air');

    Future<void> runUntilLocGot() async {
      await Future.delayed(Duration(milliseconds: _socketDelay), () {
        if (_executeLoc == null) {
          runUntilLocGot();
        } else {
          processTask(commands);

          _recordSpeed();
        }
      });
    }

    runUntilLocGot();
  }

  Future<void> _recordSpeed() async {
    if (!_onTask) return;
    Timer(const Duration(seconds: 1), () {
      _speed = _commandSent - _commandSentRecord;
      _commandSentRecord = _commandSent;
      notifyListeners();
      _recordSpeed();
    });
  }

  Future<void> processTask(List<String> commands) async {
    final reg = RegExp(r'~(-?\d+)'); // [ADD] 坐标解析正则

    for (int i = 0; i < commands.length; i++) {
      if (!_onTask) {
        _cachedCommands = commands;
        return;
      }

      // [ADD] 自动化跳跃 TP 加载逻辑开始
      if (_executeLoc != null) {
        final matches = reg.allMatches(commands[i]).toList();
        if (matches.length >= 3) {
          int relX = int.parse(matches[0].group(1)!);
          int relZ = int.parse(matches[2].group(1)!);
          int curX = _executeLoc![0] + relX;
          int curZ = _executeLoc![2] + relZ;

          if (_virtualPlayerPos == null) {
            _virtualPlayerPos = [curX, _executeLoc![1], curZ];
            await WebSocket().broadcastCommand('tp @s $curX ${_executeLoc![1]} $curZ');
          } else {
            bool shouldTp = (curX - _virtualPlayerPos![0]).abs() > 64 || (curZ - _virtualPlayerPos![2]).abs() > 64;
            if (shouldTp) {
              int nextX = _virtualPlayerPos![0] + (curX > _virtualPlayerPos![0] ? 128 : (curX < _virtualPlayerPos![0] ? -128 : 0));
              int nextZ = _virtualPlayerPos![2] + (curZ > _virtualPlayerPos![2] ? 128 : (curZ < _virtualPlayerPos![2] ? -128 : 0));
              await WebSocket().broadcastCommand('tp @s $nextX ${_executeLoc![1]} $nextZ');
              _virtualPlayerPos = [nextX, _executeLoc![1], nextZ];
            }
          }
        }
      }
      // [ADD] 自动化跳跃 TP 加载逻辑结束

      String command;
      if (_executeLoc != null) {
        command = {
          WebSocketExecuteSyntaxVersion.executeOld:
              'execute @p ${_executeLoc![0]} ${_executeLoc![1]} ${_executeLoc![2]} ${commands[i]}',
          WebSocketExecuteSyntaxVersion.executeNew:
              'execute positioned ${_executeLoc![0]} ${_executeLoc![1]} ${_executeLoc![2]} run ${commands[i]}',
        }[_socketExecuteSyntaxVersion]!;
      } else {
        command = commands[i];
      }

      await WebSocket().broadcastCommand(command);

      if (i % 128 == 0 || i == commands.length - 1) {
        if (_executeLoc != null) {
          await WebSocket().broadcastCommand(
            titleBuilder(_executeLoc!, _virtualPlayerPos, i, commands.length, speed),
          );
        } else {
          await WebSocket().broadcastCommand(
            'title @s actionbar §bColorify§f: §cPlease dont move!!!§f ${i + 1} / ${commands.length}',
          );
        }
      }


      _commandSent++;
      _commandUnsend--;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1));
    }
    _onTask = false;
  }


  void stopTask() {
    _onTask = false;
    _socketState = WebSocketState.pausing;
    notifyListeners();
  }

  void continueTask() {
    _onTask = true;
    processTask(_cachedCommands.sublist(_cachedCommands.length - _commandUnsend));

    _recordSpeed();
    _socketState = WebSocketState.connected;
    notifyListeners();
  }

  void killTask() {
    _cachedCommands = [];
    _onTask = false;
    _executeLoc = null;
    _socketState = WebSocketState.connected;
    notifyListeners();
  }
}

String titleBuilder(List<int> exeLoc, List<int>? virPos, int executed, int len, int speed) {
  const String line1 = '§bColorify§f - v6.1.6 - Comeix Alpha';
  final String line2 = 'Executing at: [§6${exeLoc[0]}§f, §6${exeLoc[1]}§f, §6${exeLoc[2]}§f]';
  final String line3 = "Player: [${virPos == null ? '§aWaiting§f' : '§a${virPos[0]}§f, §a${virPos[1]}§f, §a${virPos[2]}§f'}], §cPlease dont move!!!§f";
  final String line4 = 'Executed §6$executed§f / §6$len§f';
  final String line5 = 'Speed: §6${speed}§fBPS, Last §6${speed > 0 ? ((len - executed) / speed).toStringAsFixed(2) : '0'}s§f';
  return 'title @s actionbar ${[line1, line2, line3, line4, line5].join('\n')}';
}
