import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/domain/entities/category_entity.dart';

enum RecurringPattern {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

class RecurringExpenseTemplate {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String currency;
  final String paidById;
  final List<ExpenseParticipant> participants;
  final EnhancedSplitType splitType;
  final String? categoryId;
  final RecurringPattern pattern;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? notes;

  const RecurringExpenseTemplate({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidById,
    required this.participants,
    required this.splitType,
    this.categoryId,
    required this.pattern,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.notes,
  });

  RecurringExpenseTemplate copyWith({
    String? id,
    String? groupId,
    String? description,
    double? amount,
    String? currency,
    String? paidById,
    List<ExpenseParticipant>? participants,
    EnhancedSplitType? splitType,
    String? categoryId,
    RecurringPattern? pattern,
    DateTime? startDate,
    DateTime? endDate,
    int? maxOccurrences,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? notes,
  }) {
    return RecurringExpenseTemplate(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidById: paidById ?? this.paidById,
      participants: participants ?? this.participants,
      splitType: splitType ?? this.splitType,
      categoryId: categoryId ?? this.categoryId,
      pattern: pattern ?? this.pattern,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }
}

class RecurringExpenseOccurrence {
  final String templateId;
  final DateTime scheduledDate;
  final bool isGenerated;
  final String? generatedExpenseId;
  final DateTime? generatedAt;

  const RecurringExpenseOccurrence({
    required this.templateId,
    required this.scheduledDate,
    this.isGenerated = false,
    this.generatedExpenseId,
    this.generatedAt,
  });

  RecurringExpenseOccurrence copyWith({
    String? templateId,
    DateTime? scheduledDate,
    bool? isGenerated,
    String? generatedExpenseId,
    DateTime? generatedAt,
  }) {
    return RecurringExpenseOccurrence(
      templateId: templateId ?? this.templateId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isGenerated: isGenerated ?? this.isGenerated,
      generatedExpenseId: generatedExpenseId ?? this.generatedExpenseId,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

class RecurringExpenseService {
  /// Create a new recurring expense template
  RecurringExpenseTemplate createTemplate({
    required String groupId,
    required String description,
    required double amount,
    required String currency,
    required String paidById,
    required List<ExpenseParticipant> participants,
    required EnhancedSplitType splitType,
    String? categoryId,
    required RecurringPattern pattern,
    required DateTime startDate,
    DateTime? endDate,
    int? maxOccurrences,
    List<String> tags = const [],
    String? notes,
  }) {
    return RecurringExpenseTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      description: description,
      amount: amount,
      currency: currency,
      paidById: paidById,
      participants: participants,
      splitType: splitType,
      categoryId: categoryId,
      pattern: pattern,
      startDate: startDate,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      notes: notes,
    );
  }

  /// Generate upcoming occurrences for a template
  List<RecurringExpenseOccurrence> generateOccurrences(
    RecurringExpenseTemplate template, {
    DateTime? fromDate,
    DateTime? toDate,
    int? maxCount,
  }) {
    final occurrences = <RecurringExpenseOccurrence>[];
    final startDate = fromDate ?? template.startDate;
    final endDate = toDate ??
        template.endDate ??
        DateTime.now().add(const Duration(days: 365));

    DateTime currentDate =
        _getNextOccurrenceDate(template.startDate, template.pattern, startDate);
    int count = 0;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (template.maxOccurrences != null &&
          count >= template.maxOccurrences!) {
        break;
      }

      if (maxCount != null && count >= maxCount) {
        break;
      }

      occurrences.add(RecurringExpenseOccurrence(
        templateId: template.id,
        scheduledDate: currentDate,
      ));

      currentDate = _getNextOccurrenceDate(currentDate, template.pattern);
      count++;
    }

    return occurrences;
  }

  /// Generate a shared expense from a template and occurrence
  SharedExpenseEntity generateExpenseFromTemplate(
    RecurringExpenseTemplate template,
    RecurringExpenseOccurrence occurrence,
    GroupEntity group,
  ) {
    // Find the paid by member
    final paidByMember = group.members.firstWhere(
      (member) => member.id == template.paidById,
    );

    // Find category if specified
    // Note: This would need to be fetched from a category repository in real implementation
    // For now, we'll set it to null and handle it in the UI layer

    return SharedExpenseEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: template.groupId,
      title: '${template.description} (Recurring)',
      description: template.notes,
      totalAmount: template.amount,
      currency: template.currency,
      category: CategoryEntity(
        id: template.categoryId ?? 'default',
        categoryName: 'General',
        categoryType: CategoryType.other,
        type: TransactionType.expense,
        isDeleted: false,
      ),
      splitType: template.splitType,
      participants: template.participants,
      createdBy: template.paidById,
      createdAt: occurrence.scheduledDate,
      updatedAt: DateTime.now(),
      receiptUrls: const [],
      metadata: {
        'isRecurring': true,
        'recurringTemplateId': template.id,
        'tags': template.tags,
      },
      isRecurring: true,
      recurringPattern: template.pattern.name,
      recurringEndDate: template.endDate,
      isSettled: false,
      tags: template.tags,
    );
  }

