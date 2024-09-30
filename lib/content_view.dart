import 'package:flutter/material.dart';
import 'package:json_to_html_parser/helper/parser.dart';

class ContentView extends StatelessWidget {
  final Map<String, dynamic> content;
  const ContentView({required this.content});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => {Navigator.pop(context)},
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth,
                        maxHeight:
                            MediaQuery.of(context).size.height - 100 - 50,
                      ),
                      child: SingleChildScrollView(
                        child: JSONToWidgetParser(json: content),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
