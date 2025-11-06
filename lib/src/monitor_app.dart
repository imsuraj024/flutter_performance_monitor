import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'monitor.dart';
import 'monitor_config.dart';
import 'performance_overlay.dart';

/// MonitorApp - Optimized root wrapper to initialize monitors
/// Wrap your MaterialApp or CupertinoApp with this
class MonitorApp extends StatefulWidget {
  final Widget child;
  final bool enableFPS;
  final bool enableStartup;
  final bool showComprehensiveOverlay;

  const MonitorApp({
    super.key,
    required this.child,
    this.enableFPS = true,
    this.enableStartup = true,
    this.showComprehensiveOverlay = false,
  });

  @override
  State<MonitorApp> createState() => _MonitorAppState();
}

class _MonitorAppState extends State<MonitorApp> {
  @override
  void initState() {
    super.initState();
    
    // Initialize monitor with optimized settings
    Monitor.instance.init(
      enableFPS: widget.enableFPS,
      enableStartup: widget.enableStartup,
    );

  }

  @override
  void dispose() {
    Monitor.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Monitor.instance.config,
      child: Consumer<MonitorConfig>(
        builder: (context, config, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                widget.child, // Must be MaterialApp / CupertinoApp
                
                // Performance overlays
                ..._buildPerformanceOverlays(config),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build performance overlays based on configuration
  List<Widget> _buildPerformanceOverlays(MonitorConfig config) {
    final overlays = <Widget>[];
    
    // Only show overlays if performance overlay is enabled and FPS monitor exists
    if (config.showPerformanceOverlay && Monitor.instance.fps != null) {
      // Show comprehensive overlay if requested and advanced metrics enabled
      if (widget.showComprehensiveOverlay && 
          widget.enableFPS && 
          widget.enableStartup
          ) {
        overlays.add(
          ComprehensivePerformanceOverlay(
            fpsMonitor: Monitor.instance.fps!,
            startupMonitor: Monitor.instance.startup,
            showAdvanceStats: config.enableAdvancedMetrics,
          
          ),
        );
      }
    }
    
    return overlays;
  }

}