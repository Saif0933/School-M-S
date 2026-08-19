import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Health Record Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentHealthRecord {
  final String studentId;
  final String studentName;
  final String branchId;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String vaccinations;
  final String visionDetails;
  final String dentalDetails;
  final String emergencyContact;
  final String allergies;

  const StudentHealthRecord({
    required this.studentId,
    required this.studentName,
    required this.branchId,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.vaccinations,
    required this.visionDetails,
    required this.dentalDetails,
    required this.emergencyContact,
    required this.allergies,
  });

  StudentHealthRecord copyWith({
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? visionDetails,
    String? dentalDetails,
  }) {
    return StudentHealthRecord(
      studentId: studentId,
      studentName: studentName,
      branchId: branchId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      vaccinations: vaccinations,
      visionDetails: visionDetails ?? this.visionDetails,
      dentalDetails: dentalDetails ?? this.dentalDetails,
      emergencyContact: emergencyContact,
      allergies: allergies,
    );
  }
}

class HealthRecordsNotifier extends StateNotifier<List<StudentHealthRecord>> {
  HealthRecordsNotifier() : super([
    const StudentHealthRecord(
      studentId: 'ST-001',
      studentName: 'Aarav Sharma',
      branchId: 'BR-001',
      heightCm: 165.0,
      weightKg: 58.0,
      bmi: 21.3,
      vaccinations: 'COVID-19 (Done), Hep-B (Done)',
      visionDetails: 'L: 6/6, R: 6/6',
      dentalDetails: 'No dental cavities observed.',
      emergencyContact: 'Ramesh Sharma (+91 98765 43210)',
      allergies: 'Peanuts, Dust',
    ),
    const StudentHealthRecord(
      studentId: 'ST-002',
      studentName: 'Sunita Rao',
      branchId: 'BR-001',
      heightCm: 152.0,
      weightKg: 46.0,
      bmi: 19.9,
      vaccinations: 'COVID-19 (Done), MMR (Done)',
      visionDetails: 'L: 6/9, R: 6/6 (Wears spectacles)',
      dentalDetails: 'Mild plaque present.',
      emergencyContact: 'Venkatesh Rao (+91 99999 11111)',
      allergies: 'Penicillin',
    ),
  ]);

  void updateRecord(StudentHealthRecord updated) {
    state = state.map((r) => r.studentId == updated.studentId ? updated : r).toList();
  }
}

final studentHealthProvider = StateNotifierProvider<HealthRecordsNotifier, List<StudentHealthRecord>>((ref) {
  return HealthRecordsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// First Aid & Medical Incident Log
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FirstAidLog {
  final String id;
  final String branchId;
  final String studentName;
  final String incident;
  final String treatment;
  final String timestamp;

  const FirstAidLog({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.incident,
    required this.treatment,
    required this.timestamp,
  });
}

class FirstAidNotifier extends StateNotifier<List<FirstAidLog>> {
  FirstAidNotifier() : super([
    const FirstAidLog(
      id: 'AID-01',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      incident: 'Scraped knee during football practice',
      treatment: 'Antiseptic wash, bandage applied, rested for 10 mins',
      timestamp: '2026-08-19 10:30 AM',
    ),
  ]);

  void logFirstAid(FirstAidLog log) {
    state = [log, ...state];
  }
}

final firstAidProvider = StateNotifierProvider<FirstAidNotifier, List<FirstAidLog>>((ref) {
  return FirstAidNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Infirmary Stock Inventory Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MedicalStock {
  final String id;
  final String name;
  final int qty;
  final String expDate;

  const MedicalStock({required this.id, required this.name, required this.qty, required this.expDate});
}

class StockNotifier extends StateNotifier<List<MedicalStock>> {
  StockNotifier() : super([
    const MedicalStock(id: 'STK-01', name: 'Paracetamol 500mg', qty: 250, expDate: '2027-12'),
    const MedicalStock(id: 'STK-02', name: 'Sterile Cotton Rolls', qty: 15, expDate: '2029-06'),
    const MedicalStock(id: 'STK-03', name: 'Adhesive Bandages (Band-Aid)', qty: 180, expDate: '2028-09'),
  ]);

  void restock(String id, int addQty) {
    state = state.map((s) => s.id == id ? MedicalStock(id: s.id, name: s.name, qty: s.qty + addQty, expDate: s.expDate) : s).toList();
  }
}

final medicalStockProvider = StateNotifierProvider<StockNotifier, List<MedicalStock>>((ref) {
  return StockNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Epidemic Tracking Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DiseaseCase {
  final String diseaseName;
  final int activeCases;
  final String protocol;

  const DiseaseCase({required this.diseaseName, required this.activeCases, required this.protocol});
}

final epidemicTrackerProvider = Provider<List<DiseaseCase>>((ref) {
  return const [
    DiseaseCase(diseaseName: 'Chickenpox', activeCases: 2, protocol: 'Isolate child for 14 days. Notify class teacher.'),
    DiseaseCase(diseaseName: 'Conjunctivitis (Eye Flu)', activeCases: 1, protocol: 'Strict hand hygiene in Block B classrooms.'),
    DiseaseCase(diseaseName: 'Viral Dengue Fever', activeCases: 0, protocol: 'Mosquito fogging scheduled in rear gardens.'),
  ];
});
