import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Salary Structure Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SalaryStructureEntity {
  final String staffId;
  final String branchId;
  final double basicPay;
  final double da; // Dearness Allowance
  final double hra; // House Rent Allowance
  final double ta; // Travel Allowance
  final double specialAllowance;
  final double pfRate; // percentage (default 12%)
  final double esiRate; // percentage (default 0.75%)
  final double tdsRate; // monthly income tax TDS flat rate

  const SalaryStructureEntity({
    required this.staffId,
    required this.branchId,
    this.basicPay = 25000.0,
    this.da = 5000.0,
    this.hra = 8000.0,
    this.ta = 2000.0,
    this.specialAllowance = 3000.0,
    this.pfRate = 12.0,
    this.esiRate = 0.75,
    this.tdsRate = 5.0,
  });

  double get grossEarnings => basicPay + da + hra + ta + specialAllowance;
  
  double get pfDeduction => basicPay * (pfRate / 100);
  double get esiDeduction => grossEarnings * (esiRate / 100);
  double get tdsDeduction => grossEarnings * (tdsRate / 100);

  double get totalDeductions => pfDeduction + esiDeduction + tdsDeduction;
  double get netSalary => grossEarnings - totalDeductions;

  SalaryStructureEntity copyWith({
    double? basicPay,
    double? da,
    double? hra,
    double? ta,
    double? specialAllowance,
    double? pfRate,
    double? esiRate,
    double? tdsRate,
  }) {
    return SalaryStructureEntity(
      staffId: staffId,
      branchId: branchId,
      basicPay: basicPay ?? this.basicPay,
      da: da ?? this.da,
      hra: hra ?? this.hra,
      ta: ta ?? this.ta,
      specialAllowance: specialAllowance ?? this.specialAllowance,
      pfRate: pfRate ?? this.pfRate,
      esiRate: esiRate ?? this.esiRate,
      tdsRate: tdsRate ?? this.tdsRate,
    );
  }
}

class SalaryStructuresNotifier extends StateNotifier<List<SalaryStructureEntity>> {
  SalaryStructuresNotifier() : super([
    // Vikram Malhotra STF-001 (Delhi)
    const SalaryStructureEntity(
      staffId: 'STF-001',
      branchId: 'BR-001',
      basicPay: 40000.0,
      da: 8000.0,
      hra: 12000.0,
      ta: 4000.0,
      specialAllowance: 6000.0,
    ),
    // Sunita Sharma STF-002 (Delhi)
    const SalaryStructureEntity(
      staffId: 'STF-002',
      branchId: 'BR-001',
      basicPay: 28000.0,
      da: 5000.0,
      hra: 8000.0,
      ta: 2500.0,
      specialAllowance: 3500.0,
    ),
    // Rahul Deshmukh STF-003 (Mumbai)
    const SalaryStructureEntity(
      staffId: 'STF-003',
      branchId: 'BR-002',
      basicPay: 55000.0,
      da: 11000.0,
      hra: 16000.0,
      ta: 5000.0,
      specialAllowance: 8000.0,
    ),
  ]);

  void updateStructure(String staffId, SalaryStructureEntity updated) {
    state = state.map((s) => s.staffId == staffId ? updated : s).toList();
  }
}

