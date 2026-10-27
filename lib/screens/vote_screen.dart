import 'package:flutter/material.dart';
import '../logic/election_logic.dart';
import '../widgets/weather_strip.dart';

class VoteScreen extends StatefulWidget {
  final Election election;
  const VoteScreen({super.key, required this.election});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final nameController = TextEditingController();

  void vote(int index) {
    final candidate = widget.election.candidates[index];
    final error = widget.election.castVote(nameController.text, candidate);
    final message = error ?? 'Vote counted for ${candidate.name}';

    if (error == null) nameController.clear();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void undoVote() {
    final error = widget.election.undoLastVote();
    final message = error ?? 'Last vote undone';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.election,
      builder: (context, _) {
        final candidates = widget.election.candidates;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The live API part: weather from Open-Meteo
              const WeatherStrip(),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Votes so far: ${widget.election.totalVotes}',
                      style: Theme.of(context).textTheme.titleMedium),
                  OutlinedButton.icon(
                    onPressed: widget.election.voteHistory.isEmpty ? null : undoVote,
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Undo Last Vote'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: candidates.isEmpty
                    ? const Center(
                    child: Text('No candidates yet. Add one in Candidates.'))
                    : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, i) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(candidates[i].name),
                      trailing: FilledButton(
                        onPressed: () => vote(i),
                        child: const Text('Vote'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}