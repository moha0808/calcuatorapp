import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Calculator",
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade200,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _expression = "";
  List<String> _history = []; // store history

  void _onButtonClick(String value) {
    setState(() {
      if (value == "C") {
        _output = "0";
        _expression = "";
      } else if (value == "=") {
        try {
          String result = _calculateResult(_expression);
          _history.add("$_expression = $result"); // save to history
          _output = result;
          _expression = result;
        } catch (e) {
          _output = "Error";
          _expression = "";
        }
      } else {
        _expression += value;
        _output = _expression;
      }
    });
  }

  String _calculateResult(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      final result = _evalExpression(expr);
      return result.toString();
    } catch (_) {
      return "Error";
    }
  }

  double _evalExpression(String expr) {
    List<String> tokens =
        expr.split(RegExp(r'([+\-*/])')).map((e) => e.trim()).toList();
    List<String> operators = expr
        .split(RegExp(r'[0-9.]+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    double result = double.parse(tokens[0]);
    for (int i = 0; i < operators.length; i++) {
      String op = operators[i];
      double num = double.parse(tokens[i + 1]);
      if (op == '+') result += num;
      if (op == '-') result -= num;
      if (op == '*') result *= num;
      if (op == '/') result /= num;
    }
    return result;
  }

  final List<String> buttons = [
    "C", "÷", "×", "⌫",
    "7", "8", "9", "-",
    "4", "5", "6", "+",
    "1", "2", "3", "=",
    "0", ".", ""
  ];

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            const Text(
              "History",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("No history yet"))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _history[index],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          )
        ],
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                maxLines: 2,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // Buttons
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                String btn = buttons[index];
                if (btn.isEmpty) return const SizedBox();
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isOperator(btn) ? Colors.deepPurple : Colors.white,
                    foregroundColor:
                        _isOperator(btn) ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (btn == "⌫") {
                      setState(() {
                        if (_expression.isNotEmpty) {
                          _expression =
                              _expression.substring(0, _expression.length - 1);
                          _output = _expression.isEmpty ? "0" : _expression;
                        }
                      });
                    } else {
                      _onButtonClick(btn);
                    }
                  },
                  child: Text(
                    btn,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isOperator(String x) {
    return (x == "÷" || x == "×" || x == "-" || x == "+" || x == "=");
  }
}
