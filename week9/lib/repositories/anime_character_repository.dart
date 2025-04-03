import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/anime_character.dart';

abstract class AnimeRepository {
  Future<AnimeCharacter> addCharacter({
    required String name,
    required double powerLevel,
  });
  Future<List<AnimeCharacter>> getCharacters();
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

    // Handle array response format
    if (data is List) {
      return data
          .where((item) => item != null) // Filter out null entries
          .map(
            (item) => AnimeCharacter(
              id: item['id'] ?? 'unknown',
              name: item['name'] ?? 'Unknown',
              powerLevel: (item['powerLevel'] ?? 0).toDouble(),
            ),
          )
          .toList();
    }

    // Handle map response format (fallback)
    if (data is Map<String, dynamic>) {
      return data.entries
          .map((entry) => AnimeCharacterDto.fromJson(entry.key, entry.value))
          .toList();
    }

    print("ERROR: Unexpected response format: $data");
    return [];
  }
}
