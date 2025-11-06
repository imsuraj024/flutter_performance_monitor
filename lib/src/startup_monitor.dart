import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'logger.dart';

/// StartupMonitor - Optimized monitoring for app startup performance
class StartupMonitor {
  static final StartupMonitor instance = StartupMonitor._internal();
  StartupMonitor._internal();

  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  DateTime? _widgetsReadyTime;
  bool _isFirstLaunch = true;
  bool _isMonitoring = false;
  
  // Startup metrics
  Duration? _timeToFirstFrame;
  Duration? _timeToWidgetsReady;
  StartupType? _startupType;
  
  final _startupController = StreamController<StartupMetrics>.broadcast();
  Stream<StartupMetrics> get startupStream => _startupController.stream;

  /// Initialize startup monitoring
  void init() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _appStartTime = DateTime.now();
    
    // Schedule callbacks for different startup phases
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onFirstFrame();
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onWidgetsReady();
    });
    
    log("Startup monitoring initialized", module: "STARTUP");
  }

  /// Called when first frame is rendered
  void _onFirstFrame() {
    if (_firstFrameTime != null) return;
    
    _firstFrameTime = DateTime.now();
    if (_appStartTime != null) {
      _timeToFirstFrame = _firstFrameTime!.difference(_appStartTime!);
      _determineStartupType();
      
      log(
        "First frame rendered in ${_timeToFirstFrame!.inMilliseconds}ms (${_startupType?.name})",
        module: "STARTUP",
      );
    }
  }

  /// Called when widgets are ready
  void _onWidgetsReady() {
    if (_widgetsReadyTime != null) return;
    
    _widgetsReadyTime = DateTime.now();
    if (_appStartTime != null) {
      _timeToWidgetsReady = _widgetsReadyTime!.difference(_appStartTime!);
      
      // Emit complete startup metrics
      _emitStartupMetrics();
      
      log(
        "Widgets ready in ${_timeToWidgetsReady!.inMilliseconds}ms",
        module: "STARTUP",
      );
    }
  }

  /// Determine if this is a cold or warm startup
  void _determineStartupType() {
    if (_timeToFirstFrame == null) return;
    
    // Heuristic: Cold starts typically take longer than 400ms
    // Warm starts are usually under 200ms
    final milliseconds = _timeToFirstFrame!.inMilliseconds;
    
    if (_isFirstLaunch) {
      _startupType = milliseconds > 400 ? StartupType.cold : StartupType.warm;
      _isFirstLaunch = false;
    } else {
      _startupType = StartupType.warm;
    }
  }

  /// Emit complete startup metrics
  void _emitStartupMetrics() {
    if (_timeToFirstFrame == null || _timeToWidgetsReady == null) return;
    
    final metrics = StartupMetrics(
      startupType: _startupType ?? StartupType.unknown,
      timeToFirstFrame: _timeToFirstFrame!,
      timeToWidgetsReady: _timeToWidgetsReady!,
      timestamp: DateTime.now(),
    );
    
    _startupController.add(metrics);
    
    // Log comprehensive startup info
    _logStartupSummary(metrics);
  }

  /// Log detailed startup summary
  void _logStartupSummary(StartupMetrics metrics) {
    final type = metrics.startupType.name.toUpperCase();
    final firstFrame = metrics.timeToFirstFrame.inMilliseconds;
    final widgetsReady = metrics.timeToWidgetsReady.inMilliseconds;
    
    log(
      "Startup Complete - Type: $type, First Frame: ${firstFrame}ms, Widgets Ready: ${widgetsReady}ms",
      module: "STARTUP",
      level: metrics.startupType == StartupType.cold && firstFrame > 1000 ? 1000 : 900,
    );
  }

  /// Mark app as backgrounded (for warm startup detection)
  void markAppBackgrounded() {
    log("App backgrounded - next startup will be warm", module: "STARTUP");
  }

  /// Reset for new startup measurement
  void reset() {
    _appStartTime = null;
    _firstFrameTime = null;
    _widgetsReadyTime = null;
    _timeToFirstFrame = null;
    _timeToWidgetsReady = null;
    _startupType = null;
    
    log("Startup monitor reset", module: "STARTUP");
  }

  /// Get current startup metrics
  StartupMetrics? get currentMetrics {
    if (_timeToFirstFrame == null || _timeToWidgetsReady == null) return null;
    
    return StartupMetrics(
      startupType: _startupType ?? StartupType.unknown,
      timeToFirstFrame: _timeToFirstFrame!,
      timeToWidgetsReady: _timeToWidgetsReady!,
      timestamp: DateTime.now(),
    );
  }

  /// Get startup statistics
  Map<String, dynamic> getStats() {
    return {
      'isMonitoring': _isMonitoring,
      'startupType': _startupType?.name,
      'timeToFirstFrameMs': _timeToFirstFrame?.inMilliseconds,
      'timeToWidgetsReadyMs': _timeToWidgetsReady?.inMilliseconds,
      'appStartTime': _appStartTime?.toIso8601String(),
      'firstFrameTime': _firstFrameTime?.toIso8601String(),
      'widgetsReadyTime': _widgetsReadyTime?.toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _startupController.close();
    _isMonitoring = false;
  }
}

/// Startup type enumeration
enum StartupType {
  cold,
  warm,
  unknown,
}

/// Startup metrics data class
class StartupMetrics {
  final StartupType startupType;
  final Duration timeToFirstFrame;
  final Duration timeToWidgetsReady;
  final DateTime timestamp;

  const StartupMetrics({
    required this.startupType,
    required this.timeToFirstFrame,
    required this.timeToWidgetsReady,
    required this.timestamp,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'startupType': startupType.name,
      'timeToFirstFrameMs': timeToFirstFrame.inMilliseconds,
      'timeToWidgetsReadyMs': timeToWidgetsReady.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from map
  factory StartupMetrics.fromMap(Map<String, dynamic> map) {
    return StartupMetrics(
      startupType: StartupType.values.firstWhere(
        (e) => e.name == map['startupType'],
        orElse: () => StartupType.unknown,
      ),
      timeToFirstFrame: Duration(milliseconds: map['timeToFirstFrameMs']),
      timeToWidgetsReady: Duration(milliseconds: map['timeToWidgetsReadyMs']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  @override
  String toString() {
    return 'StartupMetrics(type: ${startupType.name}, firstFrame: ${timeToFirstFrame.inMilliseconds}ms, widgetsReady: ${timeToWidgetsReady.inMilliseconds}ms)';
  }
}