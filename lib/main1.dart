// // =============================================================================
// // GETINLINE FLUTTER - main.dart
// // Application Entry Point with All Provider Configurations
// // =============================================================================

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'providers/auth_provider.dart';
// import 'providers/organization_provider.dart';
// import 'providers/professional_provider.dart';
// import 'providers/appointment_provider.dart';
// import 'services/notification_service.dart';
// import 'utils/app_theme.dart';
// import 'utils/app_router.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize Firebase
//   await Firebase.initializeApp();
  
//   // Initialize Notification Service
//   await NotificationService().initialize();
  
//   runApp(const GetInLineApp());
// }

// class GetInLineApp extends StatelessWidget {
//   const GetInLineApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Auth Provider
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
        
//         // Organization Provider
//         ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        
//         // Professional Provider
//         ChangeNotifierProvider(create: (_) => ProfessionalProvider()),
        
//         // Appointment Provider
//         ChangeNotifierProvider(create: (_) => AppointmentProvider()),
//       ],
//       child: MaterialApp(
//         title: 'GetInLine',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.light,
//         initialRoute: AppRouter.splash,
//         onGenerateRoute: AppRouter.generateRoute,
//       ),
//     );
//   }
// }
