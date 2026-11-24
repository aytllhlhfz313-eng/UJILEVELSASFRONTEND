import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import 'theme.dart';
import 'routes.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/products/product_form_screen.dart';
import '../screens/categories/category_list_screen.dart';
import '../screens/categories/category_form_screen.dart';
import '../screens/profile/profile_screen.dart';

class ContreStoreApp extends StatelessWidget {
  const ContreStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Contre Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.products: (_) => const ProductListScreen(),
          AppRoutes.productDetail: (_) => const ProductDetailScreen(),
          AppRoutes.productForm: (_) => const ProductFormScreen(),
          AppRoutes.categories: (_) => const CategoryListScreen(),
          AppRoutes.categoryForm: (_) => const CategoryFormScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}