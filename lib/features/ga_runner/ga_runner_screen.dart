import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/scheduling_provider.dart';
import '../../core/state/ga_controller.dart';
import '../../core/state/ga_config.dart';

class GaRunnerScreen extends ConsumerWidget {
  const GaRunnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaState = ref.watch(gaControllerProvider);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);

    ref.listen<GaRunState>(gaControllerProvider, (previous, next) {
      if (previous?.isEvaluationDone != true &&
          next.isEvaluationDone == true &&
          workspaceId != null) {
        _showConfirmationDialog(context, ref, workspaceId, next);
      }
    });

    if (workspaceId == null) {
      return Center(child: Text(context.tr('select_workspace_first_runner')));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(context.tr('optimizer_context'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.05 * 12,
                        color: AppColors.onSurfaceVariant,
                      )),
            ],
          ),
          Text(context.tr('ga_runner_control_center'),
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 25,
                child: _ConfigPanel(
                  gaState: gaState,
                  onStartStop: () {
                    if (gaState.isRunning) {
                      ref.read(gaControllerProvider.notifier).stop();
                    } else {
                      ref
                          .read(gaControllerProvider.notifier)
                          .runOptimization(workspaceId);
                    }
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 50,
                child: _MonitoringPanel(gaState: gaState),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 25,
                child: _StatsPanel(gaState: gaState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, WidgetRef ref, int workspaceId, GaRunState state) {
    final best = state.pendingBestChromosome;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.secondary, size: 28),
              SizedBox(width: 12),
              Text(context.tr('optimization_complete_title')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('optimization_complete_body'),
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    _DialogStatRow(
                        label: context.tr('final_fitness_score'),
                        value: state.currentFitness.toStringAsFixed(6)),
                    _DialogStatRow(
                        label: context.tr('total_generations'),
                        value: '${state.currentGeneration}'),
                    _DialogStatRow(
                        label: context.tr('total_run_time'),
                        value: state.elapsedTimeFormatted),
                    if (best != null)
                      _DialogStatRow(
                          label: context.tr('sessions_scheduled'),
                          value: '${best.courseGenes.length}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('confirm_save_prompt'),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref
                    .read(gaControllerProvider.notifier)
                    .discardPendingSchedule();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(context.tr('schedules_discarded'))),
                );
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(context.tr('discard')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ref
                    .read(gaControllerProvider.notifier)
                    .savePendingSchedule(workspaceId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('schedules_saved')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: Text(context.tr('save_schedules')),
            ),
          ],
        );
      },
    );
  }
}

class _DialogStatRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogStatRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONFIG PANEL — Duration Selection Sliders
// ─────────────────────────────────────────────

class _ConfigPanel extends ConsumerStatefulWidget {
  final GaRunState gaState;
  final VoidCallback onStartStop;

  const _ConfigPanel({required this.gaState, required this.onStartStop});

  @override
  ConsumerState<_ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends ConsumerState<_ConfigPanel> {
  int _maxRunTimeMinutes = 5;
  int _extraTimeMinutes = 1;
  bool _configDirty = false;

  @override
  void initState() {
    super.initState();
    _maxRunTimeMinutes = widget.gaState.config.maxRunTimeMinutes;
    _extraTimeMinutes = widget.gaState.config.extraTimeMinutes;
  }

  @override
  void didUpdateWidget(covariant _ConfigPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gaState.config != widget.gaState.config) {
      _maxRunTimeMinutes = widget.gaState.config.maxRunTimeMinutes;
      _extraTimeMinutes = widget.gaState.config.extraTimeMinutes;
      _configDirty = false;
    }
  }

  void _markDirty() {
    if (!_configDirty) setState(() => _configDirty = true);
  }

  void _applyConfig() {
    final newConfig = widget.gaState.config.copyWith(
      maxRunTimeMinutes: _maxRunTimeMinutes,
      extraTimeMinutes: _extraTimeMinutes,
    );

    ref.read(gaControllerProvider.notifier).updateConfig(newConfig);
    setState(() => _configDirty = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('duration_applied')),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.gaState.isRunning;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('duration_config'),
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Max Run Time Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('max_run_time'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$_maxRunTimeMinutes min',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Slider(
            value: _maxRunTimeMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: '$_maxRunTimeMinutes min',
            onChanged: isRunning
                ? null
                : (v) => setState(() {
                      _maxRunTimeMinutes = v.round();
                      _markDirty();
                    }),
            activeColor: AppColors.secondaryContainer,
            inactiveColor: AppColors.surfaceVariant,
          ),
          Text(
            context.tr('max_run_time_desc'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),

          const SizedBox(height: 24),

          // Extra Time Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('extra_time'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$_extraTimeMinutes min',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Slider(
            value: _extraTimeMinutes.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_extraTimeMinutes min',
            onChanged: isRunning
                ? null
                : (v) => setState(() {
                      _extraTimeMinutes = v.round();
                      _markDirty();
                    }),
            activeColor: AppColors.secondaryContainer,
            inactiveColor: AppColors.surfaceVariant,
          ),
          Text(
            context.tr('extra_time_desc'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),

          const SizedBox(height: 24),

          if (_configDirty && !isRunning)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _applyConfig,
                child: Text(context.tr('apply_config')),
              ),
            ),

