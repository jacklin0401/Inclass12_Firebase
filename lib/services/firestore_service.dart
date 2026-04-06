import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final _ref = FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async => await _ref.add(item.toMap());

  Stream<List<Item>> streamItems() => _ref.snapshots().map(
    (snap) => snap.docs.map((d) => Item.fromMap(d.id, d.data())).toList(),
  );

  Future<void> updateItem(Item item) async => await _ref.doc(item.id).update(item.toMap());

  Future<void> deleteItem(String id) async => await _ref.doc(id).delete();
}