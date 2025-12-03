enum QuotationStatus { draft, sent, accepted, rejected }

class QuotationItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;

  QuotationItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class Quotation {
  final String id;
  final String quotationNumber;
  final String clientId;
  final String clientName;
  final String? firstName;
  final String? lastName;
  final String? eventName;
  final String eventType;
  final DateTime eventDate;
  final String? team;
  final String? commercial;
  final List<QuotationItem> items;
  final QuotationStatus status;
  final DateTime createdAt;
  final DateTime? validUntil;

  Quotation({
    required this.id,
    required this.quotationNumber,
    required this.clientId,
    required this.clientName,
    this.firstName,
    this.lastName,
    this.eventName,
    required this.eventType,
    required this.eventDate,
    this.team,
    this.commercial,
    required this.items,
    required this.status,
    required this.createdAt,
    this.validUntil,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  // Mock Data Factory
  static List<Quotation> getMockQuotations() {
    return [
      Quotation(
        id: '1',
        quotationNumber: 'Q-2023-001',
        clientId: '1',
        clientName: 'Rahul & Priya',
        eventType: 'Wedding Photography',
        eventDate: DateTime.now().add(const Duration(days: 30)),
        status: QuotationStatus.sent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        validUntil: DateTime.now().add(const Duration(days: 5)),
        items: [
          QuotationItem(
            id: '1',
            description: 'Photography Coverage',
            quantity: 1,
            unitPrice: 50000,
          ),
          QuotationItem(
            id: '2',
            description: 'Videography Coverage',
            quantity: 1,
            unitPrice: 40000,
          ),
          QuotationItem(
            id: '3',
            description: 'Photo Editing',
            quantity: 100,
            unitPrice: 200,
          ),
        ],
      ),
      Quotation(
        id: '2',
        quotationNumber: 'Q-2023-002',
        clientId: '2',
        clientName: 'Tech Corp',
        eventType: 'Corporate Event',
        eventDate: DateTime.now().add(const Duration(days: 15)),
        status: QuotationStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 6)),
        items: [
          QuotationItem(
            id: '4',
            description: 'Event Photography',
            quantity: 1,
            unitPrice: 25000,
          ),
          QuotationItem(
            id: '5',
            description: 'Corporate Videography',
            quantity: 1,
            unitPrice: 30000,
          ),
        ],
      ),
      Quotation(
        id: '3',
        quotationNumber: 'Q-2023-003',
        clientId: '3',
        clientName: 'Amit Singh',
        eventType: 'Portrait Session',
        eventDate: DateTime.now().add(const Duration(days: 45)),
        status: QuotationStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        validUntil: DateTime.now().subtract(const Duration(days: 3)),
        items: [
          QuotationItem(
            id: '6',
            description: 'Portrait Photography',
            quantity: 1,
            unitPrice: 15000,
          ),
          QuotationItem(
            id: '7',
            description: 'Photo Editing Package',
            quantity: 1,
            unitPrice: 5000,
          ),
          QuotationItem(
            id: '8',
            description: 'Online Gallery',
            quantity: 1,
            unitPrice: 3000,
          ),
        ],
      ),
    ];
  }
}
