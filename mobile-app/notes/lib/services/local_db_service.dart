import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();
  
  static const String notesBox = 'notes';
  static const String pendingOpsBox = 'pending_operations';
  static const String authBox = 'auth_data';
  
  Future<void> init() async {
    try {
      // Initialisation de Hive
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      
      // Ouverture des boxes (elles seront créées si elles n'existent pas)
      await Hive.openBox(authBox);
      await Hive.openBox(notesBox);
      await Hive.openBox(pendingOpsBox);
      
      print('Hive initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de Hive: $e');
    }
  }
  
  // Méthodes pour les données d'authentification
  Future<void> saveAuthData(String key, dynamic value) async {
    final box = Hive.box(authBox);
    await box.put(key, value);
  }
  
  Future<dynamic> getAuthData(String key) async {
    final box = Hive.box(authBox);
    return box.get(key);
  }
  
  Future<void> removeAuthData(String key) async {
    final box = Hive.box(authBox);
    await box.delete(key);
  }
  
  Future<void> clearAllAuthData() async {
    final box = Hive.box(authBox);
    await box.clear();
  }
  
  // Méthodes pour les notes (seront utilisées plus tard)
  Future<void> saveNote(String id, dynamic noteData) async {
    final box = Hive.box(notesBox);
    await box.put(id, noteData);
  }
  
  Future<dynamic> getNote(String id) async {
    final box = Hive.box(notesBox);
    return box.get(id);
  }
  
  Future<List<dynamic>> getAllNotes() async {
    final box = Hive.box(notesBox);
    return box.values.toList();
  }
  
  Future<void> deleteNote(String id) async {
    final box = Hive.box(notesBox);
    await box.delete(id);
  }
  
  Future<void> clearAllNotes() async {
    final box = Hive.box(notesBox);
    await box.clear();
  }
  
  // Méthodes pour les opérations en attente (offline)
  Future<void> addPendingOperation(String operationType, dynamic data) async {
    final box = Hive.box(pendingOpsBox);
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, {
      'type': operationType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<List<dynamic>> getPendingOperations() async {
    final box = Hive.box(pendingOpsBox);
    return box.values.toList();
  }
  
  Future<void> removePendingOperation(String id) async {
    final box = Hive.box(pendingOpsBox);
    await box.delete(id);
  }
  
  Future<void> clearAllPendingOperations() async {
    final box = Hive.box(pendingOpsBox);
    await box.clear();
  }
  
  // Méthode pour vider toutes les données
  Future<void> clearAllData() async {
    await clearAllAuthData();
    await clearAllNotes();
    await clearAllPendingOperations();
  }
}