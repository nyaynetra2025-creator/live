import 'package:flutter/material.dart';


class AssistantPage extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(centerTitle: true, title: Text('Nyaynetra Assistant')),
body: Column(
children: [
Expanded(
child: ListView(
padding: EdgeInsets.all(16),
children: [
_botHeader(),
SizedBox(height: 12),
_messageBubble('I need help with cybercrime.', true),
SizedBox(height: 8),
_messageBubble('Of course. Cybercrime covers a wide range of issues. Could you please specify what kind of help you need?', false),
],
),
),
_inputBar(context),
],
),
);
}


Widget _botHeader() => Column(children: [
CircleAvatar(radius: 36, backgroundColor: Color(0xFF253D7A).withOpacity(0.08), child: Icon(Icons.smart_toy, size: 36, color: Color(0xFF253D7A))),
SizedBox(height: 8),
Text('Nyaynetra Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
SizedBox(height: 4),
Text('Hello, I am the Nyaynetra Assistant. How can I help you with Indian law today?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
]);


Widget _messageBubble(String text, bool isUser) => Align(
alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
child: Container(
constraints: BoxConstraints(maxWidth: 320),
padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
decoration: BoxDecoration(color: isUser ? Color(0xFFFFE0B2) : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
child: Text(text),
),
);


Widget _inputBar(BuildContext context) => SafeArea(
child: Container(
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
child: Row(children: [
Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type your legal question here...', border: InputBorder.none))),
IconButton(icon: Icon(Icons.send, color: Color(0xFF253D7A)), onPressed: () {}),
]),
),
);
}