import 'package:flutter/material.dart';
import 'package:notes/screens/note/SharedNotesScreen.dart';
import 'package:notes/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/note_service.dart';
import '../../models/note.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NoteService _noteService = NoteService();
  List<Note> notes = [];
  List<Note> allNotes = []; // ✅ pour garder toutes les notes
  bool loading = true;
  bool modalOpen = false;
  Note? editing;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isPublic = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => loading = true);
    try {
      allNotes = await _noteService.getNotes();
      notes = List.from(allNotes); // copie pour l'affichage
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  void _openModal([Note? note]) {
    setState(() {
      editing = note;
      titleController.text = note?.title ?? '';
      contentController.text = note?.contentMd ?? '';
      isPublic = note?.isPublic ?? false;
      modalOpen = true;
    });
  }

  Future<void> _saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty) return;

    try {
      if (editing != null) {
        editing!.title = title;
        editing!.contentMd = content;
        editing!.isPublic = isPublic;
        await _noteService.updateNote(editing!);
      } else {
        final newNote =
            await _noteService.createNote(title, content, isPublic: isPublic);
        allNotes.insert(0, newNote);
        notes.insert(0, newNote);
      }
      setState(() => modalOpen = false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    _loadNotes();
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await _noteService.deleteNote(note.id);
      allNotes.removeWhere((n) => n.id == note.id);
      notes.removeWhere((n) => n.id == note.id);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _shareNote(Note note) async {
    try {
      if (note.isPublic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cette note est déjà publique.')),
        );
        return;
      }

      final token = await NoteService().shareNotePublic(note.id);
      setState(() => note.isPublic = true);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Lien public créé'),
          content: Text(
              'Lien public: ${Constants.apiBaseUrl.replaceAll('/auth', '')}/public/$token'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du partage: $e')),
      );
    }
  }

  void _filterNotes(String titleKeyword, String contentKeyword) {
    setState(() {
      notes = allNotes.where((note) {
        final matchesTitle = note.title
            .toLowerCase()
            .contains(titleKeyword.toLowerCase());
        final matchesContent = note.contentMd
            .toLowerCase()
            .contains(contentKeyword.toLowerCase());
        return matchesTitle && matchesContent;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    String titleSearch = '';
    String contentSearch = '';

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notes',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SharedNotesScreen()),
                            );
                          },
                          child: const Text('Partagées'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            await authProvider.logout(context: context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Recherche par titre
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher par titre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    titleSearch = value;
                    _filterNotes(titleSearch, contentSearch);
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
                    _filterNotes(titleSearch, contentSearch);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                    ? const Center(child: Text('Aucune note.'))
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
                          itemCount: notes.length,
                          itemBuilder: (_, index) {
                            final note = notes[index];
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(note.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 20, color: Colors.green),
                                              onPressed: () => _openModal(note),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 20, color: Colors.red),
                                              onPressed: () => _deleteNote(note),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.share,
                                                  size: 20, color: Colors.blue),
                                              onPressed: () => _shareNote(note),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(note.contentMd,
                                        maxLines: 6, overflow: TextOverflow.ellipsis),
                                    const Spacer(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openModal(),
        child: const Icon(Icons.add),
      ),
      bottomSheet: modalOpen
          ? Container(
              color: Colors.black26,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Titre'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contentController,
                            maxLines: 6,
                            decoration:
                                const InputDecoration(labelText: 'Contenu'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                  value: isPublic,
                                  onChanged: (val) {
                                    setState(() => isPublic = val ?? false);
                                  }),
                              const Text('Public')
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    setState(() => modalOpen = false);
                                  },
                                  child: const Text('Annuler')),
                              ElevatedButton(
                                  onPressed: _saveNote,
                                  child: const Text('Enregistrer')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
