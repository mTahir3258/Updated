import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_theme.dart';
import 'package:ui_specification/core/constants/routes.dart';
import 'package:ui_specification/features/auth/providers/auth_provider.dart';
import 'package:ui_specification/features/auth/screens/login_screen.dart';
import 'package:ui_specification/features/auth/screens/splash_screen.dart';
import 'package:ui_specification/features/auth/screens/forgot_password_screen.dart';
import 'package:ui_specification/features/dashboard/screens/dashboard_screen.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/features/leads/screens/lead_list_screen.dart';
import 'package:ui_specification/features/leads/screens/lead_detail_screen.dart';
import 'package:ui_specification/features/leads/screens/lead_form_screen.dart';
import 'package:ui_specification/models/lead.dart';
import 'package:ui_specification/features/clients/providers/client_provider.dart';
import 'package:ui_specification/features/clients/screens/client_list_screen.dart';
import 'package:ui_specification/features/clients/screens/client_detail_screen.dart';
import 'package:ui_specification/features/clients/screens/client_form_screen.dart';
import 'package:ui_specification/models/client.dart';
import 'package:ui_specification/features/orders/providers/order_provider.dart';
import 'package:ui_specification/features/orders/screens/order_list_screen.dart';
import 'package:ui_specification/features/orders/screens/order_detail_screen.dart';
import 'package:ui_specification/features/orders/screens/order_form_screen.dart';
import 'package:ui_specification/models/order.dart';
import 'package:ui_specification/features/events/providers/event_provider.dart';
import 'package:ui_specification/features/events/screens/event_list_screen.dart';
import 'package:ui_specification/features/events/screens/event_detail_screen.dart';
import 'package:ui_specification/features/events/screens/event_form_screen.dart';
import 'package:ui_specification/models/event.dart';
import 'package:ui_specification/features/quotations/providers/quotation_provider.dart';
import 'package:ui_specification/features/quotations/screens/quotation_list_screen.dart';
import 'package:ui_specification/features/quotations/screens/quotation_detail_screen.dart';
import 'package:ui_specification/features/quotations/screens/quotation_form_screen.dart';
import 'package:ui_specification/features/setup/providers/master_data_provider.dart';
import 'package:ui_specification/features/setup/screens/master_data_screens.dart';
import 'package:ui_specification/features/setup/screens/team_member_screen.dart';
import 'package:ui_specification/features/user_management/providers/user_management_provider.dart';
import 'package:ui_specification/features/user_management/screens/user_screens.dart';
import 'package:ui_specification/features/user_management/screens/role_screens.dart';
import 'package:ui_specification/features/communication/providers/communication_provider.dart';
import 'package:ui_specification/features/communication/screens/communication_screens.dart';
import 'package:ui_specification/features/user_management/screens/my_profile_screen.dart';
import 'package:ui_specification/features/leads/screens/incomplete_leads_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => QuotationProvider()),
        ChangeNotifierProvider(create: (_) => MasterDataProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => CommunicationProvider()),
      ],
      child: MaterialApp(
        title: 'Event Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: Routes.dashboard,
        routes: {
          Routes.splash: (context) => const SplashScreen(),
          Routes.login: (context) => const LoginScreen(),
          Routes.forgotPassword: (context) => const ForgotPasswordScreen(),
          Routes.dashboard: (context) => const DashboardScreen(),
          Routes.leadList: (context) => const LeadListScreen(),
          Routes.leadDetails: (context) => const LeadDetailScreen(),
          Routes.leadForm: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final lead = args is Lead ? args : null;
            return LeadFormScreen(lead: lead);
          },
          Routes.clientList: (context) => const ClientListScreen(),
          Routes.clientDetails: (context) => const ClientDetailScreen(),
          Routes.clientForm: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final client = args is Client ? args : null;
            return ClientFormScreen(client: client);
          },
          Routes.orderList: (context) => const OrderListScreen(),
          Routes.orderDetails: (context) => const OrderDetailScreen(),
          Routes.orderForm: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final order = args is Order ? args : null;
            return OrderFormScreen(order: order);
          },
          Routes.eventList: (context) => const EventListScreen(),
          Routes.eventDetails: (context) => const EventDetailScreen(),
          Routes.eventForm: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final event = args is Event ? args : null;
            return EventFormScreen(event: event);
          },
          Routes.quotationList: (context) => const QuotationListScreen(),
          Routes.quotationDetails: (context) => const QuotationDetailScreen(),
          Routes.quotationForm: (context) => const QuotationFormScreen(),
          Routes.teamMembers: (context) => const TeamMemberScreen(),

          // Setup Routes
          Routes.leadSource: (context) => const LeadSourceScreen(),
          Routes.eventType: (context) => const EventTypeScreen(),
          Routes.teamMemberCategory: (context) => const TeamCategoryScreen(),
          Routes.service: (context) => const ServiceScreen(),
          Routes.subService: (context) => const SubServiceScreen(),
          Routes.adminNotification: (context) =>
              const AdminNotificationScreen(),
          Routes.notificationTemplate: (context) =>
              const NotificationTemplateScreen(),
          Routes.package: (context) => const PackageScreen(),

          // User Management Routes
          Routes.users: (context) => const UserListScreen(),
          Routes.roles: (context) => const RoleListScreen(),

          // Communication Routes
          Routes.messageList: (context) => const MessageListScreen(),
          Routes.myProfile: (context) => const MyProfileScreen(),
          Routes.incompleteLeads: (context) => const IncompleteLeadsScreen(),
        },
      ),
    );
  }
}
