import 'package:flutter/material.dart';
import 'fps_monitor.dart';
import 'startup_monitor.dart';

/// Comprehensive Performance Overlay - Shows both FPS and startup metrics
class ComprehensivePerformanceOverlay extends StatelessWidget {
  final FPSMonitor fpsMonitor;
  final StartupMonitor startupMonitor;

  const ComprehensivePerformanceOverlay({
    super.key,
    required this.fpsMonitor,
    required this.startupMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        // Detailed metrics (bottom right) if enabled
       Positioned(
            bottom: 100,
            right: 10,
            child: StreamBuilder<double>(
              stream: fpsMonitor.fpsStream,
              initialData: fpsMonitor.averageFPS,
              builder: (context, fpsSnapshot) {
                return StreamBuilder<StartupMetrics>(
                  stream: startupMonitor.startupStream,
                  builder: (context, startupSnapshot) {
                    final fps = fpsSnapshot.data ?? 0;
                    final fpsStats = fpsMonitor.getStats();
                    final startupMetrics = startupSnapshot.data ?? startupMonitor.currentMetrics;
                    
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Performance Details",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // FPS Details
                          Text(
                            "FPS",
                            style: TextStyle(
                              color: Colors.blue.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          _buildDetailRow("Avg", "${fps.toStringAsFixed(1)}", _getFpsColor(fps)),
                          _buildDetailRow("Now", "${fpsStats['currentFPS'].toStringAsFixed(1)}", Colors.white70),
                          
                          const SizedBox(height: 4),
                          
                          // Startup Details
                          Text(
                            "Startup",
                            style: TextStyle(
                              color: Colors.orange.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          if (startupMetrics != null) ...[
                            _buildDetailRow(
                              "Type", 
                              startupMetrics.startupType.name.toUpperCase(), 
                              _getStartupColor(startupMetrics.startupType, startupMetrics.timeToFirstFrame.inMilliseconds)
                            ),
                            _buildDetailRow(
                              "1st", 
                              "${startupMetrics.timeToFirstFrame.inMilliseconds}ms", 
                              _getStartupColor(startupMetrics.startupType, startupMetrics.timeToFirstFrame.inMilliseconds)
                            ),
                            _buildDetailRow("Ready", "${startupMetrics.timeToWidgetsReady.inMilliseconds}ms", Colors.white70),
                          ] else
                            _buildDetailRow("Status", "Measuring...", Colors.grey),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
      ],
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.greenAccent;
    if (fps >= 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Color _getStartupColor(StartupType type, int milliseconds) {
    switch (type) {
      case StartupType.cold:
        return milliseconds > 1000 ? Colors.red : milliseconds > 600 ? Colors.orange : Colors.green;
      case StartupType.warm:
        return milliseconds > 300 ? Colors.orange : Colors.green;
      case StartupType.unknown:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 35,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}