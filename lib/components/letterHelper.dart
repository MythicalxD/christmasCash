class Letter {
  int id;
  String content;
  String reward;
  bool claimed;

  Letter({
    required this.id,
    required this.content,
    required this.reward,
    required this.claimed,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      content: json['content'],
      reward: json['reward'],
      claimed: json['claimed'],
    );
  }
}

class LetterList {
  List<Letter> letters;

  LetterList({required this.letters});

  factory LetterList.fromJson(Map<String, dynamic> json) {
    List<dynamic> letterList = json['c'];
    List<Letter> letters =
        letterList.map((letter) => Letter.fromJson(letter)).toList();

    return LetterList(letters: letters);
  }
}
