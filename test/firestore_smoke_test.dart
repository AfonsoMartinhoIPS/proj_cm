import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  test('write and read a test document', () async {
    final db = FirebaseFirestore.instance;

    // Write
    await db.collection('_test').doc('smoke').set({
      'message': 'Firebase connected',
      'ts': FieldValue.serverTimestamp(),
    });

    // Read back
    final doc = await db.collection('_test').doc('smoke').get();
    expect(doc.exists, true);
    expect(doc.data()?['message'], 'Firebase connected');

    print('✓ Firestore OK — doc: ${doc.data()}');

    // Cleanup
    await db.collection('_test').doc('smoke').delete();
  });
}