          if (_configDirty && !isRunning) const SizedBox(height: 12),

          const Divider(height: 32),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('active_rules'),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(context.trArgs('max_time_value', [widget.gaState.config.maxRunTimeMinutes.toString()]),
                    style:
                        const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text(
                    context.trArgs('extra_time_value', [widget.gaState.config.extraTimeMinutes.toString()]),
                    style:
                        const TextStyle(fontSize: 11, fontFamily: 'monospace')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onStartStop,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRunning ? Colors.grey.shade700 : AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isRunning
                    ? context.tr('stop_optimization')
                    : context.tr('start_optimization'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isRunning
                  ? null
                  : () => ref.read(gaControllerProvider.notifier).reset(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(context.tr('reset')),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MONITORING PANEL — With Error Banner
// ─────────────────────────────────────────────

class _MonitoringPanel extends ConsumerWidget {
  final GaRunState gaState;

  const _MonitoringPanel({required this.gaState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 20),
                  const SizedBox(width: 8),
                  Text(context.tr('monitoring'),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              Row(
                children: [
                  _LegendChip(
                      label: context.tr('fitness_score'), color: AppColors.secondary),
                  const SizedBox(width: 8),
                  _LegendChip(label: context.tr('penalty_drops'), color: Colors.red),
                ],
              ),
            ],
          ),

          // Error Banner
          if (gaState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gaState.error!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: AppColors.error, size: 18),
                    tooltip: 'Reset',
                    onPressed: () =>
                        ref.read(gaControllerProvider.notifier).reset(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('current_fitness_score'),
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    gaState.currentFitness.toStringAsFixed(6),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 28,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        gaState.isRunning
                            ? Icons.trending_up
                            : Icons.trending_flat,
                        size: 16,
                        color: gaState.isRunning
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gaState.isRunning ? context.tr('converging') : context.tr('idle'),
                        style: TextStyle(
                          color: gaState.isRunning
                              ? AppColors.secondary
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(context.tr('convergence_rate'),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 300,
            child: gaState.fitnessPoints.isEmpty
                ? Center(
                    child: Text(
                      context.tr('empty_chart'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'Gen ${value.toInt()}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: gaState.fitnessPoints,
                          isCurved: true,
                          color: AppColors.secondary,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) {
                            return spots.map((s) {
                              return LineTooltipItem(
                                'Gen ${s.x.toInt()}\nFit: ${s.y.toStringAsFixed(6)}',
                                const TextStyle(fontSize: 11),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Generation progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.trArgs('time_progress', [gaState.currentGeneration.toString()]),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '${gaState.elapsedTimeFormatted} / ${gaState.config.maxRunTimeMinutes}m max',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: gaState.timeProgress,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.tr('data_points'),
                      style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    '${gaState.fitnessPoints.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATS PANEL — Dynamic Status + Computed Time
// ─────────────────────────────────────────────

class _StatsPanel extends ConsumerWidget {
  final GaRunState gaState;

  const _StatsPanel({required this.gaState});

  Color get _statusColor {
    if (gaState.isRunning) return Colors.green;
    if (gaState.isEvaluationDone) return Colors.amber;
    if (gaState.error != null) return Colors.red;
    if (gaState.currentGeneration > 0) return Colors.blue;
    return AppColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = gaState.timeProgress;

    return Column(
      children: [
        // Status Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                      boxShadow: gaState.isRunning
                          ? [
                              BoxShadow(
                                  color: _statusColor.withValues(alpha: 0.5),
                                  blurRadius: 4)
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gaState.statusLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('generations_run'),
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                '${gaState.currentGeneration}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  color: _statusColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),
              _StatRow(
                  label: context.tr('elapsed_time'), value: gaState.elapsedTimeFormatted),
              _StatRow(
                  label: context.tr('est_remaining'), value: gaState.estimatedRemaining),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Best Solution Panel
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 20, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(context.tr('best_solution'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (gaState.currentGeneration > 0 && !gaState.isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(context.tr('done'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('conflict_penalty'),
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          '${((1 - gaState.currentFitness) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(context.tr('fitness'),
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          gaState.currentFitness.toStringAsFixed(4),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _StatRow(
                  label: context.tr('fitness_score'),
                  value: gaState.currentFitness.toStringAsFixed(4),
                  isRightAligned: true),
              _StatRow(
                  label: context.tr('best_fitness'),
                  value: gaState.bestFitness.toStringAsFixed(4),
                  isRightAligned: true),
              _StatRow(
                  label: context.tr('improvement'),
                  value: gaState.improvementDelta,
                  isRightAligned: true),
              const SizedBox(height: 16),

              // FIXED: Inspect Schedule button now navigates
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final wsId = ref.read(activeWorkspaceIdProvider);
                    if (wsId != null) {
                      context.go('/schedule');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context.tr('select_workspace_first_snack'))),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(context.tr('inspect_schedule')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isRightAligned;

  const _StatRow({
    required this.label,
    required this.value,
    this.isRightAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isRightAligned
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  fontSize: 13),
              textAlign: isRightAligned ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
