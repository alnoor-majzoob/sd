import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../src/database/repositories/workspace_repository.dart';
import '../../src/database/repositories/schedule_repository.dart';
import '../../src/database/app_database.dart';
import 'ga_controller.dart';

// The ID of the workspace currently being viewed/edited
final activeWorkspaceIdProvider = StateProvider<int?>((ref) => null);

// Provider for the list of all workspaces
final workspacesProvider = FutureProvider<List<ScheduleWorkspace>>((ref) async {
  return GetIt.I<WorkspaceRepository>().getAllWorkspaces();
});

// Provider for the current active workspace details
final activeWorkspaceProvider = FutureProvider.family<ScheduleWorkspace?, int>((ref, workspaceId) async {
  final all = await ref.watch(workspacesProvider.future);
  return all.where((w) => w.id == workspaceId).firstOrNull;
});

// Provider to fetch the schedule rows for the active workspace
// Returns List<Schedule> (Drift-generated data class)
final activeScheduleProvider = FutureProvider.family<List<Schedule>, int>((ref, workspaceId) async {
  if (workspaceId <= 0) return [];
  return GetIt.I<ScheduleRepository>().getSchedulesByWorkspace(workspaceId);
});

// GA Progress provider per workspace — surfaces GaRunState data for the given workspace
// When multiple workspaces would have concurrent GA runs, this maps workspaceId -> GaRunState
// Currently single-GA: uses the global gaControllerProvider
final gaProgressProvider = Provider.family<GaRunState, int>((ref, workspaceId) {
  // If this workspace is the active one being optimized, return live state
  // Otherwise return idle state
  // Note: In a full multi-workspace-concurrent scenario, you'd have a
  // Map<int, GaRunState> in a provider. For now, single active GA at a time:
  final gaState = ref.watch(gaControllerProvider);
  final activeWsId = ref.watch(activeWorkspaceIdProvider);
  if (activeWsId == workspaceId) {
    return gaState;
  }
  return const GaRunState(); // Idle state for non-active workspaces
});
