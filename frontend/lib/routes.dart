import 'package:flutter/widgets.dart';
import 'package:ts_speed_shop/screens/products/products_screen.dart';
import 'package:ts_speed_shop/screens/courses/courses_screen.dart';

import 'screens/cart/cart_screen.dart';
import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/favorite/favorite_screen.dart';
import 'screens/order/order_page.dart';
import 'screens/order/order_details_page.dart';
import 'screens/order/purchase_history_screen.dart';
import 'screens/notifications/notifications_screen.dart';
 
// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  OtpScreen.routeName: (context) => const OtpScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  CoursesScreen.routeName: (context) => const CoursesScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  FavoriteScreen.routeName: (context) => const FavoriteScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  OrderPage.routeName: (context) => const OrderPage(),
  PurchaseHistoryScreen.routeName: (context) => const PurchaseHistoryScreen(),
  NotificationsScreen.routeName: (context) => const NotificationsScreen(),
};
