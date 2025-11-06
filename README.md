# Flutter Performance Monitor

An optimized Flutter package for monitoring app performance with focus on **average FPS calculation** and efficient resource usage.

## Features

- **Optimized Average FPS Monitoring**: Uses circular buffer for O(1) operations
- **Startup Performance Monitoring**: Track cold/warm startup times and first frame rendering
- **Memory Efficient**: Automatic cleanup and configurable history size
- **Multiple Overlay Options**: Simple, advanced, and comprehensive performance displays
- **Lifecycle Monitoring**: Track app state changes
- **Performance Logging**: Configurable logging with level filtering
- **Real-time Statistics**: Access to detailed performance metrics

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart';

void main() {
  runApp(
    MonitorApp(
      enableFPS: true,
      enableStartup: true, // Enable startup performance monitoring
      fpsHistorySize: 30, // 30 seconds for average calculation
      showStartupMetrics: true, // Show startup overlay
      child: MyApp(),
    ),
  );
}
```

## Average FPS Calculation

The package uses an optimized circular buffer approach for calculating average FPS:

- **O(1) Operations**: Adding and removing FPS values
- **Configurable History**: Set history size (default: 30 seconds)
- **Memory Efficient**: Automatic cleanup of old data
- **Real-time Updates**: Smooth average calculation without performance impact

### Key Optimizations

1. **Circular Buffer**: Uses `Queue<double>` for efficient FIFO operations
2. **Running Sum**: Maintains sum for O(1) average calculation
3. **Memory Management**: Periodic cleanup to prevent memory leaks
4. **Cached Values**: Reduces string operations and color calculations

## Startup Performance Monitoring

The package includes comprehensive startup performance tracking:

- **Cold vs Warm Startup Detection**: Automatically categorizes startup type
- **First Frame Timing**: Measures time to first rendered frame
- **Widget Ready Timing**: Tracks when widgets are fully initialized
- **Real-time Overlay**: Visual display of startup metrics
- **Performance Thresholds**: Color-coded indicators for startup performance

### Startup Metrics

- **Cold Start**: App launch from completely closed state (typically >400ms)
- **Warm Start**: App resume from background (typically <200ms)
- **First Frame**: Time from app start to first rendered frame
- **Widgets Ready**: Time from app start to widgets fully initialized

### Startup Performance Thresholds

- **Good Performance**: 
  - Cold start: <600ms
  - Warm start: <300ms
- **Moderate Performance**:
  - Cold start: 600-1000ms
  - Warm start: 300-500ms
- **Poor Performance**:
  - Cold start: >1000ms
  - Warm start: >500ms

## Usage Examples

### Basic Setup
```dart
MonitorApp(
  enableFPS: true,
  enableLifecycle: true,
  fpsHistorySize: 30, // Average over 30 seconds
  child: MyApp(),
)
```

### Advanced Configuration
```dart
MonitorApp(
  enableFPS: true,
  enableLifecycle: true,
  enableStartup: true, // Enable startup monitoring
  fpsHistorySize: 60, // Longer history for more stable average
  enableLogging: true,
  logLevel: 900, // INFO level
  showAdvancedMetrics: true,
  showStartupMetrics: true, // Show startup overlay
  showComprehensiveOverlay: false, // Combined FPS+startup overlay
  child: MyApp(),
)
```

### Startup-Only Configuration
```dart
MonitorApp(
  enableFPS: false,
  enableStartup: true,
  showStartupMetrics: true,
  child: MyApp(),
)
```

### Comprehensive Overlay (FPS + Startup)
```dart
MonitorApp(
  enableFPS: true,
  enableStartup: true,
  showComprehensiveOverlay: true, // Shows both FPS and startup in one overlay
  showAdvancedMetrics: true,
  child: MyApp(),
)
```

### Controlling the Overlays
```dart
// Toggle performance overlay
Provider.of<MonitorConfig>(context).togglePerformanceOverlay(true);

// Enable advanced metrics
Provider.of<MonitorConfig>(context).toggleAdvancedMetrics(true);

// Show/hide startup metrics
Provider.of<MonitorConfig>(context).toggleStartupMetrics(true);

// Reset average calculation
Monitor.instance.fps?.resetAverage();

// Reset startup monitoring for new measurement
Monitor.instance.startup.reset();
```

### Accessing Statistics
```dart
// Get current performance stats
final stats = Monitor.instance.getStats();
print('Average FPS: ${stats['fpsStats']['averageFPS']}');
print('Current FPS: ${stats['fpsStats']['currentFPS']}');
print('History Size: ${stats['fpsStats']['historySize']}');

// Get startup performance stats
final startupStats = stats['startupStats'];
print('Startup Type: ${startupStats['startupType']}');
print('First Frame: ${startupStats['timeToFirstFrameMs']}ms');
print('Widgets Ready: ${startupStats['timeToWidgetsReadyMs']}ms');

// Get current startup metrics
final currentMetrics = Monitor.instance.startup.currentMetrics;
if (currentMetrics != null) {
  print('Startup: ${currentMetrics.startupType.name} - ${currentMetrics.timeToFirstFrame.inMilliseconds}ms');
}
```

## Overlay Types

### Simple FPS Overlay
- Shows average FPS with color coding
- Minimal resource usage
- Clean, unobtrusive display

### Advanced FPS Overlay
- Average and current FPS
- Sample count
- Performance metrics
- Optional startup metrics integration

### Startup Performance Overlay
- Startup type (Cold/Warm)
- First frame timing
- Color-coded performance indicators
- Positioned on top-left

### Comprehensive Overlay
- Combined FPS and startup metrics
- Detailed performance breakdown
- Advanced metrics display
- Complete performance monitoring

## Performance Considerations

- **Minimal Overhead**: Optimized for production use
- **Configurable Sampling**: Adjust history size based on needs
- **Memory Efficient**: Automatic cleanup prevents memory leaks
- **Level-based Logging**: Reduce logging overhead in production

## API Reference

### MonitorApp Parameters
- `enableFPS`: Enable FPS monitoring (default: true)
- `enableLifecycle`: Enable lifecycle monitoring (default: true)
- `enableStartup`: Enable startup performance monitoring (default: true)
- `fpsHistorySize`: Number of FPS samples for average (default: 30)
- `enableLogging`: Enable performance logging (default: true)
- `logLevel`: Minimum log level (default: 900 - INFO)
- `showAdvancedMetrics`: Show detailed metrics (default: false)
- `showStartupMetrics`: Show startup performance overlay (default: false)
- `showComprehensiveOverlay`: Show combined FPS+startup overlay (default: false)

### MonitorConfig Methods
- `togglePerformanceOverlay(bool)`: Show/hide performance overlay
- `toggleAdvancedMetrics(bool)`: Switch overlay type
- `toggleStartupMetrics(bool)`: Show/hide startup metrics overlay
- `setFPSHistorySize(int)`: Update history size
- `configureLogging({bool?, int?})`: Update logging settings

### FPSMonitor Methods
- `resetAverage()`: Reset average calculation
- `getStats()`: Get performance statistics
- `start()`: Start monitoring
- `stop()`: Stop monitoring

### StartupMonitor Methods
- `init()`: Initialize startup monitoring
- `reset()`: Reset for new startup measurement
- `getStats()`: Get startup statistics
- `currentMetrics`: Get current startup metrics
- `startupStream`: Stream of startup metrics updates

## License

MIT License