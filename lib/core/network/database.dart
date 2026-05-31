import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutri_scan/core/config/app_config.dart';
import 'package:nutri_scan/firebase_options.dart';

/// Inicializa o Firebase e configura a ligação à base de dados.
///
/// Chama [Firebase.initializeApp] com as opções padrão da plataforma.
/// Se a flag [AppConfig.useEmulator] estiver ativa, redireciona as chamadas
/// do Firestore para o emulador local em `127.0.0.1:8080`.
Future<void> initializeDatabase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (AppConfig.useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }
}

/// Fachada estática para aceder à instância do Firestore.
///
/// Fornece um ponto de acesso centralizado à base de dados através de
/// [Database.db], que expõe a instância [FirebaseFirestore] pronta a usar.
class Database {
  /// Instância única do Firestore utilizada em toda a aplicação.
  static final db = FirebaseFirestore.instance;
}