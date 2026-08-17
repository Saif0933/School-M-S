import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Book Catalog Model (Physical, E-Book, Journals)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BookEntity {
  final String id;
  final String branchId;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String barcode;
  final String rfidTag;
  final String ddcClassification; // Dewey Decimal Classification system (e.g., 510 for Mathematics)
  final String category;
  final double procurementCost;
  final String status; // 'Available', 'Issued', 'Lost', 'Damaged'
  final String type; // 'Physical Book', 'E-Book', 'Magazine', 'Journal'

  const BookEntity({
    required this.id,
    required this.branchId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.barcode,
    required this.rfidTag,
    required this.ddcClassification,
    required this.category,
    required this.procurementCost,
    required this.status,
    required this.type,
  });

  BookEntity copyWith({String? status, String? type}) {
    return BookEntity(
      id: id,
      branchId: branchId,
      isbn: isbn,
      title: title,
      author: author,
      publisher: publisher,
      barcode: barcode,
      rfidTag: rfidTag,
      ddcClassification: ddcClassification,
      category: category,
      procurementCost: procurementCost,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

class BookCatalogNotifier extends StateNotifier<List<BookEntity>> {
  BookCatalogNotifier() : super([
    const BookEntity(
      id: 'BK-001',
      branchId: 'BR-001',
      isbn: '978-0131103627',
      title: 'The C Programming Language',
      author: 'Dennis Ritchie',
      publisher: 'Prentice Hall',
      barcode: 'BAR-001036',
      rfidTag: 'RFID-BK-001',
      ddcClassification: '005.13',
      category: 'Computer Science',
      procurementCost: 45.0,
      status: 'Available',
      type: 'Physical Book',
    ),
    const BookEntity(
      id: 'BK-002',
      branchId: 'BR-001',
      isbn: '978-0321356680',
      title: 'Effective Java',
      author: 'Joshua Bloch',
      publisher: 'Addison-Wesley',
      barcode: 'BAR-032135',
      rfidTag: 'RFID-BK-002',
      ddcClassification: '005.133',
      category: 'Computer Science',
      procurementCost: 55.0,
      status: 'Issued',
      type: 'Physical Book',
    ),
    const BookEntity(
      id: 'BK-003',
      branchId: 'BR-001',
      isbn: 'EBOOK-CALC01',
      title: 'Introduction to Calculus',
      author: 'Gilbert Strang',
      publisher: 'Wellesley-Cambridge',
      barcode: 'BAR-E-001',
      rfidTag: 'RFID-E-001',
      ddcClassification: '515',
      category: 'Mathematics',
      procurementCost: 0.0,
      status: 'Available',
      type: 'E-Book',
    ),
  ]);

  void addBook(BookEntity book) {
    state = [...state, book];
  }

  void updateBookStatus(String id, String status) {
    state = state.map((b) => b.id == id ? b.copyWith(status: status) : b).toList();
  }
}

final bookCatalogProvider = StateNotifierProvider<BookCatalogNotifier, List<BookEntity>>((ref) {
  return BookCatalogNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Library Member Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LibraryMemberEntity {
  final String id;
  final String branchId;
  final String studentOrStaffId;
  final String name;
  final String memberType; // 'Student', 'Staff'
  final bool cardGenerated;

  const LibraryMemberEntity({
    required this.id,
    required this.branchId,
    required this.studentOrStaffId,
    required this.name,
    required this.memberType,
    required this.cardGenerated,
  });

  LibraryMemberEntity copyWith({bool? cardGenerated}) {
    return LibraryMemberEntity(
      id: id,
      branchId: branchId,
      studentOrStaffId: studentOrStaffId,
      name: name,
      memberType: memberType,
      cardGenerated: cardGenerated ?? this.cardGenerated,
    );
  }
}

class LibraryMembersNotifier extends StateNotifier<List<LibraryMemberEntity>> {
  LibraryMembersNotifier() : super([
    const LibraryMemberEntity(
      id: 'MEM-001',
      branchId: 'BR-001',
      studentOrStaffId: 'STU-001',
      name: 'Aarav Sharma',
      memberType: 'Student',
      cardGenerated: true,
    ),
    const LibraryMemberEntity(
      id: 'MEM-002',
      branchId: 'BR-001',
      studentOrStaffId: 'STU-002',
      name: 'Bhumika Gowda',
      memberType: 'Student',
      cardGenerated: false,
    ),
  ]);

  void addMember(LibraryMemberEntity member) {
    state = [...state, member];
  }

  void generateLibraryCard(String id) {
    state = state.map((m) => m.id == id ? m.copyWith(cardGenerated: true) : m).toList();
  }
}

final libraryMembersProvider = StateNotifierProvider<LibraryMembersNotifier, List<LibraryMemberEntity>>((ref) {
  return LibraryMembersNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Library Issues, Returns & Fine Calculations
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BookTransactionEntity {
  final String id;
  final String branchId;
  final String bookId;
  final String bookTitle;
  final String memberId;
  final String memberName;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final double finesCharged;
  final String status; // 'Issued', 'Returned', 'Overdue'

  const BookTransactionEntity({
    required this.id,
    required this.branchId,
    required this.bookId,
    required this.bookTitle,
    required this.memberId,
    required this.memberName,
    required this.issueDate,
    required this.dueDate,
    this.returnDate,
    required this.finesCharged,
    required this.status,
  });

  BookTransactionEntity copyWith({
    DateTime? dueDate,
    DateTime? returnDate,
    double? finesCharged,
    String? status,
  }) {
    return BookTransactionEntity(
      id: id,
      branchId: branchId,
      bookId: bookId,
      bookTitle: bookTitle,
      memberId: memberId,
      memberName: memberName,
      issueDate: issueDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      finesCharged: finesCharged ?? this.finesCharged,
      status: status ?? this.status,
    );
  }
}

class BookTransactionsNotifier extends StateNotifier<List<BookTransactionEntity>> {
  BookTransactionsNotifier() : super([
    BookTransactionEntity(
      id: 'TX-001',
      branchId: 'BR-001',
      bookId: 'BK-002',
      bookTitle: 'Effective Java',
      memberId: 'MEM-001',
      memberName: 'Aarav Sharma',
      issueDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      finesCharged: 14.0, // Rs. 2 per day fine rules
      status: 'Overdue',
    ),
  ]);

  void issueBook(BookTransactionEntity tx) {
    state = [...state, tx];
  }

  void renewBook(String id, DateTime newDueDate) {
    state = state.map((t) => t.id == id ? t.copyWith(dueDate: newDueDate, status: 'Issued') : t).toList();
  }

  void returnBook(String id, double finalFine) {
    state = state.map((t) => t.id == id ? t.copyWith(returnDate: DateTime.now(), finesCharged: finalFine, status: 'Returned') : t).toList();
  }
}

final bookTransactionsProvider = StateNotifierProvider<BookTransactionsNotifier, List<BookTransactionEntity>>((ref) {
  return BookTransactionsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Library Budgets
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LibraryBudgetEntity {
  final String id;
  final String branchId;
  final double allocated;
  final double spent;
  final String year;

  const LibraryBudgetEntity({
    required this.id,
    required this.branchId,
    required this.allocated,
    required this.spent,
    required this.year,
  });

  LibraryBudgetEntity copyWith({double? spent}) {
    return LibraryBudgetEntity(
      id: id,
      branchId: branchId,
      allocated: allocated,
      spent: spent ?? this.spent,
      year: year,
    );
  }
}

class LibraryBudgetsNotifier extends StateNotifier<List<LibraryBudgetEntity>> {
  LibraryBudgetsNotifier() : super([
    const LibraryBudgetEntity(
      id: 'LB-001',
      branchId: 'BR-001',
      allocated: 8000.0,
      spent: 4200.0,
      year: '2026',
    ),
  ]);

  void addBudget(LibraryBudgetEntity budget) {
    state = [...state, budget];
  }

  void updateSpent(String id, double cost) {
    state = state.map((b) => b.id == id ? b.copyWith(spent: b.spent + cost) : b).toList();
  }
}

final libraryBudgetsProvider = StateNotifierProvider<LibraryBudgetsNotifier, List<LibraryBudgetEntity>>((ref) {
  return LibraryBudgetsNotifier();
});
