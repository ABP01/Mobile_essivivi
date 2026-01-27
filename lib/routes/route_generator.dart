import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_availability_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_deliveries_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_delivery_details_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_earnings_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_history_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_main_shell.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_map_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_settings_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/bottle_inventory_screen.dart';
import 'package:essivi_mobile/presentation/screens/agent/delivery_proof_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/login_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/reset_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/auth/signup_screen.dart';
// Auth Screens
import 'package:essivi_mobile/presentation/screens/auth/splash_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/address_book_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/bottle_return_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/cart_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/change_password_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/client_home_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/client_landing_screen.dart';
// Shells
import 'package:essivi_mobile/presentation/screens/client/client_main_shell.dart';
import 'package:essivi_mobile/presentation/screens/client/client_tracking_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/create_order_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/edit_profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/help_center_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/notifications_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/order_feedback_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/orders_list_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/payment_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/profile_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/settings_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_details_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/shipment_history_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/subscription_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/track_delivery_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/tracking_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/wallet_screen.dart';
import 'package:essivi_mobile/presentation/screens/client/water_quality_screen.dart';
import 'package:essivi_mobile/presentation/screens/phone_login_screen.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/routes/role_guard.dart';
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

      case AppRoutes.phoneLogin:
        return MaterialPageRoute(builder: (_) => const PhoneLoginScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.resetPassword:
        final token = args is Map<String, dynamic>
            ? args['token'] as String?
            : null;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );

      // Client Routes
      case AppRoutes.home:
        // Client Shell
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ClientMainShell(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ProfileScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const EditProfileScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const SettingsScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ChangePasswordScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const NotificationsScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.tracking:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const TrackingScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.ordersList:
        // Handle optional status parameter
        final status = args is String ? args : 'all';
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            OrdersListScreen(status: status),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.createOrder:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const CreateOrderScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const CartScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.trackDelivery:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => _buildWithRoleCheck(
              TrackDeliveryScreen(
                deliveryId: args['deliveryId'] ?? 0,
                agentId: args['agentId'] ?? 0,
                agentName: args['agentName'] ?? 'Agent',
                agentPhone: args['agentPhone'] ?? '',
                clientLatitude: args['clientLatitude'],
                clientLongitude: args['clientLongitude'],
              ),
              allowedRoles: const ['client', 'admin', 'gestionnaire'],
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Paramètres manquants'))),
        );

      case AppRoutes.shipmentHistory:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ShipmentHistoryScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.shipmentDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => _buildWithRoleCheck(
              ShipmentDetailsScreen(shipmentData: args),
              allowedRoles: const ['client', 'agent', 'admin', 'gestionnaire'],
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            ShipmentDetailsScreen(
              shipmentData: {
                'id': 'N/A',
                'status': 'Unknown',
                'title': 'Shipment',
              },
            ),
            allowedRoles: const ['client', 'agent', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.helpCenter:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const HelpCenterScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.bottleReturn:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const BottleReturnScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.subscription:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AbonnementScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.waterQuality:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const WaterQualityScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.addressBook:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AddressBookScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.wallet:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const WalletScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.payment:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const PaymentScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.orderFeedback:
        final orderId = args is String ? args : 'N/A';
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            OrderFeedbackScreen(orderId: orderId),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      // Agent Routes
      case AppRoutes.agentDashboard:
        // Agent Shell
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentMainShell(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentDeliveries:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentDeliveriesScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentEarnings:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentEarningsScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentProfile:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            AgentProfileScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.bottleInventory:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const BottleInventoryScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.deliveryProof:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const DeliveryProofScreen(
              deliveryId: '',
              clientName: '',
              address: '',
            ),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentMap:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentMapScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentDeliveryDetails:
        final livraison =
            args as dynamic; // Cast to Livraison if imported, or dynamic
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            AgentDeliveryDetailsScreen(livraison: livraison),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentSettings:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentSettingsScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentHistory:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentHistoryScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      case AppRoutes.agentAvailability:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const AgentAvailabilityScreen(),
            allowedRoles: const ['agent'],
          ),
        );

      // Redesign Routes
      case AppRoutes.clientLanding:
        return MaterialPageRoute(builder: (_) => const ClientLandingScreen());

      case AppRoutes.clientHomeRedesign:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ClientHomeScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
        );

      case AppRoutes.clientTrackingRedesign:
        return MaterialPageRoute(
          builder: (_) => _buildWithRoleCheck(
            const ClientTrackingScreen(),
            allowedRoles: const ['client', 'admin', 'gestionnaire'],
          ),
          settings: settings, // Pass arguments
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

  static Widget _buildWithRoleCheck(
    Widget child, {
    required List<String> allowedRoles,
  }) {
    return FutureBuilder<String?>(
      future: AuthRepository().getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = snapshot.data ?? 'guest';
        if (role == 'guest') {
          return const LoginScreen();
        }
        // Allow admin/gestionnaire to access everything or handle specific roles
        if (role == 'admin' || role == 'gestionnaire') return child;

        return RoleBasedGuard(
          allowedRoles: allowedRoles,
          userRole: role,
          child: child,
        );
      },
    );
  }
}
