import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/presentation/bloc/sync_cubit.dart';
import 'package:money_track/core/presentation/widgets/sync_indicator.dart';

/// Page for viewing and managing sync settings
class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  Map<String, dynamic>? _syncStats;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await context.read<SyncCubit>().getSyncStats();
      setState(() {
        _syncStats = stats;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSyncStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSyncStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current sync status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SyncIndicator(showText: true, compact: false),
                      const SizedBox(height: 16),
                      BlocBuilder<SyncCubit, SyncState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            onPressed: state is SyncInProgress ? null : () {
                              context.read<SyncCubit>().forceSync();
                            },
                            icon: state is SyncInProgress
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(
                              state is SyncInProgress ? 'Syncing...' : 'Sync Now',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sync statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Statistics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingStats)
                        const Center(child: CircularProgressIndicator())
                      else if (_syncStats != null)
                        _buildSyncStats(theme)
                      else
                        const Text('Failed to load sync statistics'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sync information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Sync Works',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.cloud_sync,
                        'Automatic Sync',
                        'Your data automatically syncs when you\'re online',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.offline_bolt,
                        'Offline Support',
                        'Changes made offline will sync when you reconnect',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.security,
                        'Secure Storage',
                        'All data is encrypted and stored securely in the cloud',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.devices,
                        'Multi-Device',
                        'Access your data from any device with real-time updates',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStats(ThemeData theme) {
    return Column(
      children: [
        _buildStatRow('Connection Status', _syncStats!['isOnline'] ? 'Online' : 'Offline'),
        _buildStatRow('Current Status', _syncStats!['currentStatus'] ?? 'Unknown'),
        _buildStatRow('Pending Operations', '${_syncStats!['pendingOperations'] ?? 0}'),
        _buildStatRow('Pending Transactions', '${_syncStats!['pendingTransactions'] ?? 0}'),
        _buildStatRow('Pending Categories', '${_syncStats!['pendingCategories'] ?? 0}'),
        if (_syncStats!['lastSyncTime'] != null)
          _buildStatRow('Last Sync', _formatDateTime(_syncStats!['lastSyncTime'])),
        if (_syncStats!['error'] != null)
          _buildStatRow('Error', _syncStats!['error'], isError: true),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isError ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
