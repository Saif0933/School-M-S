import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../providers.dart';

class StaffRepository {
  final ApiClient _apiClient;

  StaffRepository(this._apiClient);

  /// Fetch list of staff members with branch and search filtering
  Future<List<StaffEntity>> fetchStaffList({
    String? branchId,
    String? designation,
    String? department,
    String? status,
    String? search,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff',
        queryParameters: {
          if (branchId != null) 'branchId': branchId,
          if (designation != null) 'designation': designation,
          if (department != null) 'department': department,
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => _mapToStaffEntity(item as Map<String, dynamic>)).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Fetch single staff details
  Future<StaffEntity?> fetchStaffById(String staffId) async {
    try {
      final response = await _apiClient.dio.get('/staff/$staffId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return _mapToStaffEntity(response.data['data'] as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return null;
  }

  /// Register new staff / teacher
  Future<StaffEntity?> registerStaff({
    required String branchId,
    required String firstName,
    required String lastName,
    required String email,
    String? employeeId,
    String? phone,
    String? designation,
    String? department,
    String? qualification,
    int? experienceYears,
    String? role,
    String? password,
    String? dateOfJoining,
    String? gender,
    String? dateOfBirth,
    String? bloodGroup,
    String? address,
    String? specialization,
    String? institution,
    String? previousEmployer,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff', data: {
        'branchId': branchId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (employeeId != null && employeeId.isNotEmpty) 'employeeId': employeeId,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (designation != null && designation.isNotEmpty) 'designation': designation,
        if (department != null && department.isNotEmpty) 'department': department,
        if (qualification != null && qualification.isNotEmpty) 'qualification': qualification,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (role != null && role.isNotEmpty) 'role': role,
        if (password != null && password.isNotEmpty) 'password': password,
        if (dateOfJoining != null && dateOfJoining.isNotEmpty) 'joinDate': dateOfJoining,
        if (gender != null && gender.isNotEmpty) 'gender': gender.toUpperCase(),
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final resData = response.data;
        if (resData is Map && resData['success'] == true && resData['data'] != null) {
          final created = _mapToStaffEntity(Map<String, dynamic>.from(resData['data'] as Map));
          return created.copyWith(
            address: address,
            specialization: specialization,
            institution: institution,
            previousEmployer: previousEmployer,
            bloodGroup: bloodGroup,
            dateOfBirth: dateOfBirth,
          );
        }
      }
    } on DioException catch (e) {
      final resData = e.response?.data;
      String errorMsg = e.message ?? 'Staff registration failed';
      if (resData is Map && resData['message'] != null) {
        errorMsg = resData['message'].toString();
      }
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('Unexpected error in registerStaff: $e');
      throw Exception(e.toString());
    }
    return null;
  }

  /// Update staff profile
  Future<StaffEntity?> updateStaff(String staffId, {
    String? firstName,
    String? lastName,
    String? phone,
    String? designation,
    String? department,
    String? qualification,
    int? experienceYears,
    String? status,
  }) async {
    try {
      final response = await _apiClient.dio.put('/staff/$staffId', data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (designation != null) 'designation': designation,
        if (department != null) 'department': department,
        if (qualification != null) 'qualification': qualification,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (status != null) 'status': status.toUpperCase(),
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return _mapToStaffEntity(response.data['data'] as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return null;
  }

  /// Delete staff member
  Future<bool> deleteStaff(String staffId) async {
    try {
      final response = await _apiClient.dio.delete('/staff/$staffId');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Bulk import staff
  Future<List<StaffEntity>> bulkImportStaff(String branchId, List<Map<String, dynamic>> staffList) async {
    try {
      final response = await _apiClient.dio.post('/staff/bulk', data: {
        'branchId': branchId,
        'staff': staffList,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => _mapToStaffEntity(item as Map<String, dynamic>)).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Add cross-branch assignment
  Future<bool> addSharedBranch(String staffId, String targetBranchId) async {
    try {
      final response = await _apiClient.dio.post('/staff/$staffId/shared-branch', data: {
        'targetBranchId': targetBranchId,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Remove cross-branch assignment
  Future<bool> removeSharedBranch(String staffId, String targetBranchId) async {
    try {
      final response = await _apiClient.dio.delete('/staff/$staffId/shared-branch/$targetBranchId');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Request staff branch transfer
  Future<bool> requestTransfer(String staffId, String toBranchId, {String? remarks}) async {
    try {
      final response = await _apiClient.dio.post('/staff/$staffId/transfer', data: {
        'toBranchId': toBranchId,
        if (remarks != null) 'remarks': remarks,
      });
      return (response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Fetch transfer requests
  Future<List<StaffTransferEntity>> fetchTransferRequests({String? branchId, String? staffId}) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff/transfers',
        queryParameters: {
          if (branchId != null) 'branchId': branchId,
          if (staffId != null) 'staffId': staffId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return StaffTransferEntity(
            id: m['id']?.toString() ?? '',
            staffId: m['staffId']?.toString() ?? '',
            fromBranchId: m['fromBranchId']?.toString() ?? '',
            toBranchId: m['toBranchId']?.toString() ?? '',
            requestDate: m['requestedAt']?.toString().substring(0, 10) ?? '',
            reason: m['remarks']?.toString() ?? '',
            status: m['status']?.toString() ?? 'Pending',
          );
        }).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Respond to transfer request
  Future<bool> respondTransferRequest(String requestId, String status, {String? remarks}) async {
    try {
      final response = await _apiClient.dio.put('/staff/transfers/$requestId', data: {
        'status': status.toUpperCase(),
        if (remarks != null) 'remarks': remarks,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Assign teacher to subject and section
  Future<bool> assignSubjectTeacher({
    required String sectionId,
    required String subjectId,
    required String staffId,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/academic/subject-teacher', data: {
        'sectionId': sectionId,
        'subjectId': subjectId,
        'staffId': staffId,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Remove teacher from subject & section
  Future<bool> removeSubjectTeacher({
    required String sectionId,
    required String subjectId,
  }) async {
    try {
      final response = await _apiClient.dio.delete(
        '/staff/academic/subject-teacher',
        queryParameters: {
          'sectionId': sectionId,
          'subjectId': subjectId,
        },
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Assign class teacher to section
  Future<bool> assignClassTeacher({
    required String sectionId,
    required String classTeacherId,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/academic/class-teacher', data: {
        'sectionId': sectionId,
        'classTeacherId': classTeacherId,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Mark staff attendance
  Future<bool> markAttendance({
    required String staffId,
    required String branchId,
    required String date,
    required String status,
    String? method,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/attendance', data: {
        'staffId': staffId,
        'branchId': branchId,
        'date': date,
        'status': status.toUpperCase(),
        if (method != null) 'method': method.toUpperCase(),
        if (remarks != null) 'remarks': remarks,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Bulk mark staff attendance
  Future<bool> bulkMarkAttendance({
    required String branchId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/attendance/bulk', data: {
        'branchId': branchId,
        'date': date,
        'records': records,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Fetch staff attendance records
  Future<List<StaffAttendanceEntity>> fetchAttendance({
    required String branchId,
    String? startDate,
    String? endDate,
    String? staffId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff/attendance',
        queryParameters: {
          'branchId': branchId,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (staffId != null) 'staffId': staffId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return StaffAttendanceEntity(
            id: m['id']?.toString() ?? '',
            staffId: m['staffId']?.toString() ?? '',
            branchId: m['branchId']?.toString() ?? '',
            date: m['date']?.toString().substring(0, 10) ?? '',
            status: m['status']?.toString() ?? 'Present',
          );
        }).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Apply for staff leave
  Future<bool> applyLeave({
    required String staffId,
    required String branchId,
    required String leaveType,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.dio.post('/staff/leaves', data: {
        'staffId': staffId,
        'branchId': branchId,
        'leaveType': leaveType.toUpperCase(),
        'startDate': startDate,
        'endDate': endDate,
        if (reason != null) 'reason': reason,
      });
      return (response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Fetch staff leave applications
  Future<List<StaffLeaveEntity>> fetchLeaves({
    required String branchId,
    String? staffId,
    String? status,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/staff/leaves',
        queryParameters: {
          'branchId': branchId,
          if (staffId != null) 'staffId': staffId,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          final start = DateTime.tryParse(m['startDate']?.toString() ?? '') ?? DateTime.now();
          final end = DateTime.tryParse(m['endDate']?.toString() ?? '') ?? DateTime.now();
          final days = end.difference(start).inDays + 1;

          return StaffLeaveEntity(
            id: m['id']?.toString() ?? '',
            staffId: m['staffId']?.toString() ?? '',
            branchId: m['branchId']?.toString() ?? '',
            leaveType: m['leaveType']?.toString() ?? 'Casual',
            fromDate: m['startDate']?.toString().substring(0, 10) ?? '',
            toDate: m['endDate']?.toString().substring(0, 10) ?? '',
            days: days > 0 ? days : 1,
            reason: m['reason']?.toString() ?? '',
            status: m['status']?.toString() ?? 'Pending',
          );
        }).toList();
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
    return [];
  }

  /// Update staff leave status (Approve / Reject)
  Future<bool> updateLeaveStatus(String leaveId, String status) async {
    try {
      final response = await _apiClient.dio.put('/staff/leaves/$leaveId/status', data: {
        'status': status.toUpperCase(),
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMsg);
    }
  }

  /// Mapper Helper: Convert JSON API map to StaffEntity
  StaffEntity _mapToStaffEntity(Map<String, dynamic> json) {
    final shared = (json['branchAssignments'] as List<dynamic>? ?? [])
        .map((b) => b is Map ? b['branchId']?.toString() ?? '' : '')
        .where((bId) => bId.isNotEmpty)
        .toList();

    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final fullName = (firstName + (lastName.isNotEmpty ? ' $lastName' : '')).trim();

    String joinDateStr = '2026-06-01';
    if (json['joinDate'] != null) {
      final raw = json['joinDate'].toString();
      joinDateStr = raw.contains('T') ? raw.split('T').first : (raw.length >= 10 ? raw.substring(0, 10) : raw);
    }

    return StaffEntity(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      name: fullName.isNotEmpty ? fullName : 'Staff Member',
      designation: json['designation']?.toString() ?? 'Teacher',
      role: json['designation']?.toString() ?? 'Teacher',
      dateOfJoining: joinDateStr,
      isActive: json['status'] == 'ACTIVE',
      status: json['status']?.toString() ?? 'Active',
      departmentId: json['department']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
      yearsOfExperience: json['experienceYears'] is num ? (json['experienceYears'] as num).toInt() : 0,
      sharedBranchIds: shared,
    );
  }
}
