import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../repositories/anime_character_repository.dart';
import '../models/anime_character.dart';
import '../utils/async_value.dart';

class AnimeCharacterProvider extends ChangeNotifier {
  final AnimeRepository _repository;
  AsyncValue<List<AnimeCharacter>>? charactersState;

  AnimeCharacterProvider(this._repository) {
    fetchCharacters();
  }

  bool get isLoading =>
      charactersState != null &&
      charactersState!.state == AsyncValueState.loading;
  bool get hasData =>
      charactersState != null &&
      charactersState!.state == AsyncValueState.success;

  void fetchCharacters() async {
    try {
      charactersState = AsyncValue.loading();
      notifyListeners();

      charactersState = AsyncValue.success(await _repository.getCharacters());
      print("SUCCESS: list size ${charactersState!.data!.length.toString()}");
    } catch (error) {
      print("ERROR: $error");
      charactersState = AsyncValue.error(error);
    }
    notifyListeners();
  }

  void addCharacter(String name, double powerLevel) async {
    try {
      final newCharacter = await _repository.addCharacter(
        name: name,
        powerLevel: powerLevel,
      );
      final updatedList = <AnimeCharacter>[
        ...(charactersState?.data ?? []),
        newCharacter,
      ];
      charactersState = AsyncValue.success(
        updatedList,
      ); // Ensure the type is List<AnimeCharacter>
      notifyListeners();
    } catch (error) {
      print("ADD ERROR: $error");
      fetchCharacters();
    }
  }

  void removeCharacter(AnimeCharacter character) async {
    try {
      final currentList = charactersState?.data ?? [];
      charactersState = AsyncValue.success(
        currentList.where((p) => p.id != character.id).toList(),
      );
      notifyListeners();

      final url =
          '${FirebaseAnimeCharacterRepository.baseUrl}/${FirebaseAnimeCharacterRepository.charactersCollection}/${character.id}.json';
      await http.delete(Uri.parse(url));
    } catch (error) {
      print("REMOVE ERROR: $error");
      fetchCharacters();
    }
  }
}
