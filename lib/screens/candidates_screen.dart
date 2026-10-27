import 'package:flutter/material.dart';
import '../logic/election_logic.dart';

class CandidatesScreen extends StatefulWidget {
  final Election election;
  const CandidatesScreen({super.key, required this.election});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final controller = TextEditingController();

  void show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void add() {
    final error = widget.election.addCandidate(controller.text);
    if (error == null) {
      controller.clear();
      show('Candidate added');
    } else {
      show(error);
    }
  }

  Future<void> confirmReset() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This clears every vote and every voter.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (yes == true) {
      widget.election.reset();
      show('All votes cleared');
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'New candidate',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: add, child: const Text('Add')),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: candidates.isEmpty
                    ? const Center(child: Text('No candidates yet'))
                    : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.name),
                        subtitle: Text('${c.votes} votes'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final error =
                            widget.election.removeCandidate(c);
                            if (error != null) show(error);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: confirmReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset all votes'),
              ),
            ],
          ),
        );
      },
    );
  }
}