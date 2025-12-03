import 'package:flutter/material.dart';
import 'package:ui_specification/models/master_data.dart';

class MasterDataProvider extends ChangeNotifier {
  List<LeadSource> _leadSources = [];
  List<EventType> _eventTypes = [];
  List<TeamCategory> _teamCategories = [];
  bool _isLoading = false;

  List<LeadSource> get leadSources => _leadSources;
  List<EventType> get eventTypes => _eventTypes;
  List<TeamCategory> get teamCategories => _teamCategories;
  bool get isLoading => _isLoading;

  MasterDataProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _leadSources = [
        LeadSource(id: '1', name: 'Website'),
        LeadSource(id: '2', name: 'Referral'),
        LeadSource(id: '3', name: 'Social Media'),
        LeadSource(id: '4', name: 'Walk-in'),
      ];

      _eventTypes = [
        EventType(id: '1', name: 'Wedding Photography'),
        EventType(id: '2', name: 'Portrait Session'),
        EventType(id: '3', name: 'Corporate Event'),
        EventType(id: '4', name: 'Engagement Shoot'),
      ];

      _teamCategories = [
        TeamCategory(id: '1', name: 'Management'),
        TeamCategory(id: '2', name: 'Photography'),
        TeamCategory(id: '3', name: 'Videography'),
      ];

      _services = [
        Service(id: '1', name: 'Photography'),
        Service(id: '2', name: 'Videography'),
      ];

      _subServices = [
        SubService(id: '1', serviceId: '1', name: 'Wedding Photography'),
        SubService(id: '2', serviceId: '1', name: 'Portrait Photography'),
        SubService(id: '3', serviceId: '1', name: 'Event Photography'),
        SubService(id: '4', serviceId: '2', name: 'Wedding Videography'),
        SubService(id: '5', serviceId: '2', name: 'Corporate Videography'),
        SubService(id: '6', serviceId: '2', name: 'Event Videography'),
      ];

      _adminNotifications = [
        AdminNotification(id: '1', name: 'Admin 1', number: '+1234567890'),
        AdminNotification(id: '2', name: 'Manager', number: '+0987654321'),
      ];

      _notificationTemplates = [
        NotificationTemplate(
          id: '1',
          name: 'Welcome',
          content: 'Welcome to our service!',
        ),
        NotificationTemplate(
          id: '2',
          name: 'Invoice',
          content: 'Here is your invoice.',
        ),
      ];

