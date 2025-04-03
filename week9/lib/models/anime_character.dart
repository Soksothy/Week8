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
