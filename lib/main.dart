import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';
import 'package:supbase_test/chat_view.dart';
import 'auth_view.dart';

void main() async {
  await dotenv.load(fileName: "production.env");
  late String supabaseUrl;

  // For development purposes when testing locally on Android
  if(Platform.isAndroid){
    supabaseUrl = 'http://10.0.2.2:8989';
  }else{
    supabaseUrl = dotenv.env['SUPABASE_URL']!;
  }
  final SupabaseClient supabaseClient = SupabaseClient(
    supabaseUrl,
    dotenv.env['SUPABASE_KEY']!
  );

  runApp(MyApp(supabaseClient));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient;

  MyApp(this.supabaseClient);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPABASE EXPERIMENT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gapPadding: 1,
            borderSide: BorderSide()
          ),
        ),
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Home(supabaseClient),
    );
  }
}

class Home extends StatelessWidget {
  Home(this.supabaseClient);
  final SupabaseClient supabaseClient;

  @override
  Widget build(BuildContext context) {
    if(supabaseClient.auth.currentUser == null){
      return AuthView(supabaseClient);
    }else{
      return ChatView(supabaseClient);
    }
  }
}
