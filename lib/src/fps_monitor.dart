import 'dart:async';
import 'dart:collection';
import 'package:flutter/scheduler.dart';

/// FPSMonitor - Tracks frames per second with optimized average calculation
class FPSMonitor {
  final _fpsController = StreamController<double>.broadcast();
  Stream<double> get fpsStream => _fpsController.stream;

  int _frameCount = 0;
  late DateTime _startTime;
  bool _isRunning = false;

  double currentFPS = 0;
  double averageFPS = 0;
  
  // Optimized circular buffer for FPS history
  final Queue<double> _fpsHistory = Queue<double>();
  double _fpsSum = 0.0;
  static const int _maxHistorySize = 30; // 30 seconds of data
  
  // Performance optimization: cache frequently used values
  late Timer _cleanupTimer;
  static const Duration _cleanupInterval = Duration(seconds: 5);

  /// Start monitoring FPS
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _frameCount = 0;
    _startTime = DateTime.now();
    _initializeCleanup();
    SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
    // log("FPSMonitor started", module: "FPS");
  }

  /// Stop monitoring FPS
  void stop() {
    _isRunning = false;
    _cleanupTimer.cancel();
    // log("FPSMonitor stopped", module: "FPS");
  }

  /// Initialize cleanup timer for memory optimization
  void _initializeCleanup() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      if (!_isRunning) return;
      _optimizeMemory();
    });
  }

  /// Optimize memory usage by cleaning old data
  void _optimizeMemory() {
    // Ensure we don't exceed history size
    while (_fpsHistory.length > _maxHistorySize) {
      final removed = _fpsHistory.removeFirst();
      _fpsSum -= removed;
    }
  }

  void _onFrame(Duration timeStamp) {
    if (!_isRunning) return;

    _frameCount++;
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    
    if (elapsed >= 1000) {
      // Calculate current FPS
      currentFPS = _frameCount / (elapsed / 1000);
      
      // Optimized average calculation using running sum
      _addFPSToHistory(currentFPS);
      
      // Calculate average efficiently
      averageFPS = _fpsHistory.isNotEmpty ? _fpsSum / _fpsHistory.length : 0;
      
      // Emit average FPS
      _fpsController.add(averageFPS);
      
      // Reset counters
      _frameCount = 0;
      _startTime = DateTime.now();
      
    }

    SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
  }

  /// Efficiently add FPS to history with O(1) operations
  void _addFPSToHistory(double fps) {
    // Add new FPS value
    _fpsHistory.addLast(fps);
    _fpsSum += fps;
    
    // Remove oldest if exceeding limit (O(1) operation)
    if (_fpsHistory.length > _maxHistorySize) {
      final removed = _fpsHistory.removeFirst();
      _fpsSum -= removed;
    }
  }

  /// Optimized logging with reduced string operations
  // void _logFPSStatus(double fps) {
  //   if (fps >= 55) {
  //     log("Avg FPS healthy: ${fps.toStringAsFixed(1)}", module: "FPS");
  //   } else if (fps >= 30) {
  //     log("Avg FPS warning: ${fps.toStringAsFixed(1)}", module: "FPS", level: 1000);
  //   } else {
  //     log("Avg FPS poor: ${fps.toStringAsFixed(1)}", module: "FPS", level: 1200);
  //   }
  // }

  /// Reset average calculation
  void resetAverage() {
    _fpsHistory.clear();
    _fpsSum = 0.0;
    averageFPS = 0;
  }

  /// Get FPS statistics for debugging
  Map<String, dynamic> getStats() {
    return {
      'currentFPS': currentFPS,
      'averageFPS': averageFPS,
      'historySize': _fpsHistory.length,
      'maxHistorySize': _maxHistorySize,
      'isRunning': _isRunning,
    };
  }

  /// Dispose resources
  void dispose() {
    stop();
    _fpsController.close();
  }
}