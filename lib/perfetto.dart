import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Perfetto extends StatefulWidget {
  const Perfetto({Key? key}) : super(key: key);

  @override
  State<Perfetto> createState() => _PerfettoState();
}

class _PerfettoState extends State<Perfetto> {
  // static const _perfettoUrl = 'https://ui.perfetto.dev';

  // Url when running Perfetto locally following the instructions here:
  // https://perfetto.dev/docs/contributing/build-instructions#ui-development
  static const _perfettoUrl = 'http://10.0.2.2:10000/';

  late final Completer<WebViewController> _controllerCompleter;

  WebViewController? _controller;

  Completer<void>? _pageFinishedCompleter;

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<WebViewController>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _postMessage,
                  child: const Text('Post Message'),
                ),
              ],
            ),
          ),
          Expanded(
            child: WebView(
              debuggingEnabled: true,
              initialUrl: _perfettoUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) async {
                _controllerCompleter.complete(controller);
                _controller = controller;
              },
              javascriptChannels: <JavascriptChannel>{
                _javascriptChannel(context),
              },
              onPageStarted: (String url) {
                _pageFinishedCompleter = Completer();
                print('Page started loading: $url');
              },
              onPageFinished: (String url) async {
                print('Page finished loading: $url');
                _pageFinishedCompleter!.complete();
                // await _postMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postMessage() async {
    print('calling _postMessage');
    await _pageFinishedCompleter?.future;

    final result = await _controller?.runJavascriptReturningResult('''
function pingPerfetto() {
  MyJavascriptChannel.postMessage('pinging Perfetto');
  window.postMessage('PING', 'http://10.0.2.2:10000/');
}

function ping() {
  // const win = window.open('http://10.0.2.2:10000/');

  const timer = setInterval(() => pingPerfetto(), 5000); 
  
  const onMessageHandler = (evt) => {
    // The only event we get back is 'PING' - not 'PONG' like we are expecting.
    MyJavascriptChannel.postMessage('onMessageHandler: ' + evt.data);
  
    if (evt.data !== 'PONG') return;

    // We got a PONG, the UI is ready. 
    window.open('https://www.google.com');
    window.clearInterval(timer);
    window.removeEventListener('message', onMessageHandler); 
  };

  window.addEventListener('message', onMessageHandler);  
}

ping();
''');
    print('result: $result');
  }

  JavascriptChannel _javascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'MyJavascriptChannel',
      onMessageReceived: (JavascriptMessage message) {
        print('MyJavascriptChannel.onMessageReceived: ' + message.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
  }
}
