import 'package:flutter/material.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MonitorApp(
      enableFPS: true,
      enableStartup: true, // Enable startup monitoring
      showComprehensiveOverlay: true, // Set to true for combined FPS+startup overlay
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<MonitorConfig>(context);

    return MaterialApp(
      title: 'FPS Monitor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Average FPS Monitor Demo"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Average FPS Monitoring",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "The overlay shows average FPS over the last 30 seconds",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              // FPS Overlay Toggle
              ElevatedButton.icon(
                onPressed: () {
                  config.togglePerformanceOverlay(!config.showPerformanceOverlay);
                },
                icon: Icon(config.showPerformanceOverlay 
                    ? Icons.visibility_off 
                    : Icons.visibility),
                label: Text(config.showPerformanceOverlay
                    ? "Hide Performance Overlay"
                    : "Show Performance Overlay"),
              ),
              
              const SizedBox(height: 20),
              
              // Advanced Metrics Toggle
              ElevatedButton.icon(
                onPressed: () {
                  config.toggleAdvancedMetrics(!config.enableAdvancedMetrics);
                },
                icon: Icon(config.enableAdvancedMetrics 
                    ? Icons.analytics_outlined 
                    : Icons.analytics),
                label: Text(config.enableAdvancedMetrics
                    ? "Simple View"
                    : "Advanced Metrics"),
              ),
              
              const SizedBox(height: 10),
              
              // Startup Metrics Toggle
              ElevatedButton.icon(
                onPressed: () {
                  config.toggleStartupMetrics(!config.showStartupMetrics);
                },
                icon: Icon(config.showStartupMetrics 
                    ? Icons.rocket_launch_outlined 
                    : Icons.rocket_launch),
                label: Text(config.showStartupMetrics
                    ? "Hide Startup Metrics"
                    : "Show Startup Metrics"),
              ),
              
              const SizedBox(height: 40),
              
              // Performance Test Buttons
              const Text("Performance Tests:", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => _performHeavyTask(),
                    child: const Text("Heavy Task"),
                  ),
                  ElevatedButton(
                    onPressed: () => _performAnimationTest(context),
                    child: const Text("Animation Test"),
                  ),
                  ElevatedButton(
                    onPressed: () => _resetFPSAverage(),
                    child: const Text("Reset Average"),
                  ),
                  ElevatedButton(
                    onPressed: () => _showStartupStats(context),
                    child: const Text("Startup Stats"),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Statistics Display
              _buildStatsDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsDisplay() {
    return StreamBuilder<double>(
      stream: Monitor.instance.fps?.fpsStream,
      builder: (context, snapshot) {
        final stats = Monitor.instance.getStats();
        final fpsStats = stats['fpsStats'] as Map<String, dynamic>?;
        final startupStats = stats['startupStats'] as Map<String, dynamic>?;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Performance Statistics:", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // FPS Stats
                if (fpsStats != null) ...[
                  Text("Current FPS: ${fpsStats['currentFPS']?.toStringAsFixed(1) ?? 'N/A'}"),
                  Text("Average FPS: ${fpsStats['averageFPS']?.toStringAsFixed(1) ?? 'N/A'}"),
                  Text("History Size: ${fpsStats['historySize'] ?? 'N/A'}"),
                  const SizedBox(height: 8),
                ] else
                  const Text("FPS monitoring not available"),
                
                // Startup Stats
                if (startupStats != null) ...[
                  const Text("Startup Performance:", 
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("Type: ${startupStats['startupType']?.toString().toUpperCase() ?? 'N/A'}"),
                  Text("First Frame: ${startupStats['timeToFirstFrameMs'] ?? 'N/A'}ms"),
                  Text("Widgets Ready: ${startupStats['timeToWidgetsReadyMs'] ?? 'N/A'}ms"),
                ] else
                  const Text("Startup monitoring not available"),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performHeavyTask() {
    // Simulate heavy computation to affect FPS
    for (int i = 0; i < 1000000; i++) {
      // Heavy computation
      double result = i * 0.1 + i * 0.2;
      result = result / 2;
    }
  }

  void _performAnimationTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnimationTestPage(),
      ),
    );
  }


  void _resetFPSAverage() {
    Monitor.instance.fps?.resetAverage();
  }

  void _showStartupStats(BuildContext context) {
    final startupStats = Monitor.instance.startup.getStats();
    final currentMetrics = Monitor.instance.startup.currentMetrics;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Startup Statistics"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentMetrics != null) ...[
              Text("Startup Type: ${currentMetrics.startupType.name.toUpperCase()}"),
              Text("First Frame: ${currentMetrics.timeToFirstFrame.inMilliseconds}ms"),
              Text("Widgets Ready: ${currentMetrics.timeToWidgetsReady.inMilliseconds}ms"),
              Text("Timestamp: ${currentMetrics.timestamp.toString().substring(11, 19)}"),
            ] else ...[
              const Text("No startup metrics available yet."),
              const SizedBox(height: 8),
              const Text("Restart the app to see startup performance."),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class AnimationTestPage extends StatefulWidget {
  const AnimationTestPage({super.key});

  @override
  State<AnimationTestPage> createState() => _AnimationTestPageState();
}

class _AnimationTestPageState extends State<AnimationTestPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animation Test"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Watch how animations affect average FPS"),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 6.28,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Back to Main"),
            ),
          ],
        ),
      ),
    );
  }
}