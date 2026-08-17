import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Communication Log Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CommunicationLogEntity {
  final String id;
  final String scope; // 'Organization-wide', 'Branch-specific'
  final String? branchId; // null if organization-wide
  final String? branchName;
  final String channel; // 'SMS', 'Email', 'Push Notification', 'WhatsApp'
  final String recipientGroup; // 'All Parents', 'Class 11 Science', 'Staff Pool', 'All Branches'
  final String title;
  final String message;
  final String? attachmentName;
  final DateTime dateSent;
  final int smsCreditsUsed;
  final double deliveryRate; // e.g. 0.98 for 98%
  final double readRate; // e.g. 0.85 for 85%

  const CommunicationLogEntity({
    required this.id,
    required this.scope,
    this.branchId,
    this.branchName,
    required this.channel,
    required this.recipientGroup,
    required this.title,
    required this.message,
    this.attachmentName,
    required this.dateSent,
    required this.smsCreditsUsed,
    required this.deliveryRate,
    required this.readRate,
  });
}

class CommunicationLogsNotifier extends StateNotifier<List<CommunicationLogEntity>> {
  CommunicationLogsNotifier() : super([
    // Org-Level Broadcaster
    CommunicationLogEntity(
      id: 'COM-001',
      scope: 'Organization-wide',
      branchId: null,
      branchName: 'All Branches',
      channel: 'Email',
      recipientGroup: 'All Branches (Staff & Parents)',
      title: 'Annual Founders Day Celebrations Announcement',
      message: 'Dear All, we are pleased to invite you to the Annual Founders Day on 25th September. Attendance is mandatory.',
      attachmentName: 'founders_day_invite.pdf',
      dateSent: DateTime.now().subtract(const Duration(days: 5)),
      smsCreditsUsed: 0,
      deliveryRate: 0.99,
      readRate: 0.92,
    ),
    // Delhi Scoped Dispatch
    CommunicationLogEntity(
      id: 'COM-002',
      scope: 'Branch-specific',
      branchId: 'BR-001',
      branchName: 'Delhi Central',
      channel: 'SMS',
      recipientGroup: 'All Parents',
      title: 'Monsoon Heavy Rain School Closure',
      message: 'Alert: Due to heavy rainfall and waterlogging warnings, Delhi Central branch will remain closed today.',
      attachmentName: null,
      dateSent: DateTime.now().subtract(const Duration(days: 2)),
      smsCreditsUsed: 1200,
      deliveryRate: 0.97,
      readRate: 0.88,
    ),
    // Mumbai Scoped Dispatch
    CommunicationLogEntity(
      id: 'COM-003',
      scope: 'Branch-specific',
      branchId: 'BR-002',
      branchName: 'Mumbai South',
      channel: 'WhatsApp',
      recipientGroup: 'Class 11 Science - Sec A',
      title: 'Physics Lab Viva Timings Update',
      message: 'Dear Parents, please note that the Physics Practical Board Viva is scheduled for Monday at 09:00 AM.',
      attachmentName: 'physics_lab_schedule.pdf',
      dateSent: DateTime.now().subtract(const Duration(days: 1)),
      smsCreditsUsed: 0,
      deliveryRate: 0.98,
      readRate: 0.95,
    ),
  ]);

  void sendBroadcast(CommunicationLogEntity log) {
    state = [log, ...state];
  }
}

