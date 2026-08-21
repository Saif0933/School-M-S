import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  UserRole _mapUserTypeToRole(String? userType) {
    switch (userType?.toUpperCase()) {
      case 'PLATFORM_ADMIN':
        return UserRole.platformAdmin;
      case 'ORG_ADMIN':
        return UserRole.orgAdmin;
      case 'BRANCH_ADMIN':
        return UserRole.branchAdmin;
      case 'TEACHER':
        return UserRole.teacher;
      case 'PARENT':
      case 'GUARDIAN':
        return UserRole.parent;
      case 'STUDENT':
        return UserRole.student;
      case 'ACCOUNTANT':
        return UserRole.accountant;
      default:
        return UserRole.orgAdmin;
    }
  }

  /// Maps backend data to UserEntity
  UserEntity _mapToUserEntity(Map<String, dynamic> userMap, List<dynamic> branches, String? name) {
    final userTypeStr = userMap['userType'] as String?;
    final role = _mapUserTypeToRole(userTypeStr);
    final orgId = userMap['organizationId'] as String?;
    final orgName = userMap['organizationName'] as String?;

    final branchAccessList = branches.map((b) {
      return BranchAccess(
        branchId: b['id'] as String,
        branchName: b['name'] as String,
        branchCode: b['code'] as String,
        role: role,
      );
    }).toList();

    return UserEntity(
      id: userMap['id'] as String,
      name: name ?? orgName ?? 'Organization Admin',
      email: userMap['email'] as String,
      phone: userMap['phone'] as String? ?? '',
      role: role,
      organizationId: orgId,
      organizationName: orgName,
      branchAccess: branchAccessList,
      activeBranchId: branchAccessList.isNotEmpty ? branchAccessList.first.branchId : null,
      isActive: true,
      createdAt: DateTime.tryParse(userMap['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Decode JWT helper
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decode token: $e');
    }
  }

  /// Auto login on startup if token exists
  Future<UserEntity?> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final payload = _decodeJwt(token);
      final email = payload['email'] as String;
      final userType = payload['role'] as String? ?? 'ORG_ADMIN';
      final orgId = payload['organizationId'] as String?;

      List<dynamic> branches = [];
      String? adminName;
      String? orgName;

      if (orgId != null) {
        try {
          final detailsResponse = await _apiClient.dio.get('/organization');
          if (detailsResponse.statusCode == 200 && detailsResponse.data['success'] == true) {
            final detailsData = detailsResponse.data['data'];
            orgName = detailsData['name'] as String?;
            branches = detailsData['branches'] as List<dynamic>? ?? [];
            final admins = detailsData['admins'] as List<dynamic>? ?? [];
            final matchedAdmin = admins.firstWhere((a) => a['email'] == email, orElse: () => null);
            if (matchedAdmin != null) {
              adminName = matchedAdmin['name'] as String?;
            } else if (admins.isNotEmpty) {
              adminName = admins.first['name'] as String?;
            }
          }
        } catch (e) {
          debugPrint('Warning: Failed to fetch organization details for auto login: $e');
        }
      }

      return _mapToUserEntity(
        {
          'id': payload['id'] as String? ?? '',
          'email': email,
          'userType': userType,
          'organizationId': orgId,
          'organizationName': orgName,
          'createdAt': DateTime.now().toIso8601String(),
        },
        branches,
        adminName,
      );
    } catch (e) {
      // Clear token on corruption
      await logout();
    }
    return null;
  }

  /// Onboard Organization and immediately log in
  Future<UserEntity?> onboard({
    required String orgName,
    String? registrationNumber,
    String? address,
    required String contactEmail,
    String? contactPhone,
    required String adminName,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/onboard', data: {
        'orgName': orgName,
        'registrationNumber': registrationNumber,
        'address': address,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'adminName': adminName,
        'password': password,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        // Automatically perform login using the newly created credentials
        return await login(contactEmail, password);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  /// Authenticate user via email and password
  Future<UserEntity?> login(String email, String password) async {
    try {
      final loginResponse = await _apiClient.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      if (loginResponse.statusCode == 200 && loginResponse.data['success'] == true) {
        final loginData = loginResponse.data['data'];
        final userMap = loginData['user'] as Map<String, dynamic>;
        final orgId = userMap['organizationId'] as String?;

        List<dynamic> branches = [];
        String? adminName;

        if (orgId != null) {
          // Retrieve organization details (including branches) using the new token
          try {
            final detailsResponse = await _apiClient.dio.get('/organization');
            if (detailsResponse.statusCode == 200 && detailsResponse.data['success'] == true) {
              final detailsData = detailsResponse.data['data'];
              branches = detailsData['branches'] as List<dynamic>? ?? [];
              final admins = detailsData['admins'] as List<dynamic>? ?? [];
              if (admins.isNotEmpty) {
                adminName = admins.first['name'] as String?;
              }
            }
          } catch (e) {
            // Log org details fetch warning but proceed with empty branches
            debugPrint('Warning: Failed to fetch organization details: $e');
          }
        }

        return _mapToUserEntity(userMap, branches, adminName);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  /// Create a Branch
  Future<Map<String, dynamic>?> createBranch({
    required String code,
    required String name,
    String? address,
    String? phone,
    String? email,
    String? affiliationBoard,
    String? recognitionNumber,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/branch', data: {
        'code': code,
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'affiliationBoard': affiliationBoard,
        'recognitionNumber': recognitionNumber,
      });

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  /// Refresh current session details (e.g. loaded branches)
  Future<UserEntity?> refreshSession(UserEntity currentUser) async {
    try {
      final orgId = currentUser.organizationId;
      if (orgId == null) return currentUser;

      final detailsResponse = await _apiClient.dio.get('/organization');
      if (detailsResponse.statusCode == 200 && detailsResponse.data['success'] == true) {
        final detailsData = detailsResponse.data['data'];
        final branches = detailsData['branches'] as List<dynamic>? ?? [];
        final admins = detailsData['admins'] as List<dynamic>? ?? [];
        String? adminName;
        if (admins.isNotEmpty) {
          adminName = admins.first['name'] as String?;
        }

        return _mapToUserEntity(
          {
            'id': currentUser.id,
            'email': currentUser.email,
            'userType': 'ORG_ADMIN',
            'organizationId': currentUser.organizationId,
            'organizationName': currentUser.organizationName,
            'createdAt': currentUser.createdAt.toIso8601String(),
          },
          branches,
          adminName ?? currentUser.name,
        );
      }
    } catch (e) {
      debugPrint('Warning: Failed to refresh session: $e');
    }
    return currentUser;
  }

  /// Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
