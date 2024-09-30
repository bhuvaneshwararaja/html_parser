import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_to_html_parser/content_view.dart';

class TextAreaWithSubmit extends StatefulWidget {
  @override
  _TextAreaWithSubmitState createState() => _TextAreaWithSubmitState();
}

class _TextAreaWithSubmitState extends State<TextAreaWithSubmit> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? jsonMap;
  bool enableLoading = false;

  Future<void> _handleSubmit() async {
    try {
      enableLoading = true;
      String inputText = _controller.text;
      print(inputText);

      final url = Uri.parse(
          "htmlToJSONParserendpoint");

      final Map<String, String> postData = {"htmlString": inputText};

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(postData),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentView(content: decodedJson),
          ),
        );
      } else {
        print("Failed with status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed with status code: ${response.statusCode}'),
        ));
      }

      _controller.clear();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid JSON format or network error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter your text here (in JSON format)',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        if (enableLoading)
          CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text('Submit'),
          ),
        SizedBox(height: 20),
      ],
    );
  }
}
