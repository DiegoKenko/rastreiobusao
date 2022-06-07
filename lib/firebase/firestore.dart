import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';

class Firestore {
  Future<List<Rota>> todasRotas() async {
    FirebaseApp secondaryApp = Firebase.app('rastreiobusao');
    FirebaseFirestore firestore =
        FirebaseFirestore.instanceFor(app: secondaryApp);

    List<Rota> rotas = [];
    var x = await firestore.collection('rotas').get();
    for (var element in x.docs) {
      rotas.add(Rota.fromMap(element.data()));
    }
    return rotas;
  }

  Future<List<Busao>> todosBusao() async {
    List<Busao> busao = [];
    var x = await FirebaseFirestore.instance.collection('busao').get();
    for (var element in x.docs) {
      busao.add(Busao.fromMap(element.data()));
    }
    return busao;
  }
}
