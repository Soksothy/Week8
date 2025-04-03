class AnimeCharacterDto {
  static AnimeCharacter fromJson(String id, Map<String, dynamic> json) {
    return AnimeCharacter(
      id: id,
      name: json['name'],
      powerLevel: json['powerLevel'].toDouble(),
    );
  }

  static Map<String, dynamic> toJson(AnimeCharacter character) {
    return {'name': character.name, 'powerLevel': character.powerLevel};
  }
}

class AnimeCharacter {
  final String id;
  final String name;
  final double powerLevel;

  AnimeCharacter({
    required this.id,
    required this.name,
    required this.powerLevel,
  });

  @override
  bool operator ==(Object other) {
    return other is AnimeCharacter && other.id == id;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;
}
