import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/categories/presentation/widgets/category_bottom_sheet.dart';
import 'package:money_track/features/categories/presentation/widgets/category_card.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';
import 'package:money_track/features/groups/presentation/widgets/group_bottom_sheet.dart';

class CategoriesGroupsPage extends StatefulWidget {
  const CategoriesGroupsPage({super.key});

  @override
  State<CategoriesGroupsPage> createState() => _CategoriesGroupsPageState();
}

class _CategoriesGroupsPageState extends State<CategoriesGroupsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    context.read<CategoryBloc>().add(GetAllCategoriesEvent());
    context.read<GroupBloc>().add(LoadGroups());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              20.height(),
              Text(
                "Categories & Groups",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.getTextColor(context),
                ),
              ),
              20.height(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    // borderRadius: BorderRadius.circular(25),
                    color: ColorConstants.getThemeColor(context),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ColorConstants.getTextColor(context),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      text: "Categories",
                    ),
                    Tab(text: "Groups"),
                  ],
                ),
              ),
              20.height(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoriesTab(),
                    _buildGroupsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100, right: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.getThemeColor(context),
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
            ),
            onPressed: () {
              if (_tabController.index == 0) {
                // Categories tab - show category bottom sheet
                showModalBottomSheet(
                  showDragHandle: true,
                  context: context,
                  builder: (context) => const CategoryBottomSheetWidget(),
                );
              } else {
                // Groups tab - show group bottom sheet
                showModalBottomSheet(
                  showDragHandle: true,
                  context: context,
                  builder: (context) => const GroupBottomSheetWidget(),
                );
              }
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryLoaded) {
            return GridView.builder(
              shrinkWrap: true,
              primary: false,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                var categoryEntity = state.categoryList[index];
                return CategoryCard(
                  categoryType: categoryEntity.categoryType,
                  categoryName: categoryEntity.categoryName,
                );
              },
              itemCount: state.categoryList.length,
            );
          } else {
            return const Center(child: Text("Something went wrong"));
          }
        },
      ),
    );
  }

  Widget _buildGroupsTab() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GroupsLoaded) {
          if (state.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  16.height(),
                  Text(
                    "No groups yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  8.height(),
                  Text(
                    "Tap + to create your first group",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: ColorConstants.getThemeColor(context),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${group.members.length} members',
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () {
                      _showDeleteConfirmation(context, group.id, group.name);
                    },
                  ),
                ),
              );
            },
          );
        } else if (state is GroupError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                16.height(),
                Text(
                  "Error loading groups",
                  style: TextStyle(
                    fontSize: 18,
                    color: ColorConstants.getTextColor(context),
                  ),
                ),
                8.height(),
                Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.height(),
                ElevatedButton(
                  onPressed: () {
                    context.read<GroupBloc>().add(LoadGroups());
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String groupId, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text('Are you sure you want to delete "$groupName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<GroupBloc>().add(DeleteGroupEvent(groupId));
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
