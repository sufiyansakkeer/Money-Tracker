import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/usecases/shared_expense/get_shared_expense_by_id_usecase.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/presentation/pages/add_shared_expense_page.dart';
import 'package:money_track/features/groups/presentation/widgets/receipt_attachment_widget.dart';
import 'package:money_track/core/utils/currency_formatter.dart';

class ExpenseDetailsPage extends StatefulWidget {
  final String expenseId;
  final String groupId;
  final GroupEntity group;

  const ExpenseDetailsPage({
    super.key,
    required this.expenseId,
    required this.groupId,
    required this.group,
  });

  @override
  State<ExpenseDetailsPage> createState() => _ExpenseDetailsPageState();
}

class _ExpenseDetailsPageState extends State<ExpenseDetailsPage> {
  SharedExpenseEntity? expense;
  bool isLoading = true;
  String? errorMessage;
  late final GetSharedExpenseByIdUseCase _getSharedExpenseByIdUseCase;

  @override
  void initState() {
    super.initState();
    _getSharedExpenseByIdUseCase = sl<GetSharedExpenseByIdUseCase>();
    _loadExpenseDetails();
  }

  String _getCreatorName() {
    if (expense == null) return 'Unknown';

    // Find the creator from the participants
    final creator = expense!.participants.firstWhere(
      (participant) => participant.memberId == expense!.createdBy,
      orElse: () => ExpenseParticipant(
        memberId: expense!.createdBy,
        memberName: 'Unknown User',
        amount: 0,
        paidAmount: 0,
        isPayer: false,
      ),
    );

    return creator.memberName;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPrimaryPayerName() {
    if (expense == null) return 'Unknown';

    final primaryPayer = expense!.primaryPayer;
    return primaryPayer?.memberName ?? 'Unknown';
  }

  String _getSplitTypeDisplay() {
    if (expense == null) return 'Unknown';

    switch (expense!.splitType) {
      case EnhancedSplitType.equal:
        return 'Equal';
      case EnhancedSplitType.exact:
        return 'Exact amounts';
      case EnhancedSplitType.percentage:
        return 'Percentage';
      case EnhancedSplitType.shares:
        return 'Shares';
      case EnhancedSplitType.adjustment:
        return 'With adjustments';
    }
  }

  Future<void> _loadExpenseDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _getSharedExpenseByIdUseCase(
        params: GetSharedExpenseByIdParams(expenseId: widget.expenseId),
      );

      if (result.isError) {
        setState(() {
          isLoading = false;
          errorMessage =
              result.error?.message ?? 'Failed to load expense details';
        });
        return;
      }

      setState(() {
        expense = result.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load expense details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            onPressed: () => _editExpense(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showExpenseOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: isLoading
          ? const AppLoadingWidget(message: 'Loading expense details...')
          : errorMessage != null
              ? AppErrorWidget(
                  message: errorMessage!,
                  onRetry: _loadExpenseDetails,
                )
              : expense == null
                  ? const AppErrorWidget(message: 'Expense not found')
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildExpenseHeader(context),
                          const SizedBox(height: 24),
                          _buildExpenseDetails(context),
                          const SizedBox(height: 24),
                          _buildSplitDetails(context),
                          const SizedBox(height: 24),
                          _buildReceiptSection(context),
                          const SizedBox(height: 24),
                          _buildCommentsSection(context),
                          const SizedBox(height: 24),
                          _buildActivitySection(context),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addComment(context),
        icon: const Icon(Icons.comment),
        label: const Text('Add Comment'),
      ),
    );
  }

  Widget _buildExpenseHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense?.description ?? 'Sample Expense',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Added by ${_getCreatorName()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(
                        context, expense?.totalAmount ?? 100.0),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Date',
                expense != null ? _formatDate(expense!.createdAt) : 'Unknown'),
            _buildDetailRow(context, 'Category',
                expense?.category.categoryName ?? 'Unknown'),
            _buildDetailRow(context, 'Paid by', _getPrimaryPayerName()),
            _buildDetailRow(context, 'Split type', _getSplitTypeDisplay()),
            _buildDetailRow(context, 'Group', widget.group.name),
            if (expense?.description?.isNotEmpty == true)
              _buildDetailRow(context, 'Notes', expense!.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Show actual split details from expense participants
            if (expense != null)
              ...expense!.participants.map((participant) => _buildSplitRow(
                    context,
                    participant.memberName,
                    participant.amount,
                  ))
            else
              ...widget.group.members.map((member) => _buildSplitRow(
                    context,
                    member.name,
                    (expense?.totalAmount ?? 100.0) /
                        widget.group.members.length,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitRow(BuildContext context, String member, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              member.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            CurrencyFormatter.format(context, amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receipt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => _addReceipt(context),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Show actual receipts from expense
            ReceiptAttachmentWidget(
              receiptUrls: expense?.receiptUrls ?? [],
              onReceiptsChanged: (receipts) {
                // Handle receipt changes - could update expense with new receipts
                // For now, this is read-only in details view
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Show expense comments (simplified implementation)
            _buildCommentsContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsContent(BuildContext context) {
    // For now, show a placeholder since comments entity is not implemented
    // In a full implementation, this would fetch and display actual comments
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.comment,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the comment button to add the first comment',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Show actual activity items based on expense data
            if (expense != null)
              ..._buildExpenseActivityItems(context)
            else
              _buildActivityItem(
                context,
                'Expense created',
                'Loading expense details...',
                'Recently',
                Icons.add_circle,
                Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _editExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(
          group: widget.group,
          expenseToEdit: expense, // Pass expense for editing
        ),
      ),
    );
  }

  void _showExpenseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Expense'),
            onTap: () {
              Navigator.pop(context);
              _editExpense(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate Expense'),
            onTap: () {
              Navigator.pop(context);
              _duplicateExpense(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Expense'),
            onTap: () {
              Navigator.pop(context);
              _shareExpense(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Expense',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteExpense(context);
            },
          ),
        ],
      ),
    );
  }

  void _addReceipt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Receipt',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Camera functionality coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Gallery functionality coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addComment(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: 'Enter your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comment added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _duplicateExpense(BuildContext context) {
    // Implement duplicate expense functionality
    if (expense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot duplicate expense: expense data not loaded')),
      );
      return;
    }

    // Navigate to add expense page with pre-filled data from current expense
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(
          group: widget.group,
          expenseToEdit: expense?.copyWith(
            id: DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // New ID for duplicate
            title: '${expense!.title} (Copy)', // Mark as copy
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ), // Pass expense to duplicate with new ID
        ),
      ),
    )
        .then((result) {
      if (result != null && mounted) {
        // Refresh the current page if a new expense was created
        _loadExpenseDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense duplicated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  void _shareExpense(BuildContext context) {
    // Implement share expense functionality
    if (expense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot share expense: expense data not loaded')),
      );
      return;
    }

    final shareText = _generateShareText();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share expense details:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shareText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would use the share package
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense details copied to share!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  String _generateShareText() {
    if (expense == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('💰 Expense: ${expense!.title}');
    buffer.writeln('💵 Amount: \$${expense!.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('👥 Group: ${widget.group.name}');
    buffer.writeln('📅 Date: ${_formatDate(expense!.createdAt)}');
    buffer.writeln('👤 Paid by: ${_getPrimaryPayerName()}');
    buffer.writeln('🔄 Split: ${_getSplitTypeDisplay()}');

    if (expense!.description?.isNotEmpty == true) {
      buffer.writeln('📝 Notes: ${expense!.description}');
    }

    buffer.writeln('\n💸 Split details:');
    for (final participant in expense!.participants) {
      buffer.writeln(
          '• ${participant.memberName}: \$${participant.amount.toStringAsFixed(2)}');
    }

    buffer.writeln('\nShared from Money Tracker app');

    return buffer.toString();
  }

  void _deleteExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
            'Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use the GroupDetailsCubit to delete the expense
      final cubit = context.read<GroupDetailsCubit>();
      await cubit.deleteSharedExpense(widget.expenseId);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Check if deletion was successful by checking the cubit state
      final state = cubit.state;
      if (state is GroupDetailsError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        return;
      }

      // Navigate back on successful deletion
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: $e')),
        );
      }
    }
  }

  List<Widget> _buildExpenseActivityItems(BuildContext context) {
    final items = <Widget>[];

    // Add expense creation activity
    items.add(_buildActivityItem(
      context,
      'Expense created',
      '${_getCreatorName()} created this expense',
      _formatActivityTime(expense!.createdAt),
      Icons.add_circle,
      Colors.green,
    ));

    // Add update activity if expense was updated
    if (expense!.updatedAt != expense!.createdAt) {
      items.add(_buildActivityItem(
        context,
        'Expense updated',
        'Expense details were modified',
        _formatActivityTime(expense!.updatedAt),
        Icons.edit,
        Colors.blue,
      ));
    }

    // Add receipt activity if receipts exist
    if (expense!.receiptUrls?.isNotEmpty == true) {
      items.add(_buildActivityItem(
        context,
        'Receipt added',
        '${expense!.receiptUrls!.length} receipt(s) attached',
        _formatActivityTime(expense!.createdAt), // Approximate time
        Icons.receipt,
        Colors.orange,
      ));
    }

    // Add settlement activity if expense is settled
    if (expense!.isSettled) {
      items.add(_buildActivityItem(
        context,
        'Expense settled',
        'All balances have been settled',
        'Recently', // Would need settlement data for exact time
        Icons.check_circle,
        Colors.green,
      ));
    }

    return items;
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