final communicationLogsProvider =
    StateNotifierProvider<CommunicationLogsNotifier, List<CommunicationLogEntity>>((ref) {
  return CommunicationLogsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Custom Templates Entity (Multi-Language)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MessageTemplateEntity {
  final String id;
  final String? branchId; // null if organization-level
  final String title;
  final String category; // 'Fee due', 'Results', 'Emergency', 'General'
  final String messageBody;
  final String language; // 'English', 'Hindi', 'Marathi'

  const MessageTemplateEntity({
    required this.id,
    this.branchId,
    required this.title,
    required this.category,
    required this.messageBody,
    required this.language,
  });
}

class MessageTemplatesNotifier extends StateNotifier<List<MessageTemplateEntity>> {
  MessageTemplatesNotifier() : super([
    // Org Announcement Template
    const MessageTemplateEntity(
      id: 'TMP-001',
      branchId: null,
      title: 'Official Holiday Announcement',
      category: 'General',
      messageBody: 'Dear Parents/Staff, please note that all school branches will remain closed on [HolidayDate] on account of [Occasion]. Classes resume on [ResumeDate].',
      language: 'English',
    ),
    // Delhi Custom Templates
    const MessageTemplateEntity(
      id: 'TMP-002',
      branchId: 'BR-001',
      title: 'Fee Instalment Due Reminder',
      category: 'Fee due',
      messageBody: 'प्रिय अभिभावक, आपके पाल्य की फीस किश्त बकाया है। कृपया अंतिम तिथि [DueDate] से पहले ₹[Amount] का भुगतान करें। धन्यवाद।',
      language: 'Hindi',
    ),
    // Mumbai Custom Templates
    const MessageTemplateEntity(
      id: 'TMP-003',
      branchId: 'BR-002',
      title: 'Monthly Progress Report card Release',
      category: 'Results',
      messageBody: 'प्रिय पालक, तुमच्या पाल्याचा मासिक प्रगती अहवाल जाहीर झाला आहे. कृपया डिजिटल पोर्टलवर तपासा.',
      language: 'Marathi',
    ),
  ]);

  void addTemplate(MessageTemplateEntity template) {
    state = [...state, template];
  }
}

final messageTemplatesProvider =
    StateNotifierProvider<MessageTemplatesNotifier, List<MessageTemplateEntity>>((ref) {
  return MessageTemplatesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SMS Credits Pool Allocation
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SmsCreditPoolEntity {
  final String branchId;
  final String branchName;
  final int allocated;
  final int used;

  const SmsCreditPoolEntity({
    required this.branchId,
    required this.branchName,
    required this.allocated,
    required this.used,
  });

  SmsCreditPoolEntity copyWith({int? allocated, int? used}) {
    return SmsCreditPoolEntity(
      branchId: branchId,
      branchName: branchName,
      allocated: allocated ?? this.allocated,
      used: used ?? this.used,
    );
  }
}

class SmsCreditPoolsNotifier extends StateNotifier<List<SmsCreditPoolEntity>> {
  SmsCreditPoolsNotifier() : super([
    const SmsCreditPoolEntity(
      branchId: 'BR-001',
      branchName: 'Delhi Central',
      allocated: 50000,
      used: 12400,
    ),
    const SmsCreditPoolEntity(
      branchId: 'BR-002',
      branchName: 'Mumbai South',
      allocated: 35000,
      used: 6800,
    ),
  ]);

  void allocateCredits(String bId, int extraCredits) {
    state = state.map((p) {
      if (p.branchId == bId) {
        return p.copyWith(allocated: p.allocated + extraCredits);
      }
      return p;
    }).toList();
  }

  void consumeCredits(String bId, int consumed) {
    state = state.map((p) {
      if (p.branchId == bId) {
        return p.copyWith(used: p.used + consumed);
      }
      return p;
    }).toList();
  }
}

final smsCreditPoolsProvider = StateNotifierProvider<SmsCreditPoolsNotifier, List<SmsCreditPoolEntity>>((ref) {
  return SmsCreditPoolsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Individual Parent-Teacher Thread Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ChatMessageEntity {
  final String id;
  final String branchId;
  final String studentName;
  final String teacherName;
  final String sender; // 'Teacher', 'Parent'
  final String message;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.teacherName,
    required this.sender,
    required this.message,
    required this.timestamp,
  });
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageEntity>> {
  ChatMessagesNotifier() : super([
    // Delhi Chat
    ChatMessageEntity(
      id: 'MSG-001',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      teacherName: 'Mrs. Kavita Verma',
      sender: 'Teacher',
      message: 'Dear Mr. Sharma, Aarav was outstanding in class discussions today. Keep encouraging him!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ChatMessageEntity(
      id: 'MSG-002',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      teacherName: 'Mrs. Kavita Verma',
      sender: 'Parent',
      message: 'Thank you Kavita ji, we will keep monitoring his study schedule.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // Mumbai Chat
    ChatMessageEntity(
      id: 'MSG-003',
      branchId: 'BR-002',
      studentName: 'Sachin Tendulkar',
      teacherName: 'Mrs. Rekha Joshi',
      sender: 'Teacher',
      message: 'Dear Parent, Sachin missed submitting his homework today. Please review.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ]);

  void sendMessage(ChatMessageEntity msg) {
    state = [...state, msg];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageEntity>>((ref) {
  return ChatMessagesNotifier();
});
