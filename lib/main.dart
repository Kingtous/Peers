import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:keta_peers/base/services/webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'Peers',
      theme: FluentThemeData(),
      routerConfig: kRoutes,
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final Future<void> initFuture;
  late final Future<void> timeout;
  var errorMessage = "";
  @override
  void initState() {
    super.initState();
    initFuture = initSvcs();
    timeout = Future.delayed(const Duration(milliseconds: 500));
    final cxt = WeakReference(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initFuture.then((_) {
        timeout.then((value) => {initdSvcs(value, cxt.target)});
      }).catchError((err) {
        setState(() {
          errorMessage = err.toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Peers',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(width: 150, height: 150, child: ProgressRing()),
      ],
    ));
  }
}
