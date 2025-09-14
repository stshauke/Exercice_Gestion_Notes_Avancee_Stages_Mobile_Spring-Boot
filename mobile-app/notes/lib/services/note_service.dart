import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notes/utils/constants.dart';
import '../models/note.dart';
import 'auth_service.dart';

class NoteService {
  final AuthService _authService = AuthService();

  // 🔹 Récupérer toutes les notes de l'utilisateur
  Future<List<Note>> getNotes() async {
    final token = await _authService.getToken();
    final url = Uri.parse(Constants.notesUrl); // <-- utilise la constante notesUrl
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des notes');
    }
  }
  // 🔹 Nouvelle méthode : notes partagées
  Future<List<Note>> getSharedNotes() async {
  final token = await _authService.getToken();
  final url = Uri.parse('${Constants.apiBaseUrl.replaceAll('/auth', '')}/shares/all');
  final res = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Note(
      id: e['noteId'],
      title: e['noteTitle'],
      contentMd: e['noteContent'],
      isPublic: true, // toutes ces notes sont partagées
    )).toList();
  } else {
    throw Exception('Erreur lors du chargement des notes partagées');
  }
}

  // 🔹 Créer une nouvelle note
  Future<Note> createNote(String title, String content, {bool isPublic = false}) async {
    final token = await _authService.getToken();
    final url = Uri.parse(Constants.notesUrl); // <-- utilise la constante notesUrl
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'contentMd': content,
        'visibility': isPublic ? 'PUBLIC' : 'PRIVATE',
      }),
    );

    if (res.statusCode == 200) {
      return Note.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Erreur lors de la création de la note');
    }
  }

  // 🔹 Mettre à jour une note existante
  Future<Note> updateNote(Note note) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${Constants.notesUrl}/${note.id}');
    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': note.title,
        'contentMd': note.contentMd,
        'visibility': note.isPublic ? 'PUBLIC' : 'PRIVATE',
      }),
    );

    if (res.statusCode == 200) {
      return Note.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la note');
    }
  }

  // 🔹 Supprimer une note
  Future<void> deleteNote(int id) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${Constants.notesUrl}/$id');
    final res = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la note');
    }
  }
  Future<String> shareNotePublic(int noteId) async {
  final token = await _authService.getToken();
  final url = Uri.parse('${Constants.apiBaseUrl.replaceAll('/auth', '')}/shares/public/$noteId');
  
  final res = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data['urlToken']; // retourne le token public
  } else {
    throw Exception('Erreur lors du partage de la note');
  }
}

}
