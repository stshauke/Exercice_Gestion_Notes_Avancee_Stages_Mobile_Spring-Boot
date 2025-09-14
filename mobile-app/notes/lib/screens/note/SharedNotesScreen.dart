import 'package:flutter/material.dart';
import 'package:notes/screens/note/NotesListScreen.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';
import '../../providers/auth_provider.dart';

class SharedNotesScreen extends StatefulWidget {
  const SharedNotesScreen({Key? key}) : super(key: key);

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  List<Note> sharedNotes = [];
  List<Note> allSharedNotes = []; // ✅ pour garder toutes les notes
  bool loading = true;

  String titleSearch = '';
  String contentSearch = '';

  @override
  void initState() {
    super.initState();
    _loadSharedNotes();
  }

  Future<void> _loadSharedNotes() async {
    setState(() => loading = true);
    try {
      final notes = await NoteService().getSharedNotes();
      allSharedNotes = notes;
      _filterNotes(); // appliquer le filtre initial
    } catch (e) {
      print('Erreur: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _filterNotes() {
    setState(() {
      sharedNotes = allSharedNotes.where((note) {
        final matchesTitle =
            note.title.toLowerCase().contains(titleSearch.toLowerCase());
        final matchesContent =
            note.contentMd.toLowerCase().contains(contentSearch.toLowerCase());
        return matchesTitle && matchesContent;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesListScreen()),
                );
              },
              child: const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Notes Partagées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      // Recherche par titre
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Rechercher par titre',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          titleSearch = value;
                          _filterNotes();
                        },
                      ),
                      const SizedBox(height: 8),
                      // Recherche par contenu
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Rechercher par contenu',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          contentSearch = value;
                          _filterNotes();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: sharedNotes.isEmpty
                      ? const Center(child: Text('Aucune note partagée.'))
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: sharedNotes.length,
                            itemBuilder: (_, index) {
                              final note = sharedNotes[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(note.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Expanded(
                                          child: Text(note.contentMd,
                                              maxLines: 6,
                                              overflow: TextOverflow.ellipsis)),
                                      const SizedBox(height: 6),
                                      Text(note.isPublic ? '🔗 Public' : '👥 Privé',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.blue)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
