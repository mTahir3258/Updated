import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/theme/app_colors.dart';
import 'package:ui_specification/core/theme/app_dimensions.dart';
import 'package:ui_specification/core/utils/responsive.dart';
import 'package:ui_specification/core/widgets/status_badge.dart';
import 'package:ui_specification/features/leads/providers/lead_provider.dart';
import 'package:ui_specification/features/communication/providers/communication_provider.dart';
import 'package:intl/intl.dart';
import 'package:ui_specification/core/constants/routes.dart';

/// Modern Lead Details Screen with premium styling
class LeadDetailScreen extends StatelessWidget {
  final String? leadId;

  const LeadDetailScreen({super.key, this.leadId});

  @override
  Widget build(BuildContext context) {
    final id = leadId ?? ModalRoute.of(context)!.settings.arguments as String;
    final lead = context.read<LeadProvider>().getLeadById(id);

    if (lead == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Not Found')),
        body: const Center(child: Text('Lead not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                lead.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.leadForm,
                    arguments: lead,
                  );
                },
                tooltip: 'Edit Lead',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Convert to Client')),
                  const PopupMenuItem(child: Text('Generate Quotation')),
                  const PopupMenuItem(child: Text('Delete')),
                ],
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personal Details Card with glassmorphism effect
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Personal Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          StatusBadge(
                            label: lead.status.toUpperCase(),
                            type: _getStatusType(lead.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.email_outlined, 'Email', lead.email),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Phone',
                        lead.phone,
                        action: IconButton(
                          icon: const Icon(
                            Icons.call,
                            size: 20,
                            color: AppColors.success,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      _buildInfoRow(
                        Icons.chat_outlined,
                        'WhatsApp',
                        lead.whatsapp,
                        action: IconButton(
                          icon: const Icon(
                            Icons.message,
                            size: 20,
                            color: AppColors.success,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        lead.address ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Communications Timeline
                Consumer<CommunicationProvider>(
                  builder: (context, commProvider, child) {
                    // In a real app, we'd filter by lead ID.
                    // For now, we'll show all messages as a demo or filter by a mock ID if available.
                    final messages =
                        commProvider.messages
                            .where(
                              (m) =>
                                  m.receiverId == lead.id ||
                                  m.senderId == lead.id,
                            )
                            .toList()
                          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    return _buildSectionCard(
                      title: 'Communication History',
                      icon: Icons.history_outlined,
                      count: messages.length,
                      actionLabel: 'Add Note',
                      onAction: () =>
                          _showAddNoteDialog(context, commProvider, lead.id),
                      child: messages.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No communications yet',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.secondaryLight,
                                    child: Icon(
                                      msg.senderId == '1'
                                          ? Icons.arrow_outward
                                          : Icons.arrow_downward,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  title: Text(
                                    msg.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    DateFormat(
                                      'MMM d, y h:mm a',
                                    ).format(msg.timestamp),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),

                const SizedBox(height: 80), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_comment),
        label: const Text('Add Communication'),
      ),
    );
  }

  void _showAddNoteDialog(
    BuildContext context,
    CommunicationProvider provider,
    String leadId,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note / Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter message details...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.sendMessage(controller.text, leadId);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required int count,
    required String actionLabel,
    required VoidCallback onAction,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    actionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  StatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return StatusType.newStatus;
      case 'in_progress':
        return StatusType.inProgress;
      case 'success':
        return StatusType.success;
      case 'failed':
        return StatusType.failed;
      default:
        return StatusType.pending;
    }
  }
}
