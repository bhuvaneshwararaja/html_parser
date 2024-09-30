import 'package:flutter/material.dart';

enum HtmlTag {
  body,
  div,
  text,
  img,
  strong,
  span,
  em,
  a,
  ul,
  li,
  table,
  tr,
  td,
  th,
  input,
}

extension HtmlTagExtension on HtmlTag {
  String get name {
    switch (this) {
      case HtmlTag.body:
        return 'body';
      case HtmlTag.div:
        return 'div';
      case HtmlTag.text:
        return 'text';
      case HtmlTag.img:
        return 'img';
      case HtmlTag.strong:
        return 'strong';
      case HtmlTag.span:
        return 'span';
      case HtmlTag.em:
        return 'em';
      case HtmlTag.a:
        return 'a';
      case HtmlTag.ul:
        return 'ul';
      case HtmlTag.li:
        return 'li';
      case HtmlTag.table:
        return 'table';
      case HtmlTag.tr:
        return 'tr';
      case HtmlTag.td:
        return 'td';
      case HtmlTag.th:
        return 'th';
      case HtmlTag.input:
        return 'input';
    }
  }

  static HtmlTag? fromString(String name) {
    switch (name) {
      case 'body':
        return HtmlTag.body;
      case 'div':
        return HtmlTag.div;
      case 'text':
        return HtmlTag.text;
      case 'img':
        return HtmlTag.img;
      case 'strong':
        return HtmlTag.strong;
      case 'span':
        return HtmlTag.span;
      case 'em':
        return HtmlTag.em;
      case 'a':
        return HtmlTag.a;
      case 'ul':
        return HtmlTag.ul;
      case 'li':
        return HtmlTag.li;
      case 'table':
        return HtmlTag.table;
      case 'tr':
        return HtmlTag.tr;
      case 'td':
        return HtmlTag.td;
      case 'th':
        return HtmlTag.th;
      case 'input':
        return HtmlTag.input;
      default:
        return null;
    }
  }
}

class JSONToWidgetParser extends StatelessWidget {
  final Map<String, dynamic> json;

  const JSONToWidgetParser({Key? key, required this.json}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return parseJsonToWidget(json);
  }

