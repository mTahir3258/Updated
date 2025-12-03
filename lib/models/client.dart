class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName; // Computed from firstName + lastName
  final String mobileNumber;
  final String whatsappNumber;
  final String? alternateNumber;
  final String? email;
  final String? address;
  final String source;
  final String createdBy;
  final DateTime createdDate;
  final List<ContactPerson> contactPersons;
  final String? notes;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.whatsappNumber,
    this.alternateNumber,
    this.email,
    this.address,
    required this.source,
    required this.createdBy,
    required this.createdDate,
    this.contactPersons = const [],
    this.notes,
  }) : fullName = '$firstName $lastName'.trim();

  factory Client.mock(int index) {
    final firstNames = ['Rajesh', 'Amit', 'Vikram'];
    final lastNames = ['Sharma', 'Patel', 'Singh'];

    return Client(
      id: 'CLT${index.toString().padLeft(3, '0')}',
      firstName: firstNames[index % 3],
      lastName: lastNames[index % 3],
      mobileNumber: '+91 ${98765 + index} ${43210 + index}',
      whatsappNumber: '+91 ${98765 + index} ${43210 + index}',
      alternateNumber: index % 2 == 0
          ? '+91 ${98766 + index} ${43211 + index}'
          : null,
      email: index % 2 == 0 ? 'client$index@example.com' : null,
      address: index % 2 == 0 ? '123 Main Street, Mumbai, Maharashtra' : null,
      source: ['Referral', 'Facebook', 'Instagram', 'Website'][index % 4],
      createdBy: 'Admin',
      createdDate: DateTime.now().subtract(Duration(days: index * 5)),
      contactPersons: [
        ContactPerson(
          name: firstNames[index % 3],
          phone: '+91 98765 ${43210 + index}',
          isPrimary: true,
        ),
        if (index % 2 == 0)
          ContactPerson(
            name: lastNames[index % 3],
            phone: '+91 98766 ${43211 + index}',
            isPrimary: false,
          ),
      ],
      notes: index % 2 == 0
          ? 'VIP client - high budget wedding photography'
          : null,
    );
  }

  static List<Client> generateMockList(int count) {
    return List.generate(count, (index) => Client.mock(index));
  }
}

class ContactPerson {
  final String name;
  final String phone;
  final bool isPrimary;

  ContactPerson({
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });
}
