import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool phoneMode = prefs.getBool('phone_mode') ?? false;
  final bool showCursor = prefs.getBool('show_cursor') ?? false;
  
  runApp(MyApp(
    phoneMode: phoneMode,
    showCursor: showCursor,
  ));
}

class MyApp extends StatelessWidget {
  final bool phoneMode;
  final bool showCursor;
  
  const MyApp({
    Key? key,
    required this.phoneMode,
    required this.showCursor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Browser Vertical',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
        initialPhoneMode: phoneMode,
        initialShowCursor: showCursor,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final bool initialPhoneMode;
  final bool initialShowCursor;
  
  const HomePage({
    Key? key,
    required this.initialPhoneMode,
    required this.initialShowCursor,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _phoneMode;
  late bool _showCursor;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneMode = widget.initialPhoneMode;
    _showCursor = widget.initialShowCursor;
    _urlController.text = 'https://www.google.com';
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('phone_mode', _phoneMode);
    prefs.setBool('show_cursor', _showCursor);
  }

  void _navigateToWebView() {
    if (_urlController.text.isNotEmpty) {
      String url = _urlController.text;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      // En una app real aquí navegarías a la WebView
      print('Navegando a: $url');
      print('Modo teléfono: $_phoneMode');
      print('Mostrar cursor: $_showCursor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Browser Vertical'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _navigateToWebView,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('Opciones:', style: TextStyle(fontSize: 18)),
            
            SwitchListTile(
              title: const Text('Modo Teléfono (Vertical)'),
              value: _phoneMode,
              onChanged: (value) {
                setState(() {
                  _phoneMode = value;
                  _savePreferences();
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Mostrar Cursor'),
              value: _showCursor,
              onChanged: (value) {
                setState(() {
                  _showCursor = value;
                  _savePreferences();
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            Center(
              child: ElevatedButton(
                onPressed: _navigateToWebView,
                child: const Text('Navegar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
