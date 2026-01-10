import 'package:flutter/material.dart';
import 'package:essivi_mobile/routes/app_routes.dart';

// Auth Screens
import 'package:essivi_mobile/presentation/screens/client/onboarding_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/login_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/signup_screen.dart';

// Client Screens
import 'package:essivi_mobile/presentation/screens/client/home_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/edit_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/settings_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/change_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/notifications_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/tracking_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/orders_list_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/create_order_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_history_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_details_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/help_center_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/bottle_return_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/subscription_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/water_quality_screen.dart';

// Agent Screens
import 'package:essivi_mobile/presentation/screens/agent/agent_dashboard.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_deliveries_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_earnings_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/bottle_inventory_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/delivery_proof_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      // Auth Routes
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      // Client Routes
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
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
      
      case AppRoutes.shipmentHistory:
        return MaterialPageRoute(builder: (_) => const ShipmentHistoryScreen());
      
      case AppRoutes.shipmentDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ShipmentDetailsScreen(
              title: args['title'] ?? 'Shipment',
              id: args['id'] ?? 'N/A',
              status: args['status'] ?? 'Unknown',
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ShipmentDetailsScreen(
            title: 'Shipment',
            id: 'N/A',
            status: 'Unknown',
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
        return MaterialPageRoute(builder: (_) => const AgentDashboard());
      
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

      // Default Route (404)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
