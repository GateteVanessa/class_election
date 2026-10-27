import 'package:flutter/material.dart';
import 'logic/election_logic.dart';
import 'screens/vote_screen.dart';
import 'screens/results_screen.dart';
import 'screens/candidates_screen.dart';

void main() {
  runApp(const IjwiApp());
}

class IjwiApp extends StatefulWidget {
  const IjwiApp({super.key});

  @override
  State<IjwiApp> createState() => _IjwiAppState();
}

class _IjwiAppState extends State<IjwiApp> {
  final Election election = Election();
  int tab = 0;
  bool loaded = false; // Part 2: wait until the saved data is read

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    await election.load();
    if (!mounted) return;
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      VoteScreen(election: election),
      ResultsScreen(election: election),
      CandidatesScreen(election: election),
    ];
    const titles = ['Vote', 'Results', 'Candidates'];

    return MaterialApp(
      title: 'Ijwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F3D9E)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ijwi · ${titles[tab]}'),
          backgroundColor: const Color(0xFF3F3D9E),
          foregroundColor: Colors.white,
        ),
        body: loaded
            ? pages[tab]
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.how_to_vote), label: 'Vote'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Results'),
            NavigationDestination(icon: Icon(Icons.group), label: 'Candidates'),
          ],
        ),
      ),
    );
  }
}