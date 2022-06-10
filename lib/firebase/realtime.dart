/* Responsável por: 
  Enviar a localização do ônibus ao usuário.
*/
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';

class Realtime {
  FirebaseDatabase instance =
      FirebaseDatabase.instanceFor(app: Firebase.app('rastreiobusao'));
  final controller = StreamController<bool>();

  void attLocalizacao(Rota idRota, Busao busao, LatLng latLng) async {
    DatabaseReference ref = instance.ref('localizacaoBusao/' + idRota.id!);
    await ref.set({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'busao': busao.placa,
    });
  }

  Stream<DatabaseEvent> statusConexao() {
    return instance.ref('localizacaoBusao').onValue;
  }
}
