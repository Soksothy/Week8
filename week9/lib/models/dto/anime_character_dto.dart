import '../anime_character.dart';

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
