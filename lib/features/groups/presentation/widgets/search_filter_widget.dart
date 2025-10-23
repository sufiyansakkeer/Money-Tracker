import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/services/search_filter_service.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';

class SearchFilterWidget extends StatefulWidget {
  final GroupEntity group;
  final ExpenseFilter? initialFilter;
  final Function(ExpenseFilter) onFilterChanged;
  final VoidCallback? onClearFilter;

  const SearchFilterWidget({
    Key? key,
    required this.group,
    this.initialFilter,
    required this.onFilterChanged,
    this.onClearFilter,
  }) : super(key: key);

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  late TextEditingController _searchController;
  late ExpenseFilter _currentFilter;

  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? const ExpenseFilter();
    _searchController = TextEditingController(text: _currentFilter.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateFilter(searchQuery: '');
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _showAdvancedFilters
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                      color: _hasActiveFilters()
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _updateFilter(searchQuery: value);
            },
          ),
        ),

        // Advanced Filters
        if (_showAdvancedFilters) _buildAdvancedFilters(),

        // Quick Filter Chips
        _buildQuickFilters(),
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range
          _buildDateRangeFilter(),
          const SizedBox(height: 16),

          // Amount Range
          _buildAmountRangeFilter(),
          const SizedBox(height: 16),

          // Member Filter
          _buildMemberFilter(),
          const SizedBox(height: 16),

          // Sort Options
          _buildSortOptions(),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = false;
                  });
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
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
                        _currentFilter.startDate != null
                            ? '${_currentFilter.startDate!.day}/${_currentFilter.startDate!.month}/${_currentFilter.startDate!.year}'
                            : 'Start Date',
                        style: TextStyle(
                          color: _currentFilter.startDate != null
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
                    vertical: 12,
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
                        _currentFilter.endDate != null
                            ? '${_currentFilter.endDate!.day}/${_currentFilter.endDate!.month}/${_currentFilter.endDate!.year}'
                            : 'End Date',
                        style: TextStyle(
                          color: _currentFilter.endDate != null
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
      ],
    );
  }

  Widget _buildAmountRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Range',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  _updateFilter(minAmount: amount);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  _updateFilter(maxAmount: amount);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paid By',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.group.members.map((member) {
            final isSelected =
                _currentFilter.paidByMembers?.contains(member.id) ?? false;
            return FilterChip(
              label: Text(member.name),
              selected: isSelected,
              onSelected: (selected) {
                final currentMembers = _currentFilter.paidByMembers ?? [];
                List<String> newMembers;

                if (selected) {
                  newMembers = [...currentMembers, member.id];
                } else {
                  newMembers =
                      currentMembers.where((id) => id != member.id).toList();
                }

                _updateFilter(
                    paidByMembers: newMembers.isEmpty ? null : newMembers);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SortBy>(
                value: _currentFilter.sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: SortBy.values.map((sortBy) {
                  return DropdownMenuItem(
                    value: sortBy,
                    child: Text(_getSortByDisplayName(sortBy)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateFilter(sortBy: value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<SortOrder>(
                value: _currentFilter.sortOrder,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: SortOrder.values.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(order == SortOrder.ascending
                        ? 'Ascending'
                        : 'Descending'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateFilter(sortOrder: value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final presets = SearchFilterService.getExpenseFilterPresets();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filters',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickFilterChip('This Week', presets[1]),
              _buildQuickFilterChip('This Month', presets[2]),
              _buildQuickFilterChip('Last Month', presets[3]),
              _buildQuickFilterChip('Highest Amount', presets[4]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, ExpenseFilter filter) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _currentFilter = filter;
          _searchController.text = filter.searchQuery ?? '';
        });
        widget.onFilterChanged(_currentFilter);
      },
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
      if (isStartDate) {
        _updateFilter(startDate: date);
      } else {
        _updateFilter(endDate: date);
      }
    }
  }

  void _updateFilter({
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<String>? categories,
    List<String>? paidByMembers,
    List<EnhancedSplitType>? splitTypes,
    String? searchQuery,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(
        startDate: startDate,
        endDate: endDate,
        minAmount: minAmount,
        maxAmount: maxAmount,
        categories: categories,
        paidByMembers: paidByMembers,
        splitTypes: splitTypes,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    });
    widget.onFilterChanged(_currentFilter);
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilter = const ExpenseFilter();
      _searchController.clear();
    });
    widget.onFilterChanged(_currentFilter);
    widget.onClearFilter?.call();
  }

  bool _hasActiveFilters() {
    return _currentFilter.startDate != null ||
        _currentFilter.endDate != null ||
        _currentFilter.minAmount != null ||
        _currentFilter.maxAmount != null ||
        (_currentFilter.categories?.isNotEmpty ?? false) ||
        (_currentFilter.paidByMembers?.isNotEmpty ?? false) ||
        (_currentFilter.splitTypes?.isNotEmpty ?? false) ||
        (_currentFilter.searchQuery?.isNotEmpty ?? false);
  }

  String _getSortByDisplayName(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.date:
        return 'Date';
      case SortBy.amount:
        return 'Amount';
      case SortBy.description:
        return 'Description';
      case SortBy.category:
        return 'Category';
      case SortBy.paidBy:
        return 'Paid By';
    }
  }
}
