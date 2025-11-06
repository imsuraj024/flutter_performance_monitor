import 'package:flutter/material.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MonitorApp(
      showComprehensiveOverlay: true, // Set to true for combined FPS+startup overlay
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPS Monitor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<MonitorConfig>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Average FPS Monitor Demo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Performance Monitoring",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            
            ElevatedButton(
              onPressed: () {
                config.togglePerformanceOverlay(!config.showPerformanceOverlay);
              },
              child: Text(config.showPerformanceOverlay
                  ? "Hide Performance Overlay"
                  : "Show Performance Overlay"),
            ),
            
            const SizedBox(height: 20),
            
            // Advanced Metrics Toggle
            ElevatedButton(
              onPressed: () {
                config.toggleAdvancedMetrics(!config.enableAdvancedMetrics);
              },
              
              child: Text(config.enableAdvancedMetrics
                  ? "Simple View"
                  : "Advanced Metrics"),
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
              ],
            ),
            
            const SizedBox(height: 40),
            
          ],
        ),
      ),
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