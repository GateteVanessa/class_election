import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate.dart';

/// Lab 4: trim, collapse spaces, Title Case.
String cleanName(String raw) {
  return raw
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

/// Percentage of all votes. Never divides by zero.
double percentOf(int votes, int totalVotes) {
  if (totalVotes == 0) return 0;
  return votes / totalVotes * 100;
}

/// Lab 9: highest votes first. Ties are ordered by name so the order is stable.
List<Candidate> rankCandidates(List<Candidate> list) {
  final ranked = List<Candidate>.from(list);
  ranked.sort((a, b) {
    final byVotes = b.votes.compareTo(a.votes); // more votes goes earlier
    if (byVotes != 0) return byVotes;
    return a.name.compareTo(b.name);
  });
  return ranked;
}

/// Lab 8: winner or tie, based on how many candidates share the top score.
String bannerText(List<Candidate> list) {
  final total = list.fold(0, (sum, c) => sum + c.votes);
  if (total == 0) return 'No votes yet';

  final top = list.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
  final leaders = list.where((c) => c.votes == top).toList();

  if (leaders.length == 1) return 'Winner: ${leaders.first.name}';
  final names = leaders.map((c) => c.name).join(' and ');
  return 'Tie between $names ($top votes each)';
}

class VoteRecord {
  final String voter;
  final Candidate candidate;
  VoteRecord({required this.voter, required this.candidate});
}

/// Holds all the data. Screens listen to it, so every change shows everywhere.
class Election extends ChangeNotifier {
  final List<Candidate> candidates = [
    Candidate(name: 'Keza'),
    Candidate(name: 'Mutoni'),
    Candidate(name: 'Eric'),
  ];
  final List<String> voters = [];
  final List<VoteRecord> voteHistory = [];
  int classSize = 30;

  int get totalVotes => voters.length;

  bool hasVoted(String cleaned) => voters.contains(cleaned);

  void setClassSize(int size) {
    classSize = size < 0 ? 0 : size;
    notifyListeners();
  }

  /// Returns an error message, or null if the vote was counted.
  String? castVote(String rawName, Candidate candidate) {
    final voter = cleanName(rawName);
    if (voter.isEmpty) return 'Please type your name';
    if (hasVoted(voter)) return '$voter has already voted';

    voters.add(voter);
    candidate.votes++;
    voteHistory.add(VoteRecord(voter: voter, candidate: candidate));
    notifyListeners();
    return null;
  }

  /// Undo the last cast vote.
  String? undoLastVote() {
    if (voteHistory.isEmpty) return 'No votes to undo';
    final last = voteHistory.removeLast();
    voters.remove(last.voter);
    last.candidate.votes--;
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null if the candidate was added.
  String? addCandidate(String rawName) {
    final name = cleanName(rawName);
    if (name.isEmpty) return 'Candidate name cannot be empty';
    if (candidates.any((c) => c.name == name)) return '$name already exists';

    candidates.add(Candidate(name: name));
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null if the candidate was removed.
  String? removeCandidate(Candidate c) {
    if (c.votes > 0) return '${c.name} has votes and cannot be removed';
    candidates.remove(c);
    notifyListeners();
    return null;
  }

  void reset() {
    for (final c in candidates) {
      c.votes = 0;
    }
    voters.clear();
    voteHistory.clear();
    notifyListeners();
  }

  // ---------------- Part 2: saving on the phone ----------------

  /// Every change already calls notifyListeners(), so saving here means
  /// add, vote, undo, delete, reset and class size are ALL saved.
  @override
  void notifyListeners() {
    super.notifyListeners();
    save();
  }

  Map<String, dynamic> toJson() {
    return {
      'candidates': candidates.map((c) => c.toJson()).toList(),
      'voters': voters,
      'history': voteHistory
          .map((v) => {'voter': v.voter, 'candidate': v.candidate.name})
          .toList(),
      'classSize': classSize,
    };
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('election', jsonEncode(toJson()));
  }

  /// Called once when the app opens. The first time there is nothing saved,
  /// so the three sample candidates stay.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('election');
    if (saved == null) return;

    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;

      final loadedCandidates = (data['candidates'] as List)
          .map((x) => Candidate.fromJson(x as Map<String, dynamic>))
          .toList();
      final loadedVoters =
      (data['voters'] as List).map((x) => x as String).toList();

      final loadedHistory = <VoteRecord>[];
      for (final x in data['history'] as List) {
        final m = x as Map<String, dynamic>;
        final matches = loadedCandidates.where((c) => c.name == m['candidate']);
        if (matches.isNotEmpty) {
          loadedHistory.add(
            VoteRecord(voter: m['voter'] as String, candidate: matches.first),
          );
        }
      }
      final loadedSize = (data['classSize'] as num).toInt();

      // Only now, when everything was read well, replace the data.
      candidates
        ..clear()
        ..addAll(loadedCandidates);
      voters
        ..clear()
        ..addAll(loadedVoters);
      voteHistory
        ..clear()
        ..addAll(loadedHistory);
      classSize = loadedSize;
    } catch (e) {
      // Damaged saved text: keep the sample data instead of crashing.
    }
  }
}