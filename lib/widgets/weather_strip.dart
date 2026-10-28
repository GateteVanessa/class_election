import 'package:flutter/material.dart';

import '../logic/weather.dart';

IconData iconFor(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code <= 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 95) return Icons.thunderstorm;
  if (code >= 51) return Icons.water_drop;
  return Icons.help_outline;
}

/// The live API part: today's weather in Kigali.
/// Three states: loading (spinner), error (message + Retry), data.
class WeatherStrip extends StatefulWidget {
  const WeatherStrip({super.key});

  @override
  State<WeatherStrip> createState() => _WeatherStripState();
}

class _WeatherStripState extends State<WeatherStrip> {
  Weather? weather;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchWeather();
      if (!mounted) return;
      setState(() {
        weather = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load the weather. Check your internet connection.';
      });
    }
  }

  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    const white = TextStyle(color: Colors.white);
    Widget content;
    if (loading) {
      content = const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else if (error != null) {
      content = Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(error!, style: white)),
          TextButton(
            onPressed: retry,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    } else {
      final w = weather!;
      content = Row(
        children: [
          Icon(iconFor(w.code), color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Voting day weather · Kigali', style: white),
                Text(
                  '${w.temperature.round()}°C · ${describe(w.code)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Humidity ${w.humidity}% · Wind ${w.wind} km/h · ${w.clock}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F3D9E), Color(0xFF24236B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: content,
    );
  }
}