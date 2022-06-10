/* Responsável por: 
  Enviar a localização do ônibus ao usuário.
*/
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';

class Realtime {
  void attLocalizacao(Rota idRota, Busao busao, LatLng latLng) async {
    FirebaseApp secondaryApp = Firebase.app('rastreiobusao');
    DatabaseReference ref = FirebaseDatabase.instanceFor(app: secondaryApp)
        .ref('localizacaoBusao/' + idRota.id!);

    await ref.set({
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'busao': busao.placa,
    });
  }

  statusConexao() {
    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
      } else {}
    });
  }
}
