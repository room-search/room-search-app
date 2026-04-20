import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cafe/data/cafe_repository.dart';
import '../../../cafe/data/models/cafe_location.dart';

const _priorityAreas = <String>['서울', '경기/인천', '경기', '인천'];

List<String> _sortAreas(List<String> original) {
  final priority = <String>[];
  for (final p in _priorityAreas) {
    if (original.contains(p)) priority.add(p);
  }
  final rest = original.where((a) => !_priorityAreas.contains(a)).toList();
  return [...priority, ...rest];
}

Map<String, List<String>> _groupByArea(List<CafeLocation> list) {
  final m = <String, List<String>>{};
  for (final loc in list) {
    final bucket = m.putIfAbsent(loc.area, () => <String>[]);
    if (loc.location.isNotEmpty && !bucket.contains(loc.location)) {
      bucket.add(loc.location);
    }
  }
  return m;
}

/// Hierarchical region picker: top-level area chips + nested sub-location
/// panels for each selected area.
///
/// [onChanged] is called with a ready-to-apply snapshot of the selection.
/// Orphan sub-locations (whose parent area was deselected) are dropped
/// automatically.
class RegionPicker extends ConsumerWidget {
  const RegionPicker({
    super.key,
    required this.selectedAreas,
    required this.selectedLocations,
    required this.onChanged,
  });

  final Set<String> selectedAreas;
  final Set<String> selectedLocations;
  final void Function(Set<String> areas, Set<String> locations) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final async = ref.watch(cafeLocationsProvider);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Text('지역 목록을 불러오지 못했어요', style: text.bodyMedium),
      data: (list) {
        final byArea = _groupByArea(list);
        final areas = _sortAreas(byArea.keys.toList());
        if (areas.isEmpty) {
          return Text('등록된 지역이 없어요', style: text.bodyMedium);
        }

        Set<String> intersectLocations(Set<String> nextAreas) {
          final valid = <String>{};
          for (final a in nextAreas) {
            valid.addAll(byArea[a] ?? const <String>[]);
          }
          return selectedLocations.intersection(valid);
        }

        void handleAreaTap(String area) {
          final next = {...selectedAreas};
          if (next.contains(area)) {
            next.remove(area);
          } else {
            next.add(area);
          }
          onChanged(next, intersectLocations(next));
        }

        void toggleLocation(String loc) {
          final next = {...selectedLocations};
          if (next.contains(loc)) {
            next.remove(loc);
          } else {
            next.add(loc);
          }
          onChanged(selectedAreas, next);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedAreas.length}개 지역 · '
                    '${selectedLocations.length}개 세부 지역',
                    style: text.labelMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                if (selectedAreas.isNotEmpty || selectedLocations.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        onChanged(const <String>{}, const <String>{}),
                    child: const Text('초기화'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in areas)
                  FilterChip(
                    label: Text(a),
                    selected: selectedAreas.contains(a),
                    showCheckmark: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    onSelected: (_) => handleAreaTap(a),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            for (final a in areas.where(selectedAreas.contains))
              _SubLocationsPanel(
                area: a,
                locations: byArea[a] ?? const <String>[],
                selected: selectedLocations,
                onToggle: toggleLocation,
              ),
            if (selectedAreas.isEmpty)
              Text(
                '선택하지 않으면 전국으로 검색돼요.',
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SubLocationsPanel extends StatelessWidget {
  const _SubLocationsPanel({
    required this.area,
    required this.locations,
    required this.selected,
    required this.onToggle,
  });

  final String area;
  final List<String> locations;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (locations.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$area 세부 지역',
                  style: text.titleMedium?.copyWith(
                      color: scheme.primary, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${locations.where(selected.contains).length} / ${locations.length}',
                style: text.labelMedium?.copyWith(
                  color: scheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final loc in locations)
                FilterChip(
                  label: Text(loc),
                  selected: selected.contains(loc),
                  showCheckmark: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  onSelected: (_) => onToggle(loc),
                ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 220.ms);
  }
}
