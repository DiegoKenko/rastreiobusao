import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';
import 'package:rastreiobusao/firebase/firestore.dart';
import 'package:rastreiobusao/firebase/realtime.dart';
import 'package:rastreiobusao/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'rastreiobusao',
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDZT5coXo6WlxWHoe4iZGLYkg8bq7xK1CM',
      appId: '1:519420295610:android:c3089dca57bbb2766b4583',
      messagingSenderId: '519420295610',
      projectId: 'multirotas-b3006',
      databaseURL: 'https://multirotas-b3006-default-rtdb.firebaseio.com',
      storageBucket: 'multirotas-b3006.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<Position>? _currentPositionStream;
  LatLng location = LatLng(-22.98, -44.99);
  List<Rota> todasRotas = [];
  List<Busao> todosBusao = [];

  @override
  void dispose() {
    _currentPositionStream?.cancel();
    _currentPositionStream = null;
    super.dispose();
  }

  @override
  void initState() {
    buscaRotas();
    buscaBusao();
    _getStremLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ListView()],
        ),
      ),
    );
  }

  _getStremLocation() async {
    _currentPositionStream = Geolocator.getPositionStream(
      intervalDuration: const Duration(seconds: 4),
      desiredAccuracy: LocationAccuracy.high,
    ).listen((event) {
      location = LatLng(event.latitude, event.longitude);
      //Realtime().attLocalizacao(rotaAtual, busaoAtual, location);
    });
  }

  void buscaRotas() async {
    Firestore().todasRotas().then((value) {
      todasRotas = value;
    });
  }

  void buscaBusao() async {
    Firestore().todosBusao().then((value) {
      todosBusao = value;
    });
  }
}