  /// Get the next occurrence date based on pattern
  DateTime _getNextOccurrenceDate(
    DateTime currentDate,
    RecurringPattern pattern, [
    DateTime? fromDate,
  ]) {
    final baseDate = fromDate ?? currentDate;

    switch (pattern) {
      case RecurringPattern.daily:
        return DateTime(baseDate.year, baseDate.month, baseDate.day + 1);
      case RecurringPattern.weekly:
        return DateTime(baseDate.year, baseDate.month, baseDate.day + 7);
      case RecurringPattern.biweekly:
        return DateTime(baseDate.year, baseDate.month, baseDate.day + 14);
      case RecurringPattern.monthly:
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case RecurringPattern.quarterly:
        return DateTime(baseDate.year, baseDate.month + 3, baseDate.day);
      case RecurringPattern.yearly:
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
    }
  }

  /// Check if a template should generate an expense on a given date
  bool shouldGenerateExpense(
    RecurringExpenseTemplate template,
    DateTime date,
  ) {
    if (!template.isActive) return false;
    if (date.isBefore(template.startDate)) return false;
    if (template.endDate != null && date.isAfter(template.endDate!))
      return false;

    // Check if this date matches the recurring pattern
    final daysDifference = date.difference(template.startDate).inDays;

    switch (template.pattern) {
      case RecurringPattern.daily:
        return daysDifference >= 0;
      case RecurringPattern.weekly:
        return daysDifference >= 0 && daysDifference % 7 == 0;
      case RecurringPattern.biweekly:
        return daysDifference >= 0 && daysDifference % 14 == 0;
      case RecurringPattern.monthly:
        return daysDifference >= 0 &&
            date.day == template.startDate.day &&
            _monthsDifference(template.startDate, date) >= 0;
      case RecurringPattern.quarterly:
        return daysDifference >= 0 &&
            date.day == template.startDate.day &&
            _monthsDifference(template.startDate, date) % 3 == 0;
      case RecurringPattern.yearly:
        return daysDifference >= 0 &&
            date.day == template.startDate.day &&
            date.month == template.startDate.month &&
            date.year >= template.startDate.year;
    }
  }

  /// Calculate the difference in months between two dates
  int _monthsDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
  }

  /// Get human-readable description of recurring pattern
  String getPatternDescription(RecurringPattern pattern) {
    switch (pattern) {
      case RecurringPattern.daily:
        return 'Daily';
      case RecurringPattern.weekly:
        return 'Weekly';
      case RecurringPattern.biweekly:
        return 'Every 2 weeks';
      case RecurringPattern.monthly:
        return 'Monthly';
      case RecurringPattern.quarterly:
        return 'Every 3 months';
      case RecurringPattern.yearly:
        return 'Yearly';
    }
  }

  /// Get the next scheduled date for a template
  DateTime? getNextScheduledDate(RecurringExpenseTemplate template) {
    if (!template.isActive) return null;

    final now = DateTime.now();
    if (template.endDate != null && now.isAfter(template.endDate!)) return null;

    return _getNextOccurrenceDate(template.startDate, template.pattern, now);
  }

  /// Pause/resume a recurring expense template
  RecurringExpenseTemplate toggleTemplateStatus(
    RecurringExpenseTemplate template,
    bool isActive,
  ) {
    return template.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  /// Update a recurring expense template
  RecurringExpenseTemplate updateTemplate(
    RecurringExpenseTemplate template, {
    String? description,
    double? amount,
    String? currency,
    String? paidById,
    List<ExpenseParticipant>? participants,
    EnhancedSplitType? splitType,
    String? categoryId,
    RecurringPattern? pattern,
    DateTime? startDate,
    DateTime? endDate,
    int? maxOccurrences,
    List<String>? tags,
    String? notes,
  }) {
    return template.copyWith(
      description: description,
      amount: amount,
      currency: currency,
      paidById: paidById,
      participants: participants,
      splitType: splitType,
      categoryId: categoryId,
      pattern: pattern,
      startDate: startDate,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
      tags: tags,
      notes: notes,
      updatedAt: DateTime.now(),
    );
  }
}
