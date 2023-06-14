
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MarkdownGenerator(),
    );
  }
}

class MarkdownGenerator extends StatefulWidget {
  @override
  _MarkdownGeneratorState createState() => _MarkdownGeneratorState();
}

class _MarkdownGeneratorState extends State<MarkdownGenerator> {
  final TextEditingController _controller = TextEditingController();
  String _generatedMarkdown = '';

  void _applyFormatting(String formattingTag) {
    final int selectionStart = _controller.selection.start;
    final int selectionEnd = _controller.selection.end;
    final String selectedText =
        _controller.text.substring(selectionStart, selectionEnd);
    final String formattedText = '$formattingTag$selectedText$formattingTag';
    final int newSelectionStart = selectionStart + formattingTag.length;
    final int newSelectionEnd = selectionEnd + formattingTag.length;
    final String newText = _controller.text
        .replaceRange(selectionStart, selectionEnd, formattedText);

    setState(() {
      _controller.text = newText;
      _controller.selection = TextSelection(
        baseOffset: newSelectionStart,
        extentOffset: newSelectionEnd,
      );
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedMarkdown));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Markdown copied to clipboard')),
    );
  }

  @override
  void initState() {
    super.initState();
    // Register key event handlers for formatting functionality
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    // Remove key event handlers when the widget is disposed
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyB) {
          // Apply bold formatting when Control + B is pressed
          _applyFormatting('**');
        } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
          // Apply italic formatting when Control + I is pressed
          _applyFormatting('*');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markdown Generator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your text',
              ),
              onChanged: (text) {
                setState(() {
                  _generatedMarkdown = text;
                });
              },
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Bold'),
                onPressed: () {
                  _applyFormatting('**');
                },
              ),
              ElevatedButton(
                child: Text('Italic'),
                onPressed: () {
                  _applyFormatting('*');
                },
              ),
              ElevatedButton(
                child: Text('Underline'),
                onPressed: () {
                  _applyFormatting('<u>');
                },
              ),
            ],
          ),
          ElevatedButton(
            child: Text('Copy Markdown'),
            onPressed: _copyToClipboard,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Markdown(
                data: _generatedMarkdown,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  blockquote: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                    decoration: TextDecoration.none,
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14.0,
                    backgroundColor: Colors.grey.shade200,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
