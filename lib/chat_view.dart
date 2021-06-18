import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';
import 'package:supbase_test/auth_view.dart';


class ChatView extends StatefulWidget {
  ChatView(this.client);

  final SupabaseClient client;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late SupabaseClient _supabaseClient = widget.client;
  List<Map> displayMessages = List<Map>.empty(growable: true);
  late RealtimeSubscription messageSubscription;
  TextEditingController _textEditingController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    subscribeToMessages();
    loadMessages();

    super.initState();
  }

  @override
  void dispose() {
    _supabaseClient.removeSubscription(messageSubscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SUPABASE CHAT',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: _loading ? Loading() : Column(
        children: [
          MessageList(displayMessages),
          MessageFormField(submitMessage, _textEditingController)
        ],
      ),
    );
  }

  void submitMessage(){
    final String message = _textEditingController.text;
    if(message != ''){
      sendMessage(message);
      _textEditingController.text = '';
    }
  }

  void sendMessage(String message){
    String username = _supabaseClient.auth.currentUser!.email;
    username = username.split('@').first;

    _supabaseClient.from('messages').insert(
      {
        'text': message,
        'username': username,
      }
    ).execute();
  }

  void subscribeToMessages(){
    messageSubscription = _supabaseClient.from('messages')
        .on(SupabaseEventTypes.insert, (payload) {
          setState(() {
            displayMessages.insert(0, payload.newRecord);
          });
        })
        .on(SupabaseEventTypes.delete, (payload) {
          setState(() {
            displayMessages
                .removeWhere((element) => element['id'] == payload.oldRecord['id']);
          });
        }).subscribe();
  }

  void loadMessages(){
    _supabaseClient.from('messages').select().execute().then((clientMessages) {
      setState(() {
        displayMessages = List<Map>.from(clientMessages.data).reversed.toList();
        _loading = false;
      });
    });
  }

  void signOut(){
    _supabaseClient.auth.signOut().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed out.'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return AuthView(_supabaseClient);
        })
      );
    });
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(this.message);

  final Map message;

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(
      children: [
        TextSpan(
          text: message['username'] + ' ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
          ),
        ),
        TextSpan(
          text: message['text'],
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ]
    ));
  }
}

class MessageList extends StatelessWidget {
  const MessageList(this.displayMessages);

  final List<Map> displayMessages;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          reverse: true,
          children: displayMessages.map((message) {
            return ChatMessage(message);
          }).toList(),
        ),
      ),
    );
  }
}

// This is a problematic Widget, but I can't be bothered right now
class MessageFormField extends StatelessWidget {
  MessageFormField(this.submitMessage, this.textEditingController);

  final TextEditingController textEditingController;
  final Function submitMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,0,5,5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: EdgeInsets.only(right: 5),
              child: TextFormField(
                onEditingComplete: () => submitMessage(),
                autofocus: true,
                controller: textEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder()
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              child: Icon(Icons.send),
              onPressed: () => submitMessage(),
            ),
          ),
        ],
      ),
    );
  }
}


class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}


