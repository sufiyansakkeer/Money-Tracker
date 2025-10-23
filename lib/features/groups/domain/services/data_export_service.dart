import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';

enum ExportFormat { csv, pdf }

enum ExportType { expenses, settlements, balances, summary }

class DataExportService {
  /// Export group data to CSV or PDF format
  Future<String> exportGroupData({
    required GroupEntity group,
    required List<SharedExpenseEntity> expenses,
    required List<SettlementEntity> settlements,
    required GroupBalanceEntity? balance,
    required ExportFormat format,
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    switch (format) {
      case ExportFormat.csv:
        return await _exportToCsv(
          group: group,
          expenses: expenses,
          settlements: settlements,
          balance: balance,
          type: type,
          startDate: startDate,
          endDate: endDate,
        );
      case ExportFormat.pdf:
        return await _exportToPdf(
          group: group,
          expenses: expenses,
          settlements: settlements,
          balance: balance,
          type: type,
          startDate: startDate,
          endDate: endDate,
        );
    }
  }

  /// Share exported file
  Future<void> shareExportedFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  Future<String> _exportToCsv({
    required GroupEntity group,
    required List<SharedExpenseEntity> expenses,
    required List<SettlementEntity> settlements,
    required GroupBalanceEntity? balance,
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<List<dynamic>> csvData = [];

    switch (type) {
      case ExportType.expenses:
        csvData = _generateExpensesCsvData(expenses, startDate, endDate);
        break;
      case ExportType.settlements:
        csvData = _generateSettlementsCsvData(settlements, startDate, endDate);
        break;
      case ExportType.balances:
        csvData = _generateBalancesCsvData(balance);
        break;
      case ExportType.summary:
        csvData =
            _generateSummaryCsvData(group, expenses, settlements, balance);
        break;
    }

    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${group.name}_${type.name}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _exportToPdf({
    required GroupEntity group,
    required List<SharedExpenseEntity> expenses,
    required List<SettlementEntity> settlements,
    required GroupBalanceEntity? balance,
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    switch (type) {
      case ExportType.expenses:
        pdf.addPage(
            _generateExpensesPdfPage(group, expenses, startDate, endDate));
        break;
      case ExportType.settlements:
        pdf.addPage(_generateSettlementsPdfPage(
            group, settlements, startDate, endDate));
        break;
      case ExportType.balances:
        pdf.addPage(_generateBalancesPdfPage(group, balance));
        break;
      case ExportType.summary:
        pdf.addPage(
            _generateSummaryPdfPage(group, expenses, settlements, balance));
        break;
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${group.name}_${type.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  List<List<dynamic>> _generateExpensesCsvData(
    List<SharedExpenseEntity> expenses,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final filteredExpenses = _filterByDateRange(expenses, startDate, endDate);

    final csvData = <List<dynamic>>[
      [
        'Date',
        'Description',
        'Amount',
        'Currency',
        'Paid By',
        'Split Type',
        'Category',
        'Participants'
      ]
    ];

    for (final expense in filteredExpenses) {
      final primaryPayer = expense.primaryPayer;
      csvData.add([
        expense.createdAt.toIso8601String().split('T')[0],
        expense.title,
        expense.totalAmount,
        expense.currency,
        primaryPayer?.memberName ?? 'Unknown',
        expense.splitType.name,
        expense.category.categoryName,
        expense.participants.map((p) => p.memberName).join(', '),
      ]);
    }

    return csvData;
  }

  List<List<dynamic>> _generateSettlementsCsvData(
    List<SettlementEntity> settlements,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final filteredSettlements = settlements.where((settlement) {
      if (startDate != null && settlement.createdAt.isBefore(startDate))
        return false;
      if (endDate != null && settlement.createdAt.isAfter(endDate))
        return false;
      return true;
    }).toList();

    final csvData = <List<dynamic>>[
      [
        'Date',
        'From',
        'To',
        'Amount',
        'Currency',
        'Status',
        'Payment Method',
        'Description'
      ]
    ];

    for (final settlement in filteredSettlements) {
      csvData.add([
        settlement.createdAt.toIso8601String().split('T')[0],
        settlement.payerName,
        settlement.receiverName,
        settlement.amount,
        settlement.currency,
        settlement.status.name,
        settlement.paymentMethod.name,
        settlement.description ?? '',
      ]);
    }

    return csvData;
  }

  List<List<dynamic>> _generateBalancesCsvData(GroupBalanceEntity? balance) {
    final csvData = <List<dynamic>>[
      ['Member', 'Balance', 'Currency']
    ];

    if (balance != null) {
      for (final currency in balance.memberBalances.keys) {
        for (final memberBalance in balance.memberBalances[currency]!) {
          csvData.add([
            memberBalance.memberName,
            memberBalance.amount,
            memberBalance.currency,
          ]);
        }
      }
    }

    return csvData;
  }

  List<List<dynamic>> _generateSummaryCsvData(
    GroupEntity group,
    List<SharedExpenseEntity> expenses,
    List<SettlementEntity> settlements,
    GroupBalanceEntity? balance,
  ) {
    final csvData = <List<dynamic>>[
      ['Group Summary'],
      ['Group Name', group.name],
      ['Members', group.members.length],
      ['Total Expenses', expenses.length],
      ['Total Settlements', settlements.length],
      ['Export Date', DateTime.now().toIso8601String().split('T')[0]],
      [],
      ['Member Balances'],
      ['Member', 'Balance', 'Currency'],
    ];

    if (balance != null) {
      for (final entry in balance.memberBalances.entries) {
        for (final memberBalance in entry.value) {
          csvData.add([
            memberBalance.memberName,
            memberBalance.amount,
            memberBalance.currency,
          ]);
        }
      }
    }

    return csvData;
  }

  pw.Page _generateExpensesPdfPage(
    GroupEntity group,
    List<SharedExpenseEntity> expenses,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final filteredExpenses = _filterByDateRange(expenses, startDate, endDate);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('${group.name} - Expenses Report'),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Generated on: ${DateTime.now().toIso8601String().split('T')[0]}'),
            if (startDate != null || endDate != null) ...[
              pw.SizedBox(height: 10),
              pw.Text(
                  'Date Range: ${startDate?.toIso8601String().split('T')[0] ?? 'All'} to ${endDate?.toIso8601String().split('T')[0] ?? 'All'}'),
            ],
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Description',
                'Amount',
                'Paid By',
                'Split Type'
              ],
              data: filteredExpenses
                  .map((expense) => [
                        expense.createdAt.toIso8601String().split('T')[0],
                        expense.title,
                        '${expense.totalAmount} ${expense.currency}',
                        expense.primaryPayer?.memberName ?? 'Unknown',
                        expense.splitType.name,
                      ])
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  pw.Page _generateSettlementsPdfPage(
    GroupEntity group,
    List<SettlementEntity> settlements,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final filteredSettlements = settlements.where((settlement) {
      if (startDate != null && settlement.createdAt.isBefore(startDate))
        return false;
      if (endDate != null && settlement.createdAt.isAfter(endDate))
        return false;
      return true;
    }).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('${group.name} - Settlements Report'),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Generated on: ${DateTime.now().toIso8601String().split('T')[0]}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Date', 'From', 'To', 'Amount', 'Status'],
              data: filteredSettlements
                  .map((settlement) => [
                        settlement.createdAt.toIso8601String().split('T')[0],
                        settlement.payerName,
                        settlement.receiverName,
                        '${settlement.amount} ${settlement.currency}',
                        settlement.status.name,
                      ])
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  pw.Page _generateBalancesPdfPage(
      GroupEntity group, GroupBalanceEntity? balance) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('${group.name} - Balance Report'),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Generated on: ${DateTime.now().toIso8601String().split('T')[0]}'),
            pw.SizedBox(height: 20),
            if (balance != null)
              pw.Table.fromTextArray(
                headers: ['Member', 'Balance', 'Currency'],
                data: balance.memberBalances.entries
                    .expand((entry) => entry.value.map((memberBalance) => [
                          memberBalance.memberName,
                          memberBalance.amount.toString(),
                          memberBalance.currency,
                        ]))
                    .toList(),
              )
            else
              pw.Text('No balance data available'),
          ],
        );
      },
    );
  }

  pw.Page _generateSummaryPdfPage(
    GroupEntity group,
    List<SharedExpenseEntity> expenses,
    List<SettlementEntity> settlements,
    GroupBalanceEntity? balance,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('${group.name} - Summary Report'),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Generated on: ${DateTime.now().toIso8601String().split('T')[0]}'),
            pw.SizedBox(height: 20),
            pw.Text('Group Information:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('• Members: ${group.members.length}'),
            pw.Text('• Total Expenses: ${expenses.length}'),
            pw.Text('• Total Settlements: ${settlements.length}'),
            pw.SizedBox(height: 20),
            if (balance != null) ...[
              pw.Text('Member Balances:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Member', 'Balance', 'Currency'],
                data: balance.memberBalances.entries
                    .expand((entry) => entry.value.map((memberBalance) => [
                          memberBalance.memberName,
                          memberBalance.amount.toString(),
                          memberBalance.currency,
                        ]))
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  List<SharedExpenseEntity> _filterByDateRange(
    List<SharedExpenseEntity> expenses,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return expenses.where((expense) {
      if (startDate != null && expense.createdAt.isBefore(startDate))
        return false;
      if (endDate != null && expense.createdAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
}
