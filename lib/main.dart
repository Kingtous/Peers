import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services.dart';

late final Future<void> initFuture;
late final Future<void> timeout;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFuture = initSvcs();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'Peers',
      theme: FluentThemeData(),
      debugShowCheckedModeBanner: false,
      routerConfig: kRoutes,
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.title = 'Peers'});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initFuture,
        builder: (context, data) {
          if (data.connectionState == ConnectionState.done) {
            Future.delayed(Duration.zero, () {
              context.replace(kPageIndex);
            });
            return const Offstage();
          } else if (data.hasError) {
            return Center(
              child: Text('Peers Error: ${data.error?.toString()}'),
            );
          }
          return const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Peers',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 8.0,
              ),
              SizedBox(width: 150, height: 150, child: ProgressRing()),
            ],
          ));
        });
  }
}