final salaryStructuresProvider = StateNotifierProvider<SalaryStructuresNotifier, List<SalaryStructureEntity>>((ref) {
  return SalaryStructuresNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Loan Request Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffLoanEntity {
  final String id;
  final String staffId;
  final String staffName;
  final String branchId;
  final double principalAmount;
  final double monthlyEmi;
  final double amountPaid;
  final String approvalDate;
  final String status; // 'Requested', 'Approved', 'Rejected', 'Active', 'Settled'

  const StaffLoanEntity({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.branchId,
    required this.principalAmount,
    required this.monthlyEmi,
    this.amountPaid = 0.0,
    this.approvalDate = '',
    required this.status,
  });

  double get outstandingAmount => principalAmount - amountPaid;

  StaffLoanEntity copyWith({String? status, double? amountPaid, String? approvalDate}) {
    return StaffLoanEntity(
      id: id,
      staffId: staffId,
      staffName: staffName,
      branchId: branchId,
      principalAmount: principalAmount,
      monthlyEmi: monthlyEmi,
      amountPaid: amountPaid ?? this.amountPaid,
      approvalDate: approvalDate ?? this.approvalDate,
      status: status ?? this.status,
    );
  }
}

class StaffLoansNotifier extends StateNotifier<List<StaffLoanEntity>> {
  StaffLoansNotifier() : super([
    const StaffLoanEntity(
      id: 'LN-STF002-101',
      staffId: 'STF-002',
      staffName: 'Sunita Sharma',
      branchId: 'BR-001',
      principalAmount: 50000.0,
      monthlyEmi: 5000.0,
      amountPaid: 20000.0,
      approvalDate: '2026-02-01',
      status: 'Active',
    ),
  ]);

  void logLoanRequest(StaffLoanEntity request) {
    state = [request, ...state];
  }

  void updateLoanStatus(String id, String status) {
    state = state.map((l) => l.id == id ? l.copyWith(status: status, approvalDate: '2026-08-18') : l).toList();
  }

  void payEMI(String id, double emiAmount) {
    state = state.map((l) {
      if (l.id == id) {
        final newPaid = l.amountPaid + emiAmount;
        final newStatus = newPaid >= l.principalAmount ? 'Settled' : l.status;
        return l.copyWith(amountPaid: newPaid, status: newStatus);
      }
      return l;
    }).toList();
  }
}

final staffLoansProvider = StateNotifierProvider<StaffLoansNotifier, List<StaffLoanEntity>>((ref) {
  return StaffLoansNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Appraisal & Salary Increment Log
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffAppraisalEntity {
  final String id;
  final String staffId;
  final String staffName;
  final String branchId;
  final String reviewPeriod; // e.g. "Annual 2025-26"
  final double oldBasicPay;
  final double newBasicPay;
  final double percentageIncrement;
  final String effectiveDate;
  final String approvedBy;

  const StaffAppraisalEntity({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.branchId,
    required this.reviewPeriod,
    required this.oldBasicPay,
    required this.newBasicPay,
    required this.percentageIncrement,
    required this.effectiveDate,
    required this.approvedBy,
  });
}

class StaffAppraisalsNotifier extends StateNotifier<List<StaffAppraisalEntity>> {
  StaffAppraisalsNotifier() : super([
    const StaffAppraisalEntity(
      id: 'APR-001',
      staffId: 'STF-001',
      staffName: 'Vikram Malhotra',
      branchId: 'BR-001',
      reviewPeriod: 'Annual Appraisal 2025',
      oldBasicPay: 35000.0,
      newBasicPay: 40000.0,
      percentageIncrement: 14.2,
      effectiveDate: '2026-04-01',
      approvedBy: 'Dr. Principal',
    ),
  ]);

  void logAppraisal(StaffAppraisalEntity appraisal) {
    state = [appraisal, ...state];
  }
}

final staffAppraisalsProvider = StateNotifierProvider<StaffAppraisalsNotifier, List<StaffAppraisalEntity>>((ref) {
  return StaffAppraisalsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Processed Monthly Salary Slip Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SalarySlipEntity {
  final String id; // Slip ID e.g., SLP-BR001-202608-01
  final String staffId;
  final String staffName;
  final String designation;
  final String branchId;
  final String monthYear; // e.g., "August 2026"
  
  // Earnings Breakup
  final double basicPay;
  final double da;
  final double hra;
  final double ta;
  final double specialAllowance;
  final double overtimeAmount;
  final double bonusAmount;
  final double arrearAmount;

  // Deductions Breakup
  final double pfDeduction;
  final double esiDeduction;
  final double tdsDeduction;
  final double loanDeduction;

  final String bankName;
  final String bankAccountNumber;
  final String status; // 'Draft', 'Approved', 'Disbursed'
  final String processedAt;

  const SalarySlipEntity({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.designation,
    required this.branchId,
    required this.monthYear,
    required this.basicPay,
    required this.da,
    required this.hra,
    required this.ta,
    required this.specialAllowance,
    this.overtimeAmount = 0.0,
    this.bonusAmount = 0.0,
    this.arrearAmount = 0.0,
    required this.pfDeduction,
    required this.esiDeduction,
    required this.tdsDeduction,
    this.loanDeduction = 0.0,
    this.bankName = 'State Bank of India',
    this.bankAccountNumber = '33445566778',
    required this.status,
    required this.processedAt,
  });

  double get grossEarnings => basicPay + da + hra + ta + specialAllowance + overtimeAmount + bonusAmount + arrearAmount;
  double get totalDeductions => pfDeduction + esiDeduction + tdsDeduction + loanDeduction;
  double get netDisbursed => grossEarnings - totalDeductions;

  SalarySlipEntity copyWith({String? status}) {
    return SalarySlipEntity(
      id: id,
      staffId: staffId,
      staffName: staffName,
      designation: designation,
      branchId: branchId,
      monthYear: monthYear,
      basicPay: basicPay,
      da: da,
      hra: hra,
      ta: ta,
      specialAllowance: specialAllowance,
      overtimeAmount: overtimeAmount,
      bonusAmount: bonusAmount,
      arrearAmount: arrearAmount,
      pfDeduction: pfDeduction,
      esiDeduction: esiDeduction,
      tdsDeduction: tdsDeduction,
      loanDeduction: loanDeduction,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      status: status ?? this.status,
      processedAt: processedAt,
    );
  }
}

class SalarySlipsNotifier extends StateNotifier<List<SalarySlipEntity>> {
  SalarySlipsNotifier() : super([
    // Delhi Central SLP July 2026
    const SalarySlipEntity(
      id: 'SLP-DEL-202607-01',
      staffId: 'STF-001',
      staffName: 'Vikram Malhotra',
      designation: 'Senior Math HOD',
      branchId: 'BR-001',
      monthYear: 'July 2026',
      basicPay: 40000.0,
      da: 8000.0,
      hra: 12000.0,
      ta: 4000.0,
      specialAllowance: 6000.0,
      pfDeduction: 4800.0,
      esiDeduction: 525.0,
      tdsDeduction: 3500.0,
      status: 'Disbursed',
      processedAt: '2026-07-31',
    ),
    const SalarySlipEntity(
      id: 'SLP-DEL-202607-02',
      staffId: 'STF-002',
      staffName: 'Sunita Sharma',
      designation: 'Secondary English Teacher',
      branchId: 'BR-001',
      monthYear: 'July 2026',
      basicPay: 28000.0,
      da: 5000.0,
      hra: 8000.0,
      ta: 2500.0,
      specialAllowance: 3500.0,
      loanDeduction: 5000.0,
      pfDeduction: 3360.0,
      esiDeduction: 330.0,
      tdsDeduction: 2200.0,
      status: 'Disbursed',
      processedAt: '2026-07-31',
    ),
  ]);

  void addSalarySlip(SalarySlipEntity slip) {
    state = [...state, slip];
  }

  void approveSlips(String monthYear, String branchId) {
    state = state.map((s) {
      if (s.monthYear == monthYear && s.branchId == branchId && s.status == 'Draft') {
        return s.copyWith(status: 'Approved');
      }
      return s;
    }).toList();
  }

  void disburseSlips(String monthYear, String branchId) {
    state = state.map((s) {
      if (s.monthYear == monthYear && s.branchId == branchId && s.status == 'Approved') {
        return s.copyWith(status: 'Disbursed');
      }
      return s;
    }).toList();
  }
}

final salarySlipsProvider = StateNotifierProvider<SalarySlipsNotifier, List<SalarySlipEntity>>((ref) {
  return SalarySlipsNotifier();
});
