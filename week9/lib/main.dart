import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/anime_character.dart';
import 'providers/anime_character_provider.dart';
import 'repositories/anime_character_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  void _onAddPressed(BuildContext context) {
    final animeProvider = Provider.of<AnimeCharacterProvider>(
      context,
      listen: false,
    );
    final nameController = TextEditingController();
    final powerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add New Character"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: powerController,
                  decoration: InputDecoration(labelText: "Power Level"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Add"),
                onPressed: () {
                  final name = nameController.text;
                  final powerLevel = double.tryParse(powerController.text) ?? 0;
                  animeProvider.addCharacter(name, powerLevel);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _onEditPressed(BuildContext context, AnimeCharacter character) {
    final animeProvider = Provider.of<AnimeCharacterProvider>(
      context,
      listen: false,
    );
    final nameController = TextEditingController(text: character.name);
    final powerController = TextEditingController(
      text: character.powerLevel.toString(),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Character"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: powerController,
                  decoration: InputDecoration(labelText: "Power Level"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Update"),
                onPressed: () {
                  final name = nameController.text;
                  final powerLevel = double.tryParse(powerController.text) ?? 0;
                  animeProvider.updateCharacter(character.id, name, powerLevel);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animeProvider = Provider.of<AnimeCharacterProvider>(context);
    Widget content = const Text('');

    if (animeProvider.isLoading) {
      content = const CircularProgressIndicator();
    } else if (animeProvider.hasData) {
      final characters = animeProvider.charactersState!.data!;

      if (characters.isEmpty) {
        content = const Text("No data yet");
      } else {
        content = ListView.builder(
          itemCount: characters.length,
          itemBuilder:
              (context, index) => ListTile(
                title: Text(characters[index].name),
                subtitle: Text("Power Level: ${characters[index].powerLevel}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed:
                          () => _onEditPressed(context, characters[index]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          () =>
                              animeProvider.removeCharacter(characters[index]),
                    ),
                  ],
                ),
              ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () => _onAddPressed(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(child: content),
    );
  }
}

void main() {
  final animeRepository = FirebaseAnimeCharacterRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AnimeCharacterProvider(animeRepository),
      child: const MaterialApp(debugShowCheckedModeBanner: false, home: App()),
    ),
  );
}
