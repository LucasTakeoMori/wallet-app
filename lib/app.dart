import 'package:flutter/material.dart';
import 'package:wallet_app/pages/home/home_page.dart';
import 'package:wallet_app/styles/app_colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Digital',
      theme: ThemeData(
        primaryColor: AppColors.white,
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.main,
          foregroundColor: AppColors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.main,
        ),
      ),
      home: const HomePage(),
    );
  }
}
