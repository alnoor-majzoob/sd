import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/state/scheduling_provider.dart';
import '../../core/state/ga_controller.dart';
import '../../src/database/app_database.dart';
import '../../src/database/repositories/workspace_repository.dart';
import '../../core/localization/app_localizations.dart';

const _workspaceColors = [
  '#4299E1', // Blue
  '#48BB78', // Green
  '#ED8936', // Orange
  '#9F7AEA', // Purple
  '#F56565', // Red
  '#38B2AC', // Teal
  '#ECC94B', // Yellow
];

extension _ColorExt on Color {
  static Color parse(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

// ─────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────

class WorkspaceHubScreen extends ConsumerWidget {
  const WorkspaceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspacesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('workspace_hub_title'), style: Theme.of(context).textTheme.displayLarge),
                  Text(
                    context.tr('workspace_hub_subtitle'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _createWorkspace(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(context.tr('create_new_workspace'), style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          workspacesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(context.trArgs('failed_workspaces', [err.toString()]), style: const TextStyle(color: Colors.red)),
              ),
            ),
            data: (workspaces) => Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                ...workspaces.map((ws) => _WorkspaceCard(
                  key: ValueKey(ws.id),
                  workspace: ws,
                  onOpen: () {
                    ref.read(activeWorkspaceIdProvider.notifier).state = ws.id;
                    context.go('/data');
                  },
                  onDelete: () => _deleteWorkspace(context, ref, ws.id),
                  onRunGA: () {
                    ref.read(activeWorkspaceIdProvider.notifier).state = ws.id;
                    context.go('/runner');
                  },
                )),
                _CreateWorkspaceGhostCard(onCreate: () => _createWorkspace(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createWorkspace(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    String selectedColor = _workspaceColors.first;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(ctx.tr('new_workspace')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: ctx.tr('workspace_name'),
                  hintText: ctx.tr('workspace_name_hint'),
                ),
              ),
              const SizedBox(height: 20),
              Text(ctx.tr('color'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workspaceColors.map((hex) {
                  final isSelected = selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _ColorExt.parse(hex),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('cancel'))),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, {
                    'name': nameController.text.trim(),
                    'color': selectedColor,
                  });
                }
              },
              child: Text(ctx.tr('create')),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['name']!.isNotEmpty) {
      await GetIt.I<WorkspaceRepository>().createWorkspace(
        name: result['name']!,
        color: result['color']!,
      );
      ref.invalidate(workspacesProvider);
    }
  }

  Future<void> _deleteWorkspace(BuildContext context, WidgetRef ref, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('delete_workspace_title')),
        content: Text(ctx.tr('delete_workspace_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ctx.tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(ctx.tr('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await GetIt.I<WorkspaceRepository>().deleteWorkspace(id);
      ref.invalidate(workspacesProvider);
    }
  }
}

// ─────────────────────────────────────────────────────
// WORKSPACE CARD — wired to GaRunState
// ─────────────────────────────────────────────────────

class _WorkspaceCard extends ConsumerWidget {
  final ScheduleWorkspace workspace;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onRunGA;

  const _WorkspaceCard({
    super.key,
    required this.workspace,
    required this.onOpen,
    required this.onDelete,
    required this.onRunGA,
  });

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch GA state for this specific workspace
    final gaState = ref.watch(gaProgressProvider(workspace.id));
    final activeWsId = ref.watch(activeWorkspaceIdProvider);
    final isActiveWorkspace = activeWsId == workspace.id;
    final isOptimizing = isActiveWorkspace && gaState.isRunning;

    final accentColor = _parseColor(workspace.color);

    // Derive display status from GA state
    String statusLabel;
    if (isOptimizing) {
      statusLabel = context.tr('optimizing');
    } else if (isActiveWorkspace && gaState.currentGeneration > 0) {
      statusLabel = context.tr('optimized');
    } else {
      statusLabel = workspace.status;
    }

    // Progress from GA state
    final generationLimit = gaState.config.generationLimit;
    final currentGen = gaState.currentGeneration;
    final progress = generationLimit > 0 ? currentGen / generationLimit : 0.0;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOptimizing ? accentColor.withValues(alpha: 0.5) : AppColors.outlineVariant,
          width: isOptimizing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOptimizing ? accentColor.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
            blurRadius: isOptimizing ? 8 : 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored accent bar
            Container(
              height: isOptimizing ? 6 : 4,
              color: accentColor,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workspace.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(status: statusLabel, isOptimizing: isOptimizing),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(_formatTimestamp(workspace.timestamp), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),

                  // GA progress bar — only shown when actively optimizing
                  if (isOptimizing) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.trArgs('gen_progress', [currentGen.toString(), generationLimit.toString()]),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                        ),
                        Text(
                          context.trArgs('percent_value', [(progress * 100).toStringAsFixed(1)]),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceVariant,
                        color: accentColor,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          context.trArgs('elapsed', [gaState.elapsedTimeFormatted]),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ] else if (isActiveWorkspace && gaState.currentGeneration > 0) ...[
                    // Show completion info when optimized but not running
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.trArgs('completed_generations', [gaState.currentGeneration.toString()]),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  context.trArgs('fitness_value', [gaState.currentFitness.toStringAsFixed(4)]),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: isOptimizing
                            ? OutlinedButton(
                                onPressed: () => ref.read(gaControllerProvider.notifier).stop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.stop, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text(context.tr('stop'), style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              )
                            : OutlinedButton(
                                onPressed: onOpen,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  statusLabel == context.tr('optimized') ? context.tr('view_schedule') : context.tr('open'),
                                  style: const TextStyle(color: AppColors.onSurface),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      // GA run button
                      IconButton(
                        onPressed: isOptimizing ? null : onRunGA,
                        icon: const Icon(Icons.play_arrow, size: 20),
                        tooltip: context.tr('run_ga_optimizer'),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: isOptimizing
                              ? AppColors.surfaceContainerLow
                              : accentColor.withValues(alpha: 0.1),
                          foregroundColor: isOptimizing
                              ? AppColors.onSurfaceVariant
                              : accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        tooltip: context.tr('delete_workspace'),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: AppColors.outlineVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// STATUS CHIP
// ─────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isOptimizing;

  const _StatusChip({required this.status, this.isOptimizing = false});

  @override
  Widget build(BuildContext context) {
    final isOptimizing_ = status == context.tr('optimizing');
    final isOptimized = status == context.tr('optimized');

    Color bgColor;
    Color textColor;

    if (isOptimizing_) {
      bgColor = Colors.orange;
      textColor = Colors.white;
    } else if (isOptimized) {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else {
      bgColor = AppColors.surfaceContainerHigh;
      textColor = AppColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOptimizing_)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: _PulsingDot(),
            ),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3 + 0.7 * _controller.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CREATE WORKSPACE GHOST CARD
// ─────────────────────────────────────────────────────

class _CreateWorkspaceGhostCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _CreateWorkspaceGhostCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: InkWell(
        onTap: onCreate,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: const Icon(Icons.add, color: AppColors.onSurfaceVariant, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('create_workspace_card'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('start_new_project'),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
