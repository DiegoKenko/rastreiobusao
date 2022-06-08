import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
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
  bool ida = true;

  @override
  void dispose() {
    _currentPositionStream?.cancel();
    _currentPositionStream = null;
    super.dispose();
  }

  @override
  void initState() {
    _getStremLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColorTran(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.selected,
        MaterialState.focused,
        MaterialState.disabled
      };
      if (states.contains(MaterialState.selected)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    }

    Color getColor(Set<MaterialState> states) {
      return Color.fromARGB(255, 82, 168, 218);
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.yellow,
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: ida,
                      thumbColor: MaterialStateProperty.resolveWith(getColor),
                      trackColor:
                          MaterialStateProperty.resolveWith(getColorTran),
                      onChanged: (bool value1) {
                        setState(() {
                          ida = value1;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.amber,
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: FutureBuilder(
                  future: buscaRotas(),
                  builder: (context, snap) {
                    if (todasRotas.isNotEmpty) {
                      return Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todasRotas.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ListTile(
                                tileColor: Colors.grey,
                                title: Text(todasRotas[index].nome!),
                                subtitle: Text(
                                    todasRotas[index].ida! ? 'ida' : 'volta'),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Text('Carregando...');
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              color: Colors.blueAccent,
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: FutureBuilder(
                  future: buscaBusao(),
                  builder: (context, snap) {
                    if (todasRotas.isNotEmpty) {
                      return Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todasRotas.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ListTile(
                                tileColor: Colors.grey,
                                title: Text(todosBusao[index].placa!),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Text('Carregando...');
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Colors.indigo,
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              child: Center(),
            ),
          ],
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

  Future<void> buscaRotas() async {
    //todasRotas = await Firestore().todasRotas();
  }

  Future<void> buscaBusao() async {
    //todosBusao = await Firestore().todosBusao();
  }
}
