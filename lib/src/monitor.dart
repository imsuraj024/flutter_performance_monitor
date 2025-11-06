import 'fps_monitor.dart';
import 'lifecycle_monitor.dart';
import 'startup_monitor.dart';
import 'monitor_config.dart';
import 'logger.dart';

/// Monitor - Optimized singleton to manage all monitoring modules
class Monitor {
  static final Monitor instance = Monitor._internal();
  Monitor._internal();

  FPSMonitor? _fpsMonitor;
  LifecycleMonitor? _lifecycleMonitor;
  final MonitorConfig config = MonitorConfig();

  bool _isInitialized = false;

  /// Initialize required modules with optimized settings
  void init({
    bool enableFPS = true, 
    bool enableStartup = true,
  }) {
    if (_isInitialized) {
      // log("Monitor already initialized", module: "MONITOR", level: 1000);
      return;
    }

    // Initialize startup monitoring first (must be early)
    if (enableStartup) {
      StartupMonitor.instance.init();
      // log("Startup monitoring initialized", module: "MONITOR");
    }

    // Initialize FPS monitoring
    if (enableFPS) {
      _fpsMonitor = FPSMonitor()..start();
      // log("FPS monitoring initialized", module: "MONITOR");
    }

    _isInitialized = true;
    // log("Monitor initialization complete", module: "MONITOR");
  }

  /// Get FPS monitor instance
  FPSMonitor? get fps => _fpsMonitor;

  /// Get startup monitor instance
  StartupMonitor get startup => StartupMonitor.instance;

  /// Check if monitor is initialized
  bool get isInitialized => _isInitialized;

  /// Get comprehensive monitoring statistics
  Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized,
      'fpsEnabled': _fpsMonitor != null,
      'startupEnabled': true,
      'fpsStats': _fpsMonitor?.getStats(),
      'startupStats': StartupMonitor.instance.getStats(),
    };
  }

  /// Reset all monitors
  void reset() {
    dispose();
    _isInitialized = false;
    // log("Monitor reset complete", module: "MONITOR");
  }

  /// Dispose all resources
  void dispose() {
    _fpsMonitor?.dispose();
    StartupMonitor.instance.dispose();
    _fpsMonitor = null;
    // log("Monitor disposed", module: "MONITOR");
  }
}