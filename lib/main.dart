import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_visiting_card_mvc/pages/homepage.dart';
import 'package:virtual_visiting_card_mvc/pages/camera_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:virtual_visiting_card_mvc/pages/form_page.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';
import 'package:virtual_visiting_card_mvc/pages/contact_details_page.dart';
import 'package:virtual_visiting_card_mvc/pages/auth_wrapper.dart';
import 'package:virtual_visiting_card_mvc/pages/login_page.dart';
import 'package:virtual_visiting_card_mvc/pages/register_page.dart';
import 'package:virtual_visiting_card_mvc/pages/forgot_password_page.dart';
import 'package:virtual_visiting_card_mvc/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Visiting Card',
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
    initialLocation: '/',
    routes: [
      // Auth Wrapper (acts as router based on auth state)
      GoRoute(
        path: '/',
        name: AuthWrapper.routeName,
        builder: (context, state) => const AuthWrapper(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: RegisterPage.routeName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: ForgotPasswordPage.routeName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Home and Profile Routes
      GoRoute(
        path: '/home',
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'profile',
            name: ProfilePage.routeName,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            name: ContactDetailsPage.routeName,
            path: 'details/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return ContactDetailsPage(id: id);
            },
          ),
          GoRoute(
            name: CameraPage.routeName,
            path: 'camera',
            builder: (context, state) => const CameraPage(),
            routes: [
              GoRoute(
                name: FormPage.routeName,
                path: 'form',
                builder: (context, state) => FormPage(contactModel: state.extra! as ContactModel),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}