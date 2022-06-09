import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';
import 'firebase/firestore.dart';

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
  LatLng location = const LatLng(-22.98, -44.99);
  List<Rota> todasRotas = [];
  List<Busao> todosBusao = [];
  late Rota rotaAtual;
  late Busao busaoAtual;
  bool rotaAtiva = false;
  bool busaoAtivo = false;
  bool ida = true;
  Color idaCor = Colors.orange;
  Color voltaCor = Color.fromARGB(255, 0, 126, 2);

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
      if (states.contains(MaterialState.selected)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    }

    Color getColor(Set<MaterialState> states) {
      return const Color.fromARGB(255, 82, 168, 218);
    }

    return Scaffold(
      backgroundColor: Color(0xFF57C0A4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: ListTile(
                leading: const Text(
                  'Caminho de ida até a Multitécnica',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                trailing: Switch(
                  inactiveThumbColor: idaCor,
                  activeColor: voltaCor,
                  inactiveTrackColor: idaCor,
                  value: ida,
                  onChanged: (bool value) {
                    setState(() {
                      ida = value;
                    });
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: ida ? voltaCor : idaCor,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: FutureBuilder(
                  future: buscaRotas(),
                  builder: (context, snap) {
                    if (todasRotas.isNotEmpty) {
                      return SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todasRotas.length,
                          itemBuilder: (context, index) {
                            return cardRota(todasRotas[index]);
                          },
                        ),
                      );
                    } else {
                      return const Text('Carregando...');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: FutureBuilder(
                  future: buscaBusao(),
                  builder: (context, snap) {
                    if (todasRotas.isNotEmpty) {
                      return SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todosBusao.length,
                          itemBuilder: (context, index) {
                            return cardBusao(todosBusao[index]);
                          },
                        ),
                      );
                    } else {
                      return const Text('Carregando...');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: ClipOval(
                  child: Material(
                    color: Colors.blue, // Button color
                    child: InkWell(
                      splashColor: Colors.red, // Splash color
                      onTap: () {},
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: busaoAtivo && rotaAtiva
                            ? Icon(
                                Icons.sync,
                                size: MediaQuery.of(context).size.width * 0.4,
                              )
                            : Icon(Icons.refresh_outlined,
                                size: MediaQuery.of(context).size.width * 0.2),
                      ),
                    ),
                  ),
                ),
              ),
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
    });
  }

  Future<void> buscaRotas() async {
    todasRotas = await Firestore().todasRotas(ida);
  }

  Future<void> buscaBusao() async {
    todosBusao = await Firestore().todosBusao();
  }

  Widget cardRota(Rota rota) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(right: 10, left: 10),
      width: MediaQuery.of(context).size.width * 0.7,
      child: GestureDetector(
        child: Card(
          child: Center(
            child: Text(
              rota.nome!.toUpperCase(),
              style: const TextStyle(
                fontStyle: FontStyle.normal,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          shadowColor: Colors.white,
          color: const Color(0xFF373D69),
        ),
        onTap: () {},
      ),
    );
  }

  Widget cardBusao(Busao busao) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(right: 10, left: 10),
      width: MediaQuery.of(context).size.width * 0.7,
      child: GestureDetector(
        child: Card(
          child: Center(
            child: Text(
              busao.placa!,
              style: const TextStyle(
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          shadowColor: Colors.white,
          color: const Color(0xFF373D69),
        ),
        onTap: () {},
      ),
    );
  }
}
