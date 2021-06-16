import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';
import 'package:supbase_test/chat_view.dart';
import 'auth_view.dart';

void main() async {
  await dotenv.load(fileName: "production.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_KEY']!
  );

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


