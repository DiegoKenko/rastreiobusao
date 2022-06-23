import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rastreiobusao/class/busao.dart';
import 'package:rastreiobusao/class/rota.dart';
import 'package:rastreiobusao/firebase/realtime.dart';
import 'package:wakelock/wakelock.dart';
import 'firebase/firestore.dart';
import 'package:flutter_background/flutter_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground.hasPermissions;
  FlutterBackgroundAndroidConfig androidConfig =
      const FlutterBackgroundAndroidConfig(
    notificationTitle: "rastreiobusao",
    notificationText: "Enviado localização em tempo real do ônibus",
    notificationImportance: AndroidNotificationImportance.High,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  bool success =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  await FlutterBackground.enableBackgroundExecution();
  Wakelock.enable();
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
  bool localizacao = false;
  Color idaCor = Colors.orange;
  Color voltaCor = const Color.fromARGB(255, 0, 126, 2);
  Color corPad1 = const Color(0xFF373D69);
  Color corPad2 = Colors.white;
  Color corPad3 = const Color.fromARGB(255, 255, 230, 1);

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
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF373D69), width: 4),
        ),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(5.0),
        child: Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 30),
                child: Text(
                  'SAINDO DO(A) :',
                  style: TextStyle(
                      color: corPad3,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                decoration: BoxDecoration(border: bordaBrTB()),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(),
                    card(
                      'PONTO FINAL',
                      MediaQuery.of(context).size.width * 0.45,
                      40,
                      () {
                        setState(() {
                          saida = true;
                        });
                      },
                      saida ? corPad3 : corPad2,
                    ),
                    card(
                      'MULTITÉCNICA',
                      MediaQuery.of(context).size.width * 0.45,
                      40,
                      () {
                        setState(() {
                          saida = false;
                        });
                      },
                      saida ? corPad2 : corPad3,
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
                  style: TextStyle(
                      color: corPad3,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                      color: corPad3,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold),
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: boxShadowRounded(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipOval(
                              child: FutureBuilder(
                                future: Geolocator.isLocationServiceEnabled(),
                                builder: (context, AsyncSnapshot<bool> snap) {
                                  if (snap.hasData) {
                                    if (snap.data!) {
                                      localizacao = true;
                                    } else {
                                      localizacao = false;
                                    }
                                    return Material(
                                      color: snap.data!
                                          ? Colors.green
                                          : Colors.red,
                                      child: InkWell(
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
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
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: boxShadowRounded(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 20),
                          child: ClipOval(
                            child: StreamBuilder(
                              stream: Realtime().statusConexao(),
                              builder:
                                  (context, AsyncSnapshot<DatabaseEvent> snap) {
                                if (snap.hasData) {
                                  return Material(
                                    color: snap.data!.snapshot.exists &&
                                            busaoAtivo &&
                                            localizacao &&
                                            rotaAtiva
                                        ? Colors.green
                                        : Colors.red,
                                    child: InkWell(
                                      child: SizedBox(
                                        width: 60,
                                        height: 60,
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
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Versão ' + snapshot.data!.version,
                          style: TextStyle(
                            color: Colors.yellow,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getStremLocation() async {
    _currentPositionStream = Geolocator.getPositionStream(
      intervalDuration: const Duration(seconds: 5),
      desiredAccuracy: LocationAccuracy.high,
    ).listen((event) {
      location = LatLng(event.latitude, event.longitude);
      if (rotaAtiva && busaoAtivo) {
        Realtime()
            .attLocalizacao(rotaAtual, busaoAtual, location, event.heading);
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
        boxShadow: boxShadow(),
        color: rotaAtiva
            ? rotaAtual.id != rota.id
                ? corPad2
                : corPad3
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
          elevation: 100,
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
          _currentPositionStream!.cancel();
          _currentPositionStream = null;
          _getStremLocation();
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
        boxShadow: boxShadow(),
        color: busaoAtivo
            ? busaoAtual.placa != busao.placa
                ? corPad2
                : corPad3
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
          elevation: 100,
          color: corPad2,
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
            busaoAtual = busao;
            busaoAtivo = true;
          });
        },
      ),
    );
  }

  Widget card(String texto, double width, double height, void Function()? onTap,
      corContainer) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadow(),
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
          elevation: 100,
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

  List<BoxShadow> boxShadow() {
    return [
      BoxShadow(
        color: corPad1,
        blurRadius: 2,
        offset: const Offset(-12, 6), // Shadow position
      ),
    ];
  }

  List<BoxShadow> boxShadowRounded() {
    return [
      BoxShadow(
        color: corPad1,
        blurRadius: 60,
        spreadRadius: 8,
        offset: const Offset(1, 1), // Shadow position
      ),
    ];
  }
}
