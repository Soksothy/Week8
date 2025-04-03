import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/anime_character.dart';
import '../models/dto/anime_character_dto.dart';

abstract class AnimeRepository {
  Future<AnimeCharacter> addCharacter({
    required String name,
    required double powerLevel,
  });
  Future<List<AnimeCharacter>> getCharacters();
  Future<AnimeCharacter> updateCharacter({
    required String id,
    required String name,
    required double powerLevel,
  });
}

class FirebaseAnimeCharacterRepository extends AnimeRepository {
  static const String baseUrl =
      'https://flutter-fire-base-2ac06-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const String charactersCollection = "anime_characters";
  static const String allCharactersUrl = '$baseUrl/$charactersCollection.json';

  @override
  Future<AnimeCharacter> addCharacter({
    required String name,
    required double powerLevel,
  }) async {
    Uri uri = Uri.parse(allCharactersUrl);

    final newCharacterData = {
      'name': name,
      'anime': 'Unknown',
      'powerLevel': powerLevel,
    };
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newCharacterData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add character');
    }

    final newId = json.decode(response.body)['name'];
    return AnimeCharacter(id: newId, name: name, powerLevel: powerLevel);
  }

  @override
  Future<List<AnimeCharacter>> getCharacters() async {
    Uri uri = Uri.parse(allCharactersUrl);
    final http.Response response = await http.get(uri);

    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load characters');
    }

    final data = json.decode(response.body);

    if (data == null) return [];

    // Convert array format to proper structure
    if (data is List) {
      return data.asMap().entries.where((entry) => entry.value != null).map((
        entry,
      ) {
        final item = entry.value;
        return AnimeCharacter(
          id: entry.key.toString(),
          name: item['name'] ?? 'Unknown',
          powerLevel: (item['powerLevel'] ?? 0).toDouble(),
        );
      }).toList();
    }

    if (data is Map<String, dynamic>) {
      return data.entries
          .where((entry) => entry.value != null)
          .map((entry) => AnimeCharacterDto.fromJson(entry.key, entry.value))
          .toList();
    }

    return [];
  }

  @override
  Future<AnimeCharacter> updateCharacter({
    required String id,
    required String name,
    required double powerLevel,
  }) async {
    final url = '$baseUrl/$charactersCollection/$id.json';
    Uri uri = Uri.parse(url);

    final updateData = {
      'name': name,
      'powerLevel': powerLevel,
      'anime': 'Unknown',
    };

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update character');
    }

    return AnimeCharacter(id: id, name: name, powerLevel: powerLevel);
  }
}
