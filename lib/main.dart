import 'package:dailyneedsserver/screens/homeScreen/homeScreen.dart';
import 'package:dailyneedsserver/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => IsInList()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple.shade600,
      statusBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      title: 'DN Shops',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreenWindow.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        SplashScreenWindow.id: (context) => SplashScreenWindow(),
      },
    );
  }
}
