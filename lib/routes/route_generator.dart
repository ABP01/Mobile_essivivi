import 'package:essivi_mobile/presentation/screens/agent/agent_deliveries_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_earnings_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_main_shell.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/bottle_inventory_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/delivery_proof_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/login_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/signup_screen.dart';
// Auth Screens
import 'package:essivi_mobile/presentation/screens/auth/splash_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/bottle_return_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/cart_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/change_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/client_home_screen_redesign.dart';
import 'package:essivi_mobile/presentation/screens/client/client_landing_screen.dart';
// Shells
import 'package:essivi_mobile/presentation/screens/client/client_main_shell.dart';
import 'package:essivi_mobile/presentation/screens/client/client_tracking_screen_redesign.dart';
import 'package:essivi_mobile/presentation/screens/client/create_order_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/edit_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/help_center_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/notifications_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/orders_list_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/settings_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_details_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_history_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/subscription_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/track_delivery_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/tracking_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/water_quality_screen.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const ClientLandingScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Client Routes
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const ClientMainShell());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.tracking:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());

      case AppRoutes.ordersList:
        // Handle optional status parameter
        final status = args is String ? args : 'all';
        return MaterialPageRoute(
          builder: (_) => OrdersListScreen(status: status),
        );

      case AppRoutes.createOrder:
        return MaterialPageRoute(builder: (_) => const CreateOrderScreen());

      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case AppRoutes.trackDelivery:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => TrackDeliveryScreen(
              deliveryId: args['deliveryId'] ?? 0,
              agentId: args['agentId'] ?? 0,
              agentName: args['agentName'] ?? 'Agent',
              agentPhone: args['agentPhone'] ?? '',
              clientLatitude: args['clientLatitude'],
              clientLongitude: args['clientLongitude'],
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Paramètres manquants'))),
        );

      case AppRoutes.shipmentHistory:
        return MaterialPageRoute(builder: (_) => const ShipmentHistoryScreen());

      case AppRoutes.shipmentDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ShipmentDetailsScreen(shipmentData: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ShipmentDetailsScreen(
            shipmentData: {
              'id': 'N/A',
              'status': 'Unknown',
              'title': 'Shipment',
            },
          ),
        );

      case AppRoutes.helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());

      case AppRoutes.bottleReturn:
        return MaterialPageRoute(builder: (_) => const BottleReturnScreen());

      case AppRoutes.subscription:
        return MaterialPageRoute(builder: (_) => const AbonnementScreen());

      case AppRoutes.waterQuality:
        return MaterialPageRoute(builder: (_) => const WaterQualityScreen());

      // Agent Routes
      case AppRoutes.agentDashboard:
        return MaterialPageRoute(builder: (_) => const AgentMainShell());

      case AppRoutes.agentDeliveries:
        return MaterialPageRoute(builder: (_) => const AgentDeliveriesScreen());

      case AppRoutes.agentEarnings:
        return MaterialPageRoute(builder: (_) => const AgentEarningsScreen());

      case AppRoutes.agentProfile:
        return MaterialPageRoute(builder: (_) => const AgentProfileScreen());

      case AppRoutes.bottleInventory:
        return MaterialPageRoute(builder: (_) => const BottleInventoryScreen());

      case AppRoutes.deliveryProof:
        return MaterialPageRoute(
          builder: (_) => const DeliveryProofScreen(
            deliveryId: '',
            clientName: '',
            address: '',
          ),
        );

      // Redesign Routes
      case AppRoutes.clientLanding:
        return MaterialPageRoute(builder: (_) => const ClientLandingScreen());

      case AppRoutes.clientHomeRedesign:
        return MaterialPageRoute(builder: (_) => const ClientHomeRedesign());

      case AppRoutes.clientTrackingRedesign:
        return MaterialPageRoute(
          builder: (_) => const ClientTrackingRedesign(),
        );

      // Default Route (404)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route non trouvée: ${settings.name}')),
          ),
        );
    }
  }
}
