import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rastreiobusao/class/rota.dart';

class Firestore {
  Future<List<Rota>> todasRotas() async {
    List<Rota> rotas = [];
    var x = await FirebaseFirestore.instance.collection('rotas').get();
    for (var element in x.docs) {
      rotas.add(Rota.fromMap(element.data()));
    }
    return rotas;
  }

  Future<List<Rota>> todosBusao() async {
    List<Rota> rotas = [];
    var x = await FirebaseFirestore.instance.collection('busao').get();
    for (var element in x.docs) {
      rotas.add(Rota.fromMap(element.data()));
    }
    return rotas;
  }
}
