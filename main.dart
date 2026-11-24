import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HfSiteApkApp());
}

class HfSiteApkApp extends StatelessWidget {
  const HfSiteApkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Propagação HF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const PropagationWebViewScreen(),
    );
  }
}

class PropagationWebViewScreen extends StatefulWidget {
  const PropagationWebViewScreen({super.key});

  @override
  State<PropagationWebViewScreen> createState() => _PropagationWebViewScreenState();
}

class _PropagationWebViewScreenState extends State<PropagationWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;

  static const String _targetUrl = 'https://antenaativa.com.br/mapa-de-propagacao/';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _hasError = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              if (mounted) setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Propagação HF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _hasError = false;
                _progress = 0;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100 && !_hasError)
            LinearProgressIndicator(value: _progress / 100.0),
          Expanded(
            child: _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, size: 48, color: Colors.amber),
                          const SizedBox(height: 12),
                          const Text(
                            'Não foi possível carregar o mapa agora. Verifique sua conexão ou tente novamente.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _hasError = false);
                              _controller.reload();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
