class Order {
  final String id;
  final String clientName;
  final String clientId;
  final String? clientMobileNumber;
  final String? eventName;
  final String eventType;
  final DateTime eventDate;
  final String venue;
  final String status; // confirmed, pending, cancelled, completed
  final String paymentStatus; // paid, partial, pending, overdue
  final double totalAmount;
  final double paidAmount;
  final double? totalOrderValue;
  final double? dueAmount;
  final DateTime? dueDate;
  final double? advancedAmount;
  final List<ServiceAssignment> services;
  final List<PaymentRecord> payments;
  final String? notes;
  final DateTime createdDate;

  Order({
    required this.id,
    required this.clientName,
    required this.clientId,
    this.clientMobileNumber,
    this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.venue,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paidAmount,
    this.totalOrderValue,
    this.dueAmount,
    this.dueDate,
    this.advancedAmount,
    this.services = const [],
    this.payments = const [],
    this.notes,
    required this.createdDate,
  });

  double get remainingAmount => totalAmount - paidAmount;
  double get paymentProgress =>
      totalAmount > 0 ? (paidAmount / totalAmount) : 0.0;

  factory Order.mock(int index) {
    final total = 150000.0 + (index * 10000);
    final paid = total * ([0.3, 0.5, 0.7, 1.0][index % 4]);

    return Order(
      id: 'ORD${index.toString().padLeft(3, '0')}',
      clientName: [
        'Rajesh & Priya',
        'Amit & Sneha',
        'Vikram & Kavita',
      ][index % 3],
      clientId: 'CLT${index.toString().padLeft(3, '0')}',
      clientMobileNumber: '+91 ${98765 + index} ${43210 + index}',
      eventName: [
        'Wedding Photography Shoot',
        'Portrait Session',
        'Corporate Event Coverage',
        'Engagement Shoot',
      ][index % 4],
      eventType: [
        'Wedding Photography',
        'Portrait Session',
        'Corporate Event',
      ][index % 3],
      eventDate: DateTime.now().add(Duration(days: 30 + (index * 15))),
      venue: [
        'Grand Palace Hotel',
        'Royal Gardens',
        'Beach Resort',
        'City Convention Center',
      ][index % 4],
      status: ['confirmed', 'pending', 'completed'][index % 3],
      paymentStatus: paid >= total
          ? 'paid'
          : paid > 0
          ? 'partial'
          : 'pending',
      totalAmount: total,
      paidAmount: paid,
      services: [
        ServiceAssignment(
          serviceName: 'Photography',
          teamMember: 'Rahul Sharma',
          status: 'assigned',
          persons: 1,
        ),
        ServiceAssignment(
          serviceName: 'Videography',
          teamMember: 'Priya Singh',
          status: 'assigned',
          persons: 1,
        ),
      ],
      payments: [
        if (paid > 0)
          PaymentRecord(
            amount: paid / 2,
            date: DateTime.now().subtract(Duration(days: 30)),
            method: 'UPI',
          ),
        if (paid > total / 2)
          PaymentRecord(
            amount: paid / 2,
            date: DateTime.now().subtract(Duration(days: 15)),
            method: 'Cash',
          ),
      ],
      notes: index % 2 == 0 ? 'Client prefers evening setup' : null,
      createdDate: DateTime.now().subtract(Duration(days: 60 + index)),
    );
  }

  static List<Order> generateMockList(int count) {
    return List.generate(count, (index) => Order.mock(index));
  }
}

class ServiceAssignment {
  final String serviceName;
  final String? teamMember;
  final String status; // assigned, in_progress, completed
  final int? persons;

  ServiceAssignment({
    required this.serviceName,
    this.teamMember,
    required this.status,
    this.persons,
  });
}

class PaymentRecord {
  final double amount;
  final DateTime date;
  final String method; // cash, upi, card, bank_transfer

  PaymentRecord({
    required this.amount,
    required this.date,
    required this.method,
  });
}
