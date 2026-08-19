import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Alumni Profile Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AlumniProfile {
  final String id;
  final String branchId;
  final String name;
  final String batchYear;
  final String occupation;
  final String email;
  final String photoUrl;

  const AlumniProfile({
    required this.id,
    required this.branchId,
    required this.name,
    required this.batchYear,
    required this.occupation,
    required this.email,
    this.photoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
  });
}

class AlumniNotifier extends StateNotifier<List<AlumniProfile>> {
  AlumniNotifier() : super([
    const AlumniProfile(
      id: 'AL-DEL-01',
      branchId: 'BR-001',
      name: 'Aditya Sen',
      batchYear: 'Class of 2020',
      occupation: 'Software Engineer at Google',
      email: 'aditya.sen@gmail.com',
    ),
    const AlumniProfile(
      id: 'AL-DEL-02',
      branchId: 'BR-001',
      name: 'Sneha Kulkarni',
      batchYear: 'Class of 2022',
      occupation: 'Research Scholar at MIT',
      email: 'sneha.k@mit.edu',
    ),
    const AlumniProfile(
      id: 'AL-MUM-01',
      branchId: 'BR-002',
      name: 'Rohan Mehta',
      batchYear: 'Class of 2019',
      occupation: 'Financial Analyst at Goldman Sachs',
      email: 'rohan.mehta@goldman.com',
    ),
  ]);

  void addAlumni(AlumniProfile profile) {
    state = [...state, profile];
  }
}

final alumniProvider = StateNotifierProvider<AlumniNotifier, List<AlumniProfile>>((ref) {
  return AlumniNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Alumni Donation Campaign Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AlumniDonation {
  final String id;
  final String branchId;
  final String title;
  final String description;
  final double goal;
  final double raised;

  const AlumniDonation({
    required this.id,
    required this.branchId,
    required this.title,
    required this.description,
    required this.goal,
    required this.raised,
  });

  AlumniDonation copyWith({double? raised}) {
    return AlumniDonation(
      id: id,
      branchId: branchId,
      title: title,
      description: description,
      goal: goal,
      raised: raised ?? this.raised,
    );
  }
}

class DonationNotifier extends StateNotifier<List<AlumniDonation>> {
  DonationNotifier() : super([
    const AlumniDonation(
      id: 'DON-DEL-01',
      branchId: 'BR-001',
      title: 'New Library Lab Expansion Fund',
      description: 'Fundraiser to build digital computer lab terminals in Delhi Block C.',
      goal: 200000.0,
      raised: 75000.0,
    ),
    const AlumniDonation(
      id: 'DON-MUM-01',
      branchId: 'BR-002',
      title: 'Mumbai Sports Kit Endowment',
      description: 'Sponsor sports kits and travel tickets for underprivileged junior athletes.',
      goal: 80000.0,
      raised: 42000.0,
    ),
  ]);

  void donate(String id, double amount) {
    state = state.map((d) => d.id == id ? d.copyWith(raised: d.raised + amount) : d).toList();
  }

  void addCampaign(AlumniDonation campaign) {
    state = [...state, campaign];
  }
}

final alumniDonationProvider = StateNotifierProvider<DonationNotifier, List<AlumniDonation>>((ref) {
  return DonationNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Alumni Job Posting Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AlumniJob {
  final String id;
  final String branchId;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String postedBy;

  const AlumniJob({
    required this.id,
    required this.branchId,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.postedBy,
  });
}

class JobsNotifier extends StateNotifier<List<AlumniJob>> {
  JobsNotifier() : super([
    const AlumniJob(
      id: 'JOB-DEL-01',
      branchId: 'BR-001',
      title: 'Frontend Developer Intern',
      company: 'TCS Innovation Labs',
      location: 'Delhi (Hybrid)',
      salary: '₹25,000/month',
      postedBy: 'Aditya Sen',
    ),
  ]);

  void postJob(AlumniJob job) {
    state = [job, ...state];
  }
}

final alumniJobsProvider = StateNotifierProvider<JobsNotifier, List<AlumniJob>>((ref) {
  return JobsNotifier();
});
