import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';
import 'package:supbase_test/chat_view.dart';

class AuthView extends StatefulWidget {
  AuthView(this.client);

  final SupabaseClient client;

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _signIn = true;
  bool _loading = false;
  late SupabaseClient _supabaseClient= widget.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SUPABASE CHAT - ${_signIn ? 'SIGN IN' : 'SIGN UP'}',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(30),
            child: _signIn
                ? SignIn(signInToSupabase, _loading)
                : SignUp(signUpToSupabase, _loading),
          ),
          GestureDetector(
            onTap: swapAuth,
            child: Text(_signIn
                ? 'Don\'t have an account?'
                : 'Already have an account?',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }

  void signInToSupabase(String email, String password){
    if(email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _loading = true;
      });
      _supabaseClient.auth.signIn(email: email, password: password).then((value,
          {error}) {
        String message = 'Signed in!';

        if (error != null) {
          message = 'Sign in failed. Check username or password.';
          showSnackBar(context, message);
        } else {
          if (value.error?.message != null) {
            message = value.error!.message;
            showSnackBar(context, message);
          }else{
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) {
                return ChatView(_supabaseClient);
              })
            );
          }
        }

        setState(() {
          _loading = false;
        });
      });
    }
  }

  void signUpToSupabase(String email, String password){
    if(email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _loading = true;
      });
      _supabaseClient.auth.signUp(email, password).then((value, {error}) {
        String message = 'Signed up! Sign in after verifying email';

        if (error != null) {
          message = 'Sign up failed. Please try again.';
        } else {
          if (value.error?.message != null) {
            message = value.error!.message;
          }
        }
        showSnackBar(context, message);
        setState(() {
          _loading = false;
        });
      });
    }
  }

  void swapAuth(){
    setState(() {
      _signIn = !_signIn;
    });
  }

  void showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 2000),
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  SignIn(this.callback, this.loading);

  final Function(String, String) callback;
  final bool loading;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: _emailEditingController,
            decoration: InputDecoration(
              labelText: 'Email'
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: _passwordEditingController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: widget.loading
              ? CircularProgressIndicator()
              : ElevatedButton(
                onPressed: onPressed,
                child: Text('SIGN IN',
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
        ),
      ],
    );
  }

  void onPressed(){
    widget.callback(
      _emailEditingController.text,
      _passwordEditingController.text,
    );
  }
}

class SignUp extends StatefulWidget {
  SignUp(this.callback, this.loading);

  final Function(String, String) callback;
  final bool loading;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: _emailEditingController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: _passwordEditingController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: widget.loading
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: onPressed,
            child: Text('SIGN UP',
              style: TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onPressed(){
    widget.callback(
      _emailEditingController.text,
      _passwordEditingController.text,
    );
  }
}


