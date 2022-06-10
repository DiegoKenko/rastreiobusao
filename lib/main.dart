import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';
import 'package:rastreiobusao/firebase/realtime.dart';
import 'firebase/firestore.dart';
import 'dart:io';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
  bool saida = true;
  bool internet = false;
  bool localizacao = false;
  Color idaCor = Colors.orange;
  Color voltaCor = const Color.fromARGB(255, 0, 126, 2);
  Color corPad1 = const Color(0xFF373D69);
  Color corPad2 = Colors.white;

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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 126, 158),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(border: bordaBrTB()),
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(),
                card(
                  'SAÍDA',
                  MediaQuery.of(context).size.width * 0.45,
                  40,
                  () {
                    setState(() {
                      saida = true;
                    });
                  },
                  saida ? corPad1 : corPad2,
                ),
                card(
                  'CHEGADA',
                  MediaQuery.of(context).size.width * 0.45,
                  40,
                  () {
                    setState(() {
                      saida = false;
                    });
                  },
                  saida ? corPad2 : corPad1,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'ESCOLHA SUA ROTA:',
              style: TextStyle(color: corPad2, letterSpacing: 3),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: bordaBrTB()),
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
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'ESCOLHA SEU BUSÃO:',
              style: TextStyle(color: corPad2, letterSpacing: 3),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: bordaBrTB(),
            ),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: FutureBuilder(
                future: buscaBusao(),
                builder: (context, snap) {
                  if (todosBusao.isNotEmpty) {
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
          Row(
            children: [
              Container(
                height: 150,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipOval(
                          child: FutureBuilder(
                            future: Geolocator.isLocationServiceEnabled(),
                            builder: (context, AsyncSnapshot<bool> snap) {
                              if (snap.hasData) {
                                return Material(
                                  color: snap.data! ? Colors.green : Colors.red,
                                  child: InkWell(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: snap.data!
                                          ? const Icon(Icons.location_on,
                                              color: Colors.white)
                                          : const Icon(
                                              Icons.location_off,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipOval(
                          child: FutureBuilder(
                            future: internetAtiva(),
                            builder: (context, AsyncSnapshot<bool> snap) {
                              if (snap.hasData) {
                                return Material(
                                  color: snap.data! ? Colors.green : Colors.red,
                                  child: InkWell(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: snap.data!
                                          ? const Icon(Icons.wifi,
                                              color: Colors.white)
                                          : const Icon(
                                              Icons.wifi_off,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ClipOval(
                    child: StreamBuilder(
                      stream: Realtime().statusConexao(),
                      builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
                        if (snap.hasData) {
                          return Material(
                            color: snap.data!.snapshot.value as bool
                                ? Colors.green
                                : Colors.white,
                            child: InkWell(
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Icon(
                                  Icons.sync_outlined,
                                  color: corPad1,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _getStremLocation() async {
    _currentPositionStream = Geolocator.getPositionStream(
      intervalDuration: const Duration(seconds: 4),
      desiredAccuracy: LocationAccuracy.high,
    ).listen((event) {
      location = LatLng(event.latitude, event.longitude);
      if (rotaAtiva && busaoAtivo) {
        Realtime().attLocalizacao(rotaAtual, busaoAtual, location);
      }
    });
  }

  Future<void> buscaRotas() async {
    todasRotas = await Firestore().todasRotas(!saida);
  }

  Future<void> buscaBusao() async {
    todosBusao = await Firestore().todosBusao();
  }

  Widget cardRota(Rota rota) {
    return Container(
      decoration: BoxDecoration(
        color: rotaAtiva
            ? rotaAtual.id != rota.id
                ? corPad2
                : corPad1
            : corPad2,
        border: Border.all(
          color: corPad1,
          width: 3,
        ),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(
        left: 15,
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      child: GestureDetector(
        child: Card(
          child: Center(
            child: Text(
              rota.nome!.toUpperCase(),
              style: TextStyle(
                fontStyle: FontStyle.normal,
                color: corPad1,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            rotaAtual = rota;
            rotaAtiva = true;
          });
        },
      ),
    );
  }

  Widget cardBusao(Busao busao) {
    return Container(
      decoration: BoxDecoration(
        color: busaoAtivo
            ? busaoAtual.placa != busao.placa
                ? corPad2
                : corPad1
            : corPad2,
        border: Border.all(
          color: corPad1,
          width: 3,
        ),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(
        left: 15,
      ),
      width: MediaQuery.of(context).size.width * 0.5,
      child: GestureDetector(
        child: Card(
          child: Center(
            child: Text(
              busao.placa!,
              style: TextStyle(
                color: corPad1,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            busaoAtivo = true;
            busaoAtual = busao;
          });
        },
      ),
    );
  }

  Widget card(String texto, double width, double height, void Function()? onTap,
      corContainer) {
    return Container(
      decoration: BoxDecoration(
        color: corContainer,
        border: Border.all(
          color: corPad1,
          width: 3,
        ),
      ),
      margin: const EdgeInsets.only(right: 10, left: 10),
      width: width,
      height: height,
      child: GestureDetector(
        child: Card(
          color: corPad2,
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                color: corPad1,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Border bordaBrTB() {
    return Border(
      top: BorderSide(
        width: 2.0,
        color: corPad2,
      ),
      bottom: BorderSide(
        width: 2.0,
        color: corPad2,
      ),
    );
  }

  Future<bool> internetAtiva() async {
    try {
      final url = FirebaseFirestore.instance.app.options.databaseURL;
      final result = await InternetAddress.lookup(url!);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}
