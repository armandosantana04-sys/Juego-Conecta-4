import 'package:conecta4_game/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'ui/screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.initAudioContext();
  runApp(const Connect4App());
}

class Connect4App extends StatelessWidget {
  const Connect4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conecta 4 - IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}