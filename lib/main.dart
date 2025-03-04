import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_visiting_card_mvc/pages/homepage.dart';
import 'package:virtual_visiting_card_mvc/pages/camera_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:virtual_visiting_card_mvc/pages/form_page.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';
import 'package:virtual_visiting_card_mvc/pages/contact_details_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routerConfig: _router,
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }

  final _router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: HomePage.routeName,
        path: HomePage.routeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: ContactDetailsPage.routeName,
            path: '/details/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return ContactDetailsPage(id: id);
            },
          ),

          GoRoute(
            name: CameraPage.routeName,
            path: CameraPage.routeName,
            builder: (context, state) => const CameraPage(),
            routes: [
              GoRoute(
                name: FormPage.routeName,
                path: FormPage.routeName,
                builder: (context, state) => FormPage(contactModel: state.extra! as ContactModel),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
