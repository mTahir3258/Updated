/// Application route constants
class Routes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String dashboard = '/dashboard';

  // Lead Routes
  static const String leadList = '/leads';
  static const String leadDetails = '/leads/:id';
  static const String leadForm = '/leads/form';

  // Client Routes
  static const String clientList = '/clients';
  static const String clientDetails = '/clients/:id';
  static const String clientForm = '/clients/form';

  // Order Routes
  static const String orderList = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String orderForm = '/orders/form';

  // Event Routes
  static const String eventList = '/events';
  static const String eventDetails = '/events/:id';
  static const String eventForm = '/events/form';

  // Quotation Routes
  static const String quotationList = '/quotations';
  static const String quotationDetails = '/quotations/:id';
  static const String quotationForm = '/quotations/form';

  // Setup Routes
  static const String leadSource = '/setup/lead-sources';
  static const String eventType = '/setup/event-types';
  static const String teamMemberCategory = '/setup/team-categories';
  static const String teamMembers = '/setup/team-members';
  static const String service = '/setup/services';
  static const String subService = '/setup/sub-services';
  static const String adminNotification = '/setup/admin-notifications';
  static const String notificationTemplate = '/setup/notification-templates';
  static const String package = '/setup/packages';
  static const String users = '/users';
  static const String roles = '/roles';

  // Communication Routes
  static const String messageList = '/messages';
  static const String chat = '/messages/:mobile';
  static const String myProfile = '/my-profile';
  static const String incompleteLeads = '/leads/incomplete';
}
