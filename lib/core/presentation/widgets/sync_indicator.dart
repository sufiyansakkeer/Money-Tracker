import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/presentation/bloc/sync_cubit.dart';

/// Widget that shows sync status indicator
class SyncIndicator extends StatelessWidget {
  final bool showText;
  final bool compact;

  const SyncIndicator({
    super.key,
    this.showText = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        return _buildIndicator(context, state);
      },
    );
  }

  Widget _buildIndicator(BuildContext context, SyncState state) {
    final theme = Theme.of(context);

    if (state is SyncIdle) {
      return _buildIdleIndicator(context, state, theme);
    } else if (state is SyncInProgress) {
      return _buildProgressIndicator(context, state, theme);
    } else if (state is SyncSuccess) {
      return _buildSuccessIndicator(context, state, theme);
    } else if (state is SyncError) {
      return _buildErrorIndicator(context, state, theme);
    } else if (state is SyncOffline) {
      return _buildOfflineIndicator(context, state, theme);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildIdleIndicator(
      BuildContext context, SyncIdle state, ThemeData theme) {
    if (compact) {
      return Icon(
        state.isOnline ? Icons.cloud_done : Icons.cloud_off,
        size: 16,
        color: state.isOnline ? Colors.green : Colors.grey,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          state.isOnline ? Icons.cloud_done : Icons.cloud_off,
          size: 16,
          color: state.isOnline ? Colors.green : Colors.grey,
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            state.isOnline ? 'Synced' : 'Offline',
            style: theme.textTheme.bodySmall?.copyWith(
              color: state.isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ],
        if (state.pendingOperations > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${state.pendingOperations}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(
      BuildContext context, SyncInProgress state, ThemeData theme) {
    if (compact) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            state.message ?? 'Syncing...',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessIndicator(
      BuildContext context, SyncSuccess state, ThemeData theme) {
    if (compact) {
      return const Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.green,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green,
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            'Sync complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorIndicator(
      BuildContext context, SyncError state, ThemeData theme) {
    if (compact) {
      return const Icon(
        Icons.error,
        size: 16,
        color: Colors.red,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error,
          size: 16,
          color: Colors.red,
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            'Sync error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
          ),
        ],
        if (state.pendingOperations > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${state.pendingOperations}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfflineIndicator(
      BuildContext context, SyncOffline state, ThemeData theme) {
    if (compact) {
      return const Icon(
        Icons.cloud_off,
        size: 16,
        color: Colors.orange,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cloud_off,
          size: 16,
          color: Colors.orange,
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange,
            ),
          ),
        ],
        if (state.pendingOperations > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${state.pendingOperations}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Floating action button for manual sync
class SyncFloatingActionButton extends StatelessWidget {
  const SyncFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final isOnline = state is SyncIdle && state.isOnline ||
            state is SyncSuccess ||
            state is SyncError && state.isOnline;

        final isLoading = state is SyncInProgress;

        if (!isOnline) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          mini: true,
          onPressed: isLoading
              ? null
              : () {
                  context.read<SyncCubit>().forceSync();
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
        );
      },
    );
  }
}

/// Banner that shows when offline with pending operations
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        if (state is! SyncOffline || state.pendingOperations == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'re offline. ${state.pendingOperations} changes will sync when connected.',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
