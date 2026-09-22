import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../payroll_providers.dart';

class HRPayrollRepository {
  final ApiClient _apiClient;

  HRPayrollRepository(this._apiClient);

  /// Upsert salary structure
  Future<SalaryStructureEntity?> upsertSalaryStructure({
    required String staffId,
    required String branchId,
    required double basic,
    double hra = 0,
    double da = 0,
    double allowances = 0,
    double deductions = 0,
    String? effectiveFrom,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/hr/salary-structure', data: {
        'staffId': staffId,
        'branchId': branchId,
        'basic': basic,
        'hra': hra,
        'da': da,
        'allowances': allowances,
        'deductions': deductions,
        if (effectiveFrom != null) 'effectiveFrom': effectiveFrom,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SalaryStructureEntity(
          staffId: data['staffId']?.toString() ?? staffId,
          branchId: data['branchId']?.toString() ?? branchId,
          basicPay: (data['basic'] as num?)?.toDouble() ?? basic,
          hra: (data['hra'] as num?)?.toDouble() ?? hra,
          da: (data['da'] as num?)?.toDouble() ?? da,
          specialAllowance: (data['allowances'] as num?)?.toDouble() ?? allowances,
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return null;
  }

  /// Fetch salary structures for branch
  Future<List<SalaryStructureEntity>> fetchSalaryStructures(String branchId) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff/hr/salary-structure',
        queryParameters: {'branchId': branchId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return SalaryStructureEntity(
            staffId: m['staffId']?.toString() ?? '',
            branchId: m['branchId']?.toString() ?? branchId,
            basicPay: (m['basic'] as num?)?.toDouble() ?? 0.0,
            hra: (m['hra'] as num?)?.toDouble() ?? 0.0,
            da: (m['da'] as num?)?.toDouble() ?? 0.0,
            specialAllowance: (m['allowances'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Process monthly payroll
  Future<Map<String, dynamic>?> processPayroll({
    required String branchId,
    required int month,
    required int year,
    List<String>? staffIds,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/hr/process', data: {
        'branchId': branchId,
        'month': month,
        'year': year,
        if (staffIds != null && staffIds.isNotEmpty) 'staffIds': staffIds,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return null;
  }

  /// Fetch payroll records / salary slips
  Future<List<SalarySlipEntity>> fetchPayrollRecords({
    required String branchId,
    int? month,
    int? year,
    String? status,
    String? staffId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff/hr/records',
        queryParameters: {
          'branchId': branchId,
          if (month != null) 'month': month,
          if (year != null) 'year': year,
          if (status != null) 'status': status,
          if (staffId != null) 'staffId': staffId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          final staff = m['staff'] as Map<String, dynamic>?;
          final staffName = staff != null
              ? '${staff['firstName'] ?? ''} ${staff['lastName'] ?? ''}'.trim()
              : 'Staff Member';

          return SalarySlipEntity(
            id: m['id']?.toString() ?? '',
            staffId: m['staffId']?.toString() ?? '',
            staffName: staffName,
            designation: staff?['designation']?.toString() ?? 'Teacher',
            branchId: m['branchId']?.toString() ?? branchId,
            monthYear: '${_monthName(m['month'] as int? ?? 1)} ${m['year'] ?? 2026}',
            basicPay: (m['grossSalary'] as num?)?.toDouble() ?? 0.0,
            da: 0.0,
            hra: 0.0,
            ta: 0.0,
            specialAllowance: 0.0,
            pfDeduction: (m['totalDeductions'] as num?)?.toDouble() ?? 0.0,
            esiDeduction: 0.0,
            tdsDeduction: 0.0,
            status: m['status'] == 'PAID'
                ? 'Disbursed'
                : (m['status'] == 'APPROVED' ? 'Approved' : 'Draft'),
            processedAt: m['processedAt']?.toString() ?? '',
          );
        }).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Update single payroll record status
  Future<bool> updatePayrollStatus(String recordId, String status) async {
    try {
      final response = await _apiClient.dio.put('/staff/hr/records/$recordId/status', data: {
        'status': status.toUpperCase(),
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Bulk update payroll records status
  Future<bool> bulkUpdatePayrollStatus({
    required String branchId,
    required int month,
    required int year,
    required String status,
  }) async {
    try {
      final response = await _apiClient.dio.put('/staff/hr/bulk-status', data: {
        'branchId': branchId,
        'month': month,
        'year': year,
        'status': status.toUpperCase(),
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return 'Month $month';
  }
}
