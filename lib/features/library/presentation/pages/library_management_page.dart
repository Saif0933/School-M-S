import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../../shared/widgets/layout/responsive_flex.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class LibraryManagementPage extends ConsumerStatefulWidget {
  const LibraryManagementPage({super.key});

  @override
  ConsumerState<LibraryManagementPage> createState() => _LibraryManagementPageState();
}

class _LibraryManagementPageState extends ConsumerState<LibraryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId ?? 'BR-001';

    return Column(
      children: [
        // Tab Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: isDark ? Colors.black12 : Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.menu_book_rounded, size: 16),
                text: 'Catalog & OPAC',
              ),
              Tab(
                icon: Icon(Icons.swap_horiz_rounded, size: 16),
                text: 'Issues & Returns',
              ),
              Tab(
                icon: Icon(Icons.badge_rounded, size: 16),
                text: 'Members & Cards',
              ),
              Tab(
                icon: Icon(Icons.report_problem_rounded, size: 16),
                text: 'Lost & Damaged',
              ),
              Tab(
                icon: Icon(Icons.payments_rounded, size: 16),
                text: 'Subscriptions & Budgets',
              ),
              Tab(
                icon: Icon(Icons.insights_rounded, size: 16),
                text: 'Library Analytics',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CatalogTab(branchId: activeBranchId),
              _IssuesReturnsTab(branchId: activeBranchId),
              _MembersCardsTab(branchId: activeBranchId),
              _LostDamagedTab(branchId: activeBranchId),
              _SubscriptionsBudgetsTab(branchId: activeBranchId),
              _LibraryAnalyticsTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Cataloging & OPAC
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CatalogTab extends ConsumerStatefulWidget {
  final String branchId;
  const _CatalogTab({required this.branchId});

  @override
  ConsumerState<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends ConsumerState<_CatalogTab> {
  final _searchCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _ddcCtrl = TextEditingController(text: '500');
  final _categoryCtrl = TextEditingController(text: 'Science');
  final _costCtrl = TextEditingController(text: '25.0');
  String _bookType = 'Physical Book';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _isbnCtrl.dispose();
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _ddcCtrl.dispose();
    _categoryCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = ref.watch(bookCatalogProvider).where((b) => b.branchId == widget.branchId).toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredBooks = books.where((b) {
      return b.title.toLowerCase().contains(query) ||
          b.author.toLowerCase().contains(query) ||
          b.isbn.toLowerCase().contains(query) ||
          b.ddcClassification.contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumn(
            children: [
              // Search & Catalog
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OPAC Book Search Catalog (Branch-Scoped)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _searchCtrl,
                      label: 'Search by Title, Author, ISBN, or DDC classification...',
                      isDark: isDark,
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (filteredBooks.isEmpty)
                      Text('No matching books found in this branch catalog.', style: TextStyle(color: textSec))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: book.type == 'E-Book' ? AppColors.secondary.withValues(alpha: 0.12) : AppColors.primarySurface,
                                  child: Icon(book.type == 'E-Book' ? Icons.laptop_chromebook_rounded : Icons.menu_book_rounded, color: book.type == 'E-Book' ? AppColors.secondary : AppColors.primary, size: 18),
                                ),
                                title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                                subtitle: Text(
                                  'Author: ${book.author} • ISBN: ${book.isbn}\nClassification (DDC): ${book.ddcClassification} • Category: ${book.category}',
                                  style: TextStyle(color: textSec, fontSize: 11),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildBookStatusTag(book.status),
                                    const SizedBox(height: 6),
                                    Text(book.type, style: TextStyle(fontSize: 9, color: textSec, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Add Book Form & Barcode Graphic Generator
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Procure & Catalog Book', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPri)),
                          const SizedBox(height: 12),
                          _FormField(controller: _titleCtrl, label: 'Book Title', isDark: isDark),
                          const SizedBox(height: 8),
                          _FormField(controller: _authorCtrl, label: 'Author', isDark: isDark),
                          const SizedBox(height: 8),
                          _FormField(controller: _publisherCtrl, label: 'Publisher', isDark: isDark),
                          const SizedBox(height: 8),
                          _FormField(controller: _isbnCtrl, label: 'ISBN Code', isDark: isDark),
                          const SizedBox(height: 8),
                          ResponsiveRowColumn(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: _FormField(controller: _ddcCtrl, label: 'DDC Code', isDark: isDark),
                              ),
                              Expanded(
                                child: _FormField(controller: _costCtrl, label: 'Cost', isDark: isDark, keyboardType: TextInputType.number),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _DropdownFilter(
                            label: 'Resource Type',
                            value: _bookType,
                            items: const ['Physical Book', 'E-Book', 'Magazine', 'Journal'],
                            displayItems: const ['Physical Book', 'E-Book Resource', 'Magazine Subscription', 'Journal Subscription'],
                            onChanged: (v) => setState(() => _bookType = v),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_titleCtrl.text.trim().isEmpty) return;
                              final newId = 'BK-${DateTime.now().millisecondsSinceEpoch}';
                              ref.read(bookCatalogProvider.notifier).addBook(
                                BookEntity(
                                  id: newId,
                                  branchId: widget.branchId,
                                  isbn: _isbnCtrl.text.trim(),
                                  title: _titleCtrl.text.trim(),
                                  author: _authorCtrl.text.trim(),
                                  publisher: _publisherCtrl.text.trim(),
                                  barcode: 'BAR-${newId.substring(newId.length - 6)}',
                                  rfidTag: 'RFID-${newId.substring(newId.length - 6)}',
                                  ddcClassification: _ddcCtrl.text.trim(),
                                  category: _categoryCtrl.text.trim(),
                                  procurementCost: double.tryParse(_costCtrl.text.trim()) ?? 20.0,
                                  status: 'Available',
                                  type: _bookType,
                                ),
                              );
                              _titleCtrl.clear();
                              _authorCtrl.clear();
                              _isbnCtrl.clear();
                              _showSnack(context, 'Book added to branch catalog cataloged successfully!');
                            },
                            icon: const Icon(Icons.library_add_rounded, size: 14),
                            label: const Text('Procure & Catalog'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barcode Simulator Card
                    if (books.isNotEmpty)
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode & RFID Generator', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPri)),
                            const SizedBox(height: 10),
                            Text('Generated for: ${books.first.title}', style: TextStyle(fontSize: 10, color: textSec)),
                            const SizedBox(height: 8),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(24, (i) {
                                  return Container(
                                    width: i % 3 == 0 ? 3 : (i % 2 == 0 ? 1 : 2),
                                    color: i % 4 == 0 ? Colors.white : Colors.black,
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                books.first.barcode,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookStatusTag(String status) {
    Color color;
    switch (status) {
      case 'Available':
        color = Colors.green;
        break;
      case 'Issued':
        color = AppColors.secondary;
        break;
      default:
        color = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Book Issue, Return & Renewals
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _IssuesReturnsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _IssuesReturnsTab({required this.branchId});

  @override
  ConsumerState<_IssuesReturnsTab> createState() => _IssuesReturnsTabState();
}

class _IssuesReturnsTabState extends ConsumerState<_IssuesReturnsTab> {
  String? _selectedBookId;
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = ref.watch(bookCatalogProvider).where((b) => b.branchId == widget.branchId && b.status == 'Available').toList();
    final members = ref.watch(libraryMembersProvider).where((m) => m.branchId == widget.branchId).toList();
    final transactions = ref.watch(bookTransactionsProvider).where((t) => t.branchId == widget.branchId).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumn(
            children: [
              // Issue Book Form
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Issue Book Transaction', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPri)),
                      const SizedBox(height: 12),
                      if (books.isNotEmpty)
                        _DropdownFilter(
                          label: 'Select Book',
                          value: _selectedBookId ?? books.first.id,
                          items: books.map((b) => b.id).toList(),
                          displayItems: books.map((b) => b.title).toList(),
                          onChanged: (v) => setState(() => _selectedBookId = v),
                          isDark: isDark,
                        )
                      else
                        Text('No available books to issue.', style: TextStyle(color: textSec, fontSize: 11)),
                      const SizedBox(height: 12),
                      if (members.isNotEmpty)
                        _DropdownFilter(
                          label: 'Select Library Member',
                          value: _selectedMemberId ?? members.first.id,
                          items: members.map((m) => m.id).toList(),
                          displayItems: members.map((m) => '${m.name} (${m.memberType})').toList(),
                          onChanged: (v) => setState(() => _selectedMemberId = v),
                          isDark: isDark,
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: books.isEmpty || members.isEmpty
                            ? null
                            : () {
                                final bkId = _selectedBookId ?? books.first.id;
                                final memId = _selectedMemberId ?? members.first.id;
                                final book = books.firstWhere((b) => b.id == bkId);
                                final member = members.firstWhere((m) => m.id == memId);

                                ref.read(bookTransactionsProvider.notifier).issueBook(
                                  BookTransactionEntity(
                                    id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
                                    branchId: widget.branchId,
                                    bookId: bkId,
                                    bookTitle: book.title,
                                    memberId: memId,
                                    memberName: member.name,
                                    issueDate: DateTime.now(),
                                    dueDate: DateTime.now().add(const Duration(days: 14)),
                                    finesCharged: 0.0,
                                    status: 'Issued',
                                  ),
                                );

                                ref.read(bookCatalogProvider.notifier).updateBookStatus(bkId, 'Issued');
                                _showSnack(context, 'Book issued to ${member.name} successfully!');
                              },
                        icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                        label: const Text('Issue Resource'),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Issue logs ledger
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Library Issues Registry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                    const SizedBox(height: 10),
                    ...transactions.map((tx) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tx.bookTitle, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                                  _buildTxStatusTag(tx.status),
                                ],
                              ),
                              Text('Borrower: ${tx.memberName} • Due: ${tx.dueDate.day}/${tx.dueDate.month}/${tx.dueDate.year}', style: TextStyle(color: textSec, fontSize: 11)),
                              if (tx.finesCharged > 0.0)
                                Text('Accumulated Fine: Rs. ${tx.finesCharged.toStringAsFixed(0)} (Late policy applied)', style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                              if (tx.status != 'Returned') ...[
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        ref.read(bookTransactionsProvider.notifier).renewBook(tx.id, DateTime.now().add(const Duration(days: 7)));
                                        _showSnack(context, 'Book renewal registered. Due date extended by 7 days.');
                                      },
                                      child: const Text('Renew', style: TextStyle(fontSize: 11)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(bookTransactionsProvider.notifier).returnBook(tx.id, tx.finesCharged);
                                        ref.read(bookCatalogProvider.notifier).updateBookStatus(tx.bookId, 'Available');
                                        _showSnack(context, 'Book returned. Total fines: Rs. ${tx.finesCharged.toStringAsFixed(0)} settled.');
                                      },
                                      child: const Text('Return', style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTxStatusTag(String status) {
    Color color;
    switch (status) {
      case 'Returned':
        color = Colors.green;
        break;
      case 'Overdue':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — Members & Library Cards
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MembersCardsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _MembersCardsTab({required this.branchId});

  @override
  ConsumerState<_MembersCardsTab> createState() => _MembersCardsTabState();
}

class _MembersCardsTabState extends ConsumerState<_MembersCardsTab> {
  final _nameCtrl = TextEditingController();
  final _memIdCtrl = TextEditingController();
  String _memberType = 'Student';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final members = ref.watch(libraryMembersProvider).where((m) => m.branchId == widget.branchId).toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumn(
            children: [
              // Register Member
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Register Library Member', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPri)),
                      const SizedBox(height: 12),
                      _FormField(controller: _nameCtrl, label: 'Member Name', isDark: isDark),
                      const SizedBox(height: 8),
                      _FormField(controller: _memIdCtrl, label: 'Student or Staff ID', isDark: isDark),
                      const SizedBox(height: 12),
                      _DropdownFilter(
                        label: 'Member Classification',
                        value: _memberType,
                        items: const ['Student', 'Staff'],
                        displayItems: const ['Student Member', 'Staff Faculty Member'],
                        onChanged: (v) => setState(() => _memberType = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_nameCtrl.text.trim().isEmpty) return;
                          ref.read(libraryMembersProvider.notifier).addMember(
                            LibraryMemberEntity(
                              id: 'MEM-${DateTime.now().millisecondsSinceEpoch}',
                              branchId: widget.branchId,
                              studentOrStaffId: _memIdCtrl.text.trim(),
                              name: _nameCtrl.text.trim(),
                              memberType: _memberType,
                              cardGenerated: false,
                            ),
                          );
                          _nameCtrl.clear();
                          _memIdCtrl.clear();
                          _showSnack(context, 'Library member registration complete!');
                        },
                        icon: const Icon(Icons.person_add_rounded, size: 14),
                        label: const Text('Register Member'),
                      ),
                    ],
                  ),
                ),
              ),

              // Library Members list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Members List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                    const SizedBox(height: 10),
                    ...members.map((m) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                                    Text(m.memberType, style: TextStyle(fontSize: 10, color: textSec, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text('ID: ${m.studentOrStaffId}', style: TextStyle(color: textSec, fontSize: 11)),
                                const SizedBox(height: 8),
                                if (m.cardGenerated) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue.shade400),
                                      color: Colors.blue.shade50.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          child: Icon(Icons.person_rounded, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('OFFICIAL LIBRARY CARD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                                            Text(m.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPri)),
                                            Text('Branch: ${widget.branchId}', style: TextStyle(fontSize: 9, color: textSec)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton.icon(
                                    onPressed: () => _showSnack(context, 'Library card PDF printed!'),
                                    icon: const Icon(Icons.print_rounded, size: 12),
                                    label: const Text('Print Badge Card', style: TextStyle(fontSize: 11)),
                                  ),
                                ] else
                                  OutlinedButton(
                                    onPressed: () {
                                      ref.read(libraryMembersProvider.notifier).generateLibraryCard(m.id);
                                      _showSnack(context, 'Library card generated for ${m.name}');
                                    },
                                    child: const Text('Generate Library Card'),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — Lost & Damaged Books Tracking
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LostDamagedTab extends ConsumerWidget {
  final String branchId;
  const _LostDamagedTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = ref.watch(bookCatalogProvider).where((b) => b.branchId == branchId && (b.status == 'Lost' || b.status == 'Damaged')).toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lost / Damaged Book Audits & Replacements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 12),
          if (books.isEmpty)
            Text('No books currently flagged as lost or damaged in this branch library.', style: TextStyle(color: textSec))
          else
            ...books.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(b.status == 'Lost' ? Icons.search_off_rounded : Icons.broken_image_rounded, color: AppColors.error),
                      title: Text(b.title, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                      subtitle: Text('Author: ${b.author} • Replacement Cost: Rs. ${b.procurementCost.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          ref.read(bookCatalogProvider.notifier).updateBookStatus(b.id, 'Available');
                          _showSnack(context, 'Book marked as Replaced & Restocked. Status set to Available.');
                        },
                        child: const Text('Replace & Restock', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 5 — Subscriptions & Budgets
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SubscriptionsBudgetsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _SubscriptionsBudgetsTab({required this.branchId});

  @override
  ConsumerState<_SubscriptionsBudgetsTab> createState() => _SubscriptionsBudgetsTabState();
}

class _SubscriptionsBudgetsTabState extends ConsumerState<_SubscriptionsBudgetsTab> {
  final _subTitleCtrl = TextEditingController();
  final _subCostCtrl = TextEditingController(text: '120.0');

  @override
  void dispose() {
    _subTitleCtrl.dispose();
    _subCostCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgets = ref.watch(libraryBudgetsProvider).where((b) => b.branchId == widget.branchId).toList();
    final books = ref.watch(bookCatalogProvider).where((b) => b.branchId == widget.branchId && (b.type == 'Magazine' || b.type == 'Journal')).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final double spentSum = budgets.isEmpty ? 0.0 : budgets.first.spent;
    final double allocatedSum = budgets.isEmpty ? 1000.0 : budgets.first.allocated;
    final double percent = (spentSum / allocatedSum) > 1.0 ? 1.0 : (spentSum / allocatedSum);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumn(
            children: [
              // Budget Card
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Library Budget Ledger (Branch-Scoped)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPri)),
                      const SizedBox(height: 12),
                      Text('Allocated Budget: Rs. ${allocatedSum.toStringAsFixed(0)}', style: TextStyle(color: textPri, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Spent Budget: Rs. ${spentSum.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 10,
                          color: percent > 0.9 ? AppColors.error : AppColors.primary,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subscriptions Add
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Procure Magazine/Journal Subscription', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPri)),
                      const SizedBox(height: 12),
                      _FormField(controller: _subTitleCtrl, label: 'Subscription Title (e.g. Science Today)', isDark: isDark),
                      const SizedBox(height: 8),
                      _FormField(controller: _subCostCtrl, label: 'Cost', isDark: isDark, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_subTitleCtrl.text.trim().isEmpty) return;
                          final cost = double.tryParse(_subCostCtrl.text.trim()) ?? 100.0;
                          ref.read(bookCatalogProvider.notifier).addBook(
                            BookEntity(
                              id: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
                              branchId: widget.branchId,
                              isbn: 'ISSN-SUB',
                              title: _subTitleCtrl.text.trim(),
                              author: 'Various',
                              publisher: 'Global Press',
                              barcode: 'BAR-SUB-01',
                              rfidTag: 'RFID-SUB',
                              ddcClassification: '050',
                              category: 'Periodicals',
                              procurementCost: cost,
                              status: 'Available',
                              type: 'Magazine',
                            ),
                          );

                          if (budgets.isNotEmpty) {
                            ref.read(libraryBudgetsProvider.notifier).updateSpent(budgets.first.id, cost);
                          }
                          _subTitleCtrl.clear();
                          _showSnack(context, 'Magazine subscription purchased & cataloged!');
                        },
                        icon: const Icon(Icons.bookmark_added_rounded, size: 14),
                        label: const Text('Subscribe & Fund'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Active Subscriptions Catalog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          ...books.map((b) => Card(
                child: ListTile(
                  leading: const Icon(Icons.newspaper_rounded, color: AppColors.primary),
                  title: Text(b.title, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                  subtitle: Text('Type: ${b.type} • Procurement Cost: Rs. ${b.procurementCost.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                ),
              )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 6 — Library Analytics & Comparisons
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LibraryAnalyticsTab extends ConsumerWidget {
  final String branchId;
  const _LibraryAnalyticsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final books = ref.watch(bookCatalogProvider);
    final transactions = ref.watch(bookTransactionsProvider);

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final int delTotal = books.where((b) => b.branchId == 'BR-001').length;
    final int delIssues = transactions.where((t) => t.branchId == 'BR-001' && t.status == 'Issued').length;

    final int mumTotal = books.where((b) => b.branchId == 'BR-002').length;
    final int mumIssues = transactions.where((t) => t.branchId == 'BR-002' && t.status == 'Issued').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization-level Library Catalog Analytics Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Books Cataloged across Branches', style: TextStyle(fontSize: 12, color: textSec)),
                const SizedBox(height: 8),
                _buildAnalysisProgressBar('Delhi Branch Library ($delTotal books)', delTotal / 10.0, AppColors.secondary, isDark),
                _buildAnalysisProgressBar('Mumbai Branch Library ($mumTotal books)', mumTotal / 10.0, AppColors.primary, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Book Issue Rates comparison', style: TextStyle(fontSize: 12, color: textSec)),
                const SizedBox(height: 8),
                _buildAnalysisProgressBar('Delhi Branch Issue count ($delIssues)', delIssues / 5.0, AppColors.warning, isDark),
                _buildAnalysisProgressBar('Mumbai Branch Issue count ($mumIssues)', mumIssues / 5.0, AppColors.primary, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisProgressBar(String label, double val, Color color, bool isDark) {
    final displayVal = val > 1.0 ? 1.0 : val;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${(displayVal * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: displayVal,
              minHeight: 8,
              color: color,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITIES & SHARED WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String> displayItems;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.displayItems,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexOf(value);
    final selectedValue = selectedIndex != -1 ? value : (items.isNotEmpty ? items.first : '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue.isNotEmpty ? selectedValue : null,
          hint: Text(label),
          isDense: true,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: List.generate(items.length, (index) {
            return DropdownMenuItem<String>(
              value: items[index],
              child: Text(displayItems[index]),
            );
          }),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.isDark,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}
