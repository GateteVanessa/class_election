class Candidate {
  final String name;
  int votes;

  Candidate({required this.name, this.votes = 0});

  // Part 2: a Candidate to a Map, and back.
  Map<String, dynamic> toJson() {
    return {'name': name, 'votes': votes};
  }

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'] as String,
      votes: (json['votes'] as num).toInt(),
    );
  }
}