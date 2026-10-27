import 'package:flutter/material.dart';
import '../logic/election_logic.dart';

class ResultsScreen extends StatefulWidget {
  final Election election;
  const ResultsScreen({super.key, required this.election});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final TextEditingController classSizeController;

  @override
  void initState() {
    super.initState();
    classSizeController = TextEditingController(text: widget.election.classSize.toString());
  }

  @override
  void dispose() {
    classSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.election,
      builder: (context, _) {
        final total = widget.election.totalVotes;
        final classSize = widget.election.classSize;
        final turnout = percentOf(total, classSize);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Turnout card / section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Turnout: $total / $classSize (${turnout.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: classSizeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Class size',
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final size = int.tryParse(val);
                          if (size != null) {
                            widget.election.setClassSize(size);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Requirement 7: never show NaN%
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No votes yet', style: TextStyle(fontSize: 22)),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bannerText(widget.election.candidates),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final c in rankCandidates(widget.election.candidates)) ...[
                Text('${c.name}: ${c.votes} votes '
                    '(${percentOf(c.votes, total).toStringAsFixed(1)}%)'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentOf(c.votes, total) / 100,
                  minHeight: 14,
                  borderRadius: BorderRadius.circular(7),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ],
        );
      },
    );
  }
}
