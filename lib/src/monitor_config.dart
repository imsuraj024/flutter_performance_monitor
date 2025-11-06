import 'package:flutter/foundation.dart';

/// MonitorConfig - Configuration state for the monitoring system
class MonitorConfig extends ChangeNotifier {
  bool _showPerformanceOverlay = false;
  bool _enableAdvancedMetrics = false;
  bool _showStartupMetrics = false;

  // Getters
  bool get showPerformanceOverlay => _showPerformanceOverlay;
  bool get enableAdvancedMetrics => _enableAdvancedMetrics;
  bool get showStartupMetrics => _showStartupMetrics;

  /// Toggle performance overlay visibility
  void togglePerformanceOverlay(bool show) {
    if (_showPerformanceOverlay != show) {
      _showPerformanceOverlay = show;
      notifyListeners();
    }
  }

  /// Toggle FPS overlay visibility (deprecated - use togglePerformanceOverlay)
  @Deprecated('Use togglePerformanceOverlay instead')
  void toggleFPSOverlay(bool show) => togglePerformanceOverlay(show);

  /// Show FPS overlay (deprecated - use showPerformanceOverlay)
  @Deprecated('Use showPerformanceOverlay instead')
  bool get showFPSOverlay => _showPerformanceOverlay;

  /// Toggle advanced metrics display
  void toggleAdvancedMetrics(bool enable) {
    if (_enableAdvancedMetrics != enable) {
      _enableAdvancedMetrics = enable;
      notifyListeners();
    }
  }

  /// Toggle startup metrics display
  void toggleStartupMetrics(bool show) {
    if (_showStartupMetrics != show) {
      _showStartupMetrics = show;
      notifyListeners();
    }
  }


  /// Reset to default configuration
  void reset() {
    _showPerformanceOverlay = false;
    _enableAdvancedMetrics = false;
    _showStartupMetrics = false;
    notifyListeners();
  }

  /// Get current configuration as map
  Map<String, dynamic> toMap() {
    return {
      'showPerformanceOverlay': _showPerformanceOverlay,
      'enableAdvancedMetrics': _enableAdvancedMetrics,
      'showStartupMetrics': _showStartupMetrics,
    };
  }
}