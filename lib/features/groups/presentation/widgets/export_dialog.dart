import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/services/data_export_service.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';

class ExportDialog extends StatefulWidget {
  final GroupEntity group;
  final VoidCallback? onExportComplete;

  const ExportDialog({
    Key? key,
    required this.group,
    this.onExportComplete,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportType _selectedType = ExportType.summary;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  final DataExportService _exportService = DataExportService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.file_download,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Export Data'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export data for ${widget.group.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Export Type Selection
            Text(
              'What to export:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildTypeSelector(),

            const SizedBox(height: 24),

            // Format Selection
            Text(
              'Format:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildFormatSelector(),

            const SizedBox(height: 24),

            // Date Range Selection
            Text(
              'Date Range (Optional):',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildDateRangeSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Export',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      children: ExportType.values.map((type) {
        return RadioListTile<ExportType>(
          title: Text(_getTypeDisplayName(type)),
          subtitle: Text(_getTypeDescription(type)),
          value: type,
          groupValue: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: ExportFormat.values.map((format) {
        return Expanded(
          child: RadioListTile<ExportFormat>(
            title: Text(format.name.toUpperCase()),
            value: format,
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Start Date',
                        style: TextStyle(
                          color: _startDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'End Date',
                        style: TextStyle(
                          color: _endDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Clear Dates'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Get actual data from the GroupDetailsCubit
      final cubit = context.read<GroupDetailsCubit>();
      final state = cubit.state;

      if (state is! GroupDetailsLoaded) {
        throw Exception('Group data not loaded. Please refresh and try again.');
      }

      final filePath = await _exportService.exportGroupData(
        group: widget.group,
        expenses: state.expenses,
        settlements: state.settlements,
        balance: state.balance,
        format: _selectedFormat,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Share the exported file
      await _exportService.shareExportedFile(filePath);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onExportComplete?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Data exported successfully as ${_selectedFormat.name.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getTypeDisplayName(ExportType type) {
    switch (type) {
      case ExportType.expenses:
        return 'Expenses';
      case ExportType.settlements:
        return 'Settlements';
      case ExportType.balances:
        return 'Balances';
      case ExportType.summary:
        return 'Summary Report';
    }
  }

  String _getTypeDescription(ExportType type) {
    switch (type) {
      case ExportType.expenses:
        return 'All shared expenses with details';
      case ExportType.settlements:
        return 'Payment records and settlements';
      case ExportType.balances:
        return 'Current member balances';
      case ExportType.summary:
        return 'Complete group overview';
    }
  }
}
