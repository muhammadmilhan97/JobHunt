import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers/admin_approval_providers.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/widgets/app_logo.dart';

class UserApprovalPage extends ConsumerStatefulWidget {
  const UserApprovalPage({super.key});

  @override
  ConsumerState<UserApprovalPage> createState() => _UserApprovalPageState();
}

class _UserApprovalPageState extends ConsumerState<UserApprovalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminApprovalProvider.notifier).loadPendingUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approvalState = ref.watch(adminApprovalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'User Approval',
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                ref.read(adminApprovalProvider.notifier).loadPendingUsers();
              } else {
                ref.read(adminApprovalProvider.notifier).loadAllUsers();
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          onTap: (index) {
            if (index == 1 && approvalState.allUsers.isEmpty) {
              ref.read(adminApprovalProvider.notifier).loadAllUsers();
            }
          },
          tabs: [
            Tab(
              text: 'Pending (${approvalState.pendingUsers.length})',
              icon: const Icon(Icons.pending_actions),
            ),
            const Tab(
              text: 'All Users',
              icon: Icon(Icons.people),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingUsersTab(approvalState),
          _buildAllUsersTab(approvalState),
        ],
      ),
    );
  }

  Widget _buildPendingUsersTab(AdminApprovalState state) {
    if (state.isLoading && state.pendingUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorView(state.error!, () {
        ref.read(adminApprovalProvider.notifier).loadPendingUsers();
      });
    }

    if (state.pendingUsers.isEmpty) {
      return _buildEmptyState(
        'No Pending Approvals',
        'All user registrations have been reviewed.',
        Icons.check_circle_outline,
        Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminApprovalProvider.notifier).loadPendingUsers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.pendingUsers.length,
        itemBuilder: (context, index) {
          final user = state.pendingUsers[index];
          return _buildUserCard(user, isPending: true);
        },
      ),
    );
  }

  Widget _buildAllUsersTab(AdminApprovalState state) {
    if (state.isLoading && state.allUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorView(state.error!, () {
        ref.read(adminApprovalProvider.notifier).loadAllUsers();
      });
    }

    if (state.allUsers.isEmpty) {
      return _buildEmptyState(
        'No Users Found',
        'No registered users in the system.',
        Icons.person_off,
        Colors.grey,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminApprovalProvider.notifier).loadAllUsers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.allUsers.length,
        itemBuilder: (context, index) {
          final user = state.allUsers[index];
          return _buildUserCard(user, isPending: false);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {required bool isPending}) {
    final theme = Theme.of(context);
    final approvalStatus = user['approvalStatus'] as String? ?? 'pending';
    final role = user['role'] as String? ?? 'job_seeker';
    final name = user['name'] as String? ?? 'Unknown User';
    final email = user['email'] as String? ?? '';
    final createdAt = user['createdAt'];

    Color statusColor;
    IconData statusIcon;
    switch (approvalStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(role).withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(role),
                    color: _getRoleColor(role),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        approvalStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User details
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                      'Role', _getRoleDisplayName(role), _getRoleColor(role)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Registered',
                    createdAt != null ? _formatDate(createdAt) : 'Unknown',
                    Colors.blue,
                  ),
                ),
              ],
            ),

            // Rejection reason (if applicable)
            if (approvalStatus == 'rejected' &&
                user['rejectionReason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: ${user['rejectionReason']}',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (isPending || approvalStatus != 'approved') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (approvalStatus == 'pending') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(user),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveUser(user),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else if (approvalStatus == 'rejected') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveUser(user),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resetApproval(user),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Users',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveUser(Map<String, dynamic> user) async {
    final result = await ref.read(adminApprovalProvider.notifier).approveUser(
          user['id'],
          approverName: 'Admin User', // You can get this from current user
        );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('User ${user['name']} approved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result.errorMessage ?? 'Failed to approve user'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showRejectDialog(Map<String, dynamic> user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Reject ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejecting this user:',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Please provide a rejection reason')),
                );
                return;
              }

              // Close dialog first
              Navigator.of(dialogContext).pop();
              reasonController.dispose();

              // Wait for dialog to close before proceeding
              await Future.delayed(const Duration(milliseconds: 100));

              if (mounted) {
                await _rejectUser(user, reason);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectUser(Map<String, dynamic> user, String reason) async {
    final result = await ref.read(adminApprovalProvider.notifier).rejectUser(
          user['id'],
          reason,
          approverName: 'Admin User',
        );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('User ${user['name']} rejected'),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result.errorMessage ?? 'Failed to reject user'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetApproval(Map<String, dynamic> user) async {
    final result = await ref
        .read(adminApprovalProvider.notifier)
        .resetUserApproval(user['id']);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Reset approval status for ${user['name']}'),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Helper methods
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'job_seeker':
        return Icons.person_outline;
      case 'employer':
        return Icons.business_center_outlined;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'job_seeker':
        return Colors.blue;
      case 'employer':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'job_seeker':
        return 'Job Seeker';
      case 'employer':
        return 'Employer';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}