  Widget parseJsonToWidget(Map<String, dynamic> json) {
    try {
      final type = HtmlTagExtension.fromString(json['type'] as String? ?? '');
      switch (type) {
        case HtmlTag.body:
        case HtmlTag.div:
          return Wrap(
            children: (json['children'] as List?)
                    ?.map((child) =>
                        parseJsonToWidget(child as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        case HtmlTag.text:
          return Text(
            json['value'] as String? ?? '',
            style: const TextStyle(fontSize: 16),
          );
        case HtmlTag.img:
          return Image.network(
            json["attributes"]?["src"] as String? ?? "",
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          );
        case HtmlTag.strong:
          return Text(
            ' ${json['children']?[0]?['value'] as String? ?? ''} ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        case HtmlTag.span:
        case HtmlTag.em:
        case HtmlTag.a:
          return RichText(
            text: parseJsonToWidgetAsTextSpan(json),
            textAlign: TextAlign.start,
            textScaleFactor: 1.0,
          );
        case HtmlTag.ul:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (json['children'] as List?)
                    ?.map((child) =>
                        parseJsonToWidget(child as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        case HtmlTag.li:
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Flexible(
                  child: parseJsonToWidget((json['children'] as List?)
                          ?.firstOrNull as Map<String, dynamic>? ??
                      {})),
            ],
          );
        case HtmlTag.table:
          return Table(
            border: parseTableBorder(json['attributes']?['border'] as String?),
            defaultColumnWidth: const FlexColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: (json['children'] as List<dynamic>?)?.expand((child) {
                  if (child is List<dynamic>) {
                    return child.map<TableRow>((nestedChild) {
                      if (nestedChild is Map<String, dynamic>) {
                        return parseJsonToTableRow(nestedChild);
                      }
                      return TableRow(children: []);
                    });
                  }
                  return <TableRow>[];
                }).toList() ??
                [],
          );
        case HtmlTag.tr:
          return const SizedBox.shrink();
        case HtmlTag.td:
        case HtmlTag.th:
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ((json['children'] as List?)?.isNotEmpty ?? false)
                ? parseJsonToWidget(
                    (json['children'] as List).first as Map<String, dynamic>)
                : const SizedBox.shrink(),
          );
        case HtmlTag.input:
          return parseInputWidget(json);
        default:
          return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint('Error parsing JSON to widget: $e');
      return const SizedBox.shrink();
    }
  }

  Widget parseInputWidget(Map<String, dynamic> json) {
    try {
      final type = HtmlTagExtension.fromString(
          json['attributes']?['type'] as String? ?? 'text');
      String? placeholder = json['attributes']?['placeholder'] as String?;
      String? value = json['attributes']?['value'] as String?;

      switch (type) {
        case HtmlTag.text:
          return TextField(
            decoration: InputDecoration(
              hintText: placeholder,
            ),
            controller: TextEditingController(text: value),
          );
        default:
          return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint('Error parsing input widget: $e');
      return const SizedBox.shrink();
    }
  }

  TextSpan parseJsonToWidgetAsTextSpan(Map<String, dynamic> json) {
    try {
      final type = HtmlTagExtension.fromString(json['type'] as String? ?? '');
      switch (type) {
        case HtmlTag.text:
          return TextSpan(
            text: json['value'] as String? ?? '',
            style: const TextStyle(height: 1.2),
          );
        case HtmlTag.strong:
          return TextSpan(
            text: ' ',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1.2),
            children: (json['children'] as List?)
                    ?.map((child) => parseJsonToWidgetAsTextSpan(
                        child as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        case HtmlTag.span:
          return TextSpan(
            style: TextStyle(
              color: _parseColor(json['attributes']?['style'] as String?),
              height: 1.2,
            ),
            children: (json['children'] as List?)
                    ?.map((child) => parseJsonToWidgetAsTextSpan(
                        child as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        case HtmlTag.em:
          return TextSpan(
            style: const TextStyle(fontStyle: FontStyle.italic, height: 1.2),
            children: (json['children'] as List?)
                    ?.map((child) => parseJsonToWidgetAsTextSpan(
                        child as Map<String, dynamic>))
                    .toList() ??
                [],
          );
        case HtmlTag.a:
          return TextSpan(
            text:
                (json['children'] as List?)?.firstOrNull?['value'] as String? ??
                    '',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              height: 1.2,
            ),
          );
        default:
          return const TextSpan();
      }
    } catch (e) {
      debugPrint('Error parsing JSON to TextSpan: $e');
      return const TextSpan();
    }
  }

  TableRow parseJsonToTableRow(Map<String, dynamic> json) {
    try {
      if (HtmlTagExtension.fromString(json['type'] as String? ?? '') ==
          HtmlTag.tr) {
        return TableRow(
          children: (json['children'] as List?)
                  ?.map<Widget>((child) =>
                      parseJsonToWidget(child as Map<String, dynamic>))
                  .toList() ??
              [],
        );
      } else {
        return const TableRow(children: []);
      }
    } catch (e) {
      debugPrint('Error parsing JSON to TableRow: $e');
      return const TableRow(children: []);
    }
  }

  TableBorder? parseTableBorder(String? border) {
    if (border == null || border == '0') {
      return TableBorder.all(width: 0.0);
    } else {
      return TableBorder.all(color: Colors.black);
    }
  }

  Color? _parseColor(String? style) {
    if (style == null) return null;
    final colorMatch = RegExp(r'color: (#[0-9a-fA-F]{6});').firstMatch(style);
    if (colorMatch != null) {
      return Color(
        int.parse(colorMatch.group(1)!.substring(1), radix: 16) + 0xFF000000,
      );
    }
    return null;
  }
}
