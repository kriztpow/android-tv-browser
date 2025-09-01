import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

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
  final FocusNode _urlFocusNode = FocusNode();

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
      
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: url,
          phoneMode: _phoneMode,
          showCursor: _showCursor,
        ),
      ));
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
              focusNode: _urlFocusNode,
              decoration: InputDecoration(
                labelText: 'URL',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _navigateToWebView,
                ),
              ),
              onSubmitted: (_) => _navigateToWebView(),
            ),
            
            const SizedBox(height: 20),
            
            const Text('Opciones:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
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

class WebViewPage extends StatefulWidget {
  final String url;
  final bool phoneMode;
  final bool showCursor;
  
  const WebViewPage({
    Key? key,
    required this.url,
    required this.phoneMode,
    required this.showCursor,
  }) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.phoneMode) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              if (widget.phoneMode) {
                _controller.setUserAgent(
                  "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36"
                );
              }
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            gestureNavigationEnabled: true,
          ),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          
          if (widget.showCursor)
            Positioned(
              top: 100,
              right: 50,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mouse,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