      _packages = [
        Package(
          id: '1',
          name: 'Gold Package',
          price: 5000,
          description: 'Premium services',
        ),
        Package(
          id: '2',
          name: 'Silver Package',
          price: 3000,
          description: 'Standard services',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    });
  }

  // Lead Source Operations
  void addLeadSource(String name) {
    _leadSources.add(
      LeadSource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    notifyListeners();
  }

  void updateLeadSource(LeadSource source, String name) {
    final index = _leadSources.indexWhere((s) => s.id == source.id);
    if (index != -1) {
      _leadSources[index] = LeadSource(
        id: source.id,
        name: name,
        isActive: source.isActive,
      );
      notifyListeners();
    }
  }

  void deleteLeadSource(LeadSource source) {
    _leadSources.removeWhere((s) => s.id == source.id);
    notifyListeners();
  }

  // Event Type Operations
  void addEventType(String name) {
    _eventTypes.add(
      EventType(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    notifyListeners();
  }

  void updateEventType(EventType type, String name) {
    final index = _eventTypes.indexWhere((t) => t.id == type.id);
    if (index != -1) {
      _eventTypes[index] = EventType(
        id: type.id,
        name: name,
        isActive: type.isActive,
      );
      notifyListeners();
    }
  }

  void deleteEventType(EventType type) {
    _eventTypes.removeWhere((t) => t.id == type.id);
    notifyListeners();
  }

  // Team Category Operations
  void addTeamCategory(String name) {
    _teamCategories.add(
      TeamCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ),
    );
    notifyListeners();
  }

  void updateTeamCategory(TeamCategory category, String name) {
    final index = _teamCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _teamCategories[index] = TeamCategory(
        id: category.id,
        name: name,
        isActive: category.isActive,
      );
      notifyListeners();
    }
  }

  void deleteTeamCategory(TeamCategory category) {
    _teamCategories.removeWhere((c) => c.id == category.id);
    notifyListeners();
  }

  // Service Operations
  List<Service> _services = [];
  List<SubService> _subServices = [];

  List<Service> get services => _services;
  List<SubService> get subServices => _subServices;

  void addService(String name) {
    _services.add(
      Service(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name),
    );
    notifyListeners();
  }

  void updateService(Service service, String name) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = Service(
        id: service.id,
        name: name,
        isActive: service.isActive,
      );
      notifyListeners();
    }
  }

  void deleteService(Service service) {
    _services.removeWhere((s) => s.id == service.id);
    notifyListeners();
  }

  // Sub Service Operations
  void addSubService(String serviceId, String name) {
    _subServices.add(
      SubService(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        serviceId: serviceId,
        name: name,
      ),
    );
    notifyListeners();
  }

  void updateSubService(SubService subService, String serviceId, String name) {
    final index = _subServices.indexWhere((s) => s.id == subService.id);
    if (index != -1) {
      _subServices[index] = SubService(
        id: subService.id,
        serviceId: serviceId,
        name: name,
        isActive: subService.isActive,
      );
      notifyListeners();
    }
  }

  void deleteSubService(SubService subService) {
    _subServices.removeWhere((s) => s.id == subService.id);
    notifyListeners();
  }

  // Admin Notification Operations
  List<AdminNotification> _adminNotifications = [];
  List<AdminNotification> get adminNotifications => _adminNotifications;

  void addAdminNotification(String name, String number) {
    _adminNotifications.add(
      AdminNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        number: number,
      ),
    );
    notifyListeners();
  }

  void updateAdminNotification(
    AdminNotification notification,
    String name,
    String number,
  ) {
    final index = _adminNotifications.indexWhere(
      (n) => n.id == notification.id,
    );
    if (index != -1) {
      _adminNotifications[index] = AdminNotification(
        id: notification.id,
        name: name,
        number: number,
        isActive: notification.isActive,
      );
      notifyListeners();
    }
  }

  void deleteAdminNotification(AdminNotification notification) {
    _adminNotifications.removeWhere((n) => n.id == notification.id);
    notifyListeners();
  }

  // Notification Template Operations
  List<NotificationTemplate> _notificationTemplates = [];
  List<NotificationTemplate> get notificationTemplates =>
      _notificationTemplates;

  void addNotificationTemplate(String name, String content) {
    _notificationTemplates.add(
      NotificationTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        content: content,
      ),
    );
    notifyListeners();
  }

  void updateNotificationTemplate(
    NotificationTemplate template,
    String name,
    String content,
  ) {
    final index = _notificationTemplates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _notificationTemplates[index] = NotificationTemplate(
        id: template.id,
        name: name,
        content: content,
        isActive: template.isActive,
      );
      notifyListeners();
    }
  }

  void deleteNotificationTemplate(NotificationTemplate template) {
    _notificationTemplates.removeWhere((t) => t.id == template.id);
    notifyListeners();
  }

  // Package Operations
  List<Package> _packages = [];
  List<Package> get packages => _packages;

  void addPackage(String name, double price, String description) {
    _packages.add(
      Package(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        price: price,
        description: description,
      ),
    );
    notifyListeners();
  }

  void updatePackage(
    Package package,
    String name,
    double price,
    String description,
  ) {
    final index = _packages.indexWhere((p) => p.id == package.id);
    if (index != -1) {
      _packages[index] = Package(
        id: package.id,
        name: name,
        price: price,
        description: description,
        isActive: package.isActive,
      );
      notifyListeners();
    }
  }

  void deletePackage(Package package) {
    _packages.removeWhere((p) => p.id == package.id);
    notifyListeners();
  }
}
