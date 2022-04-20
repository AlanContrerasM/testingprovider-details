import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

void main() {
  runApp(
    //4. wrap with notifierProvider
    ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home Page'),
      ),
      body: Column(children: [
        Row(
          children: const [
            Expanded(child: CheapWidget()),
            Expanded(child: ExpensiveWidget()),
          ],
        ),
        Row(children: const [Expanded(child: ObjectProviderWidget())]),
        Row(
          children: [
            TextButton(
              onPressed: () {
                context.read<ObjectProvider>().start();
              },
              child: const Text('Start'),
            ),
            TextButton(
              onPressed: () {
                context.read<ObjectProvider>().stop();
              },
              child: const Text('Stop'),
            ),
          ],
        )
      ]),
    );
  }
}

//1. create a base class, the expensive and cheap widget will extend it.
@immutable
class BaseObject {
  final String id;
  final String lastUpdated;
  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//Expensive Widget
@immutable
class ExpensiveObject extends BaseObject {}

//Cheap Widget
@immutable
class CheapoObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapoObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubs;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubs;

  CheapoObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  //provider constructor
  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapoObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  //lets override our notifyListener so we reset id everytime
  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((event) {
      //every second we are replacing the object with a new one.
      _cheapObject = CheapoObject();
      notifyListeners();
    });

    _expensiveObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 10),
    ).listen((event) {
      //every 10 seconds we are replacing the object with a new one.
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSubs.cancel();
    _expensiveObjectStreamSubs.cancel();
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );
    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(children: [
        const Text("Expensive Widget"),
        const Text("Last Updated"),
        Text(expensiveObject.lastUpdated)
      ]),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //you choose what you want as second paramenter.
    final cheapObject = context.select<ObjectProvider, CheapoObject>(
      (provider) => provider.cheapObject,
    );
    return Container(
      height: 100,
      color: Colors.orange,
      child: Column(children: [
        const Text("Cheap Widget"),
        const Text("Last Updated"),
        Text(cheapObject.lastUpdated)
      ]),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();

    return Container(
      height: 100,
      color: Colors.purple,
      child: Column(children: [
        const Text("Object Provider Widget"),
        const Text("Id"),
        Text(provider.id)
      ]),
    );
  }
}
