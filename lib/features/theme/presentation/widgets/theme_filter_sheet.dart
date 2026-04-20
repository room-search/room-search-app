import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../finder/presentation/widgets/region_picker.dart';
import '../../data/models/theme_search_query.dart';

Future<ThemeSearchQuery?> showThemeFilterSheet(
  BuildContext context, {
  required ThemeSearchQuery initial,
}) {
  return showModalBottomSheet<ThemeSearchQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ThemeFilterSheet(initial: initial),
  );
}

class _ThemeFilterSheet extends ConsumerStatefulWidget {
  const _ThemeFilterSheet({required this.initial});
  final ThemeSearchQuery initial;

  @override
  ConsumerState<_ThemeFilterSheet> createState() => _ThemeFilterSheetState();
}

class _ThemeFilterSheetState extends ConsumerState<_ThemeFilterSheet> {
  late RangeValues _difficulty;
  late RangeValues _fear;
  late RangeValues _activity;
  late RangeValues _story;
  late RangeValues _problem;
  late RangeValues _playtime;
  late RangeValues _price;
  late Set<String> _areas;
  late Set<String> _locations;
  late bool _onlyOpen;

  @override
  void initState() {
    super.initState();
    final q = widget.initial;
    _difficulty = RangeValues(q.startDifficulty ?? 0, q.endDifficulty ?? 5);
    _fear = RangeValues(q.startFear ?? 0, q.endFear ?? 5);
    _activity = RangeValues(q.startActivity ?? 0, q.endActivity ?? 5);
    _story = RangeValues(q.startStory ?? 0, q.endStory ?? 5);
    _problem = RangeValues(q.startProblem ?? 0, q.endProblem ?? 5);
    _playtime = RangeValues(
      (q.startPlaytime ?? 30).toDouble(),
      (q.endPlaytime ?? 120).toDouble(),
    );
    _price = RangeValues(
      (q.startPrice ?? 10000).toDouble(),
      (q.endPrice ?? 50000).toDouble(),
    );
    _areas = {...q.areas};
    _locations = {...q.locations};
    _onlyOpen = q.onlyOpen ?? false;
  }

  void _reset() {
    setState(() {
      _difficulty = const RangeValues(0, 5);
      _fear = const RangeValues(0, 5);
      _activity = const RangeValues(0, 5);
      _story = const RangeValues(0, 5);
      _problem = const RangeValues(0, 5);
      _playtime = const RangeValues(30, 120);
      _price = const RangeValues(10000, 50000);
      _areas = {};
      _locations = {};
      _onlyOpen = false;
    });
  }

  ThemeSearchQuery _build() {
    double? startOrNull(RangeValues r) => r.start == 0 ? null : r.start;
    double? endOrNull(RangeValues r) => r.end == 5 ? null : r.end;
    int? pStart(RangeValues r, int min) => r.start <= min ? null : r.start.round();
    int? pEnd(RangeValues r, int max) => r.end >= max ? null : r.end.round();

    return widget.initial.copyWith(
      startDifficulty: startOrNull(_difficulty),
      endDifficulty: endOrNull(_difficulty),
      startFear: startOrNull(_fear),
      endFear: endOrNull(_fear),
      startActivity: startOrNull(_activity),
      endActivity: endOrNull(_activity),
      startStory: startOrNull(_story),
      endStory: endOrNull(_story),
      startProblem: startOrNull(_problem),
      endProblem: endOrNull(_problem),
      startPlaytime: pStart(_playtime, 30),
      endPlaytime: pEnd(_playtime, 120),
      startPrice: pStart(_price, 10000),
      endPrice: pEnd(_price, 50000),
      areas: _areas.toList(),
      locations: _locations.toList(),
      onlyOpen: _onlyOpen ? true : null,
      page: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: scheme.outline.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: Row(
              children: [
                Text('필터', style: text.headlineMedium),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('초기화')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              children: [
                _scoreRange('난이도', _difficulty, (v) => setState(() => _difficulty = v)),
                _scoreRange('공포도', _fear, (v) => setState(() => _fear = v)),
                _scoreRange('활동성', _activity, (v) => setState(() => _activity = v)),
                _scoreRange('스토리', _story, (v) => setState(() => _story = v)),
                _scoreRange('문제수준', _problem, (v) => setState(() => _problem = v)),
                const SizedBox(height: 8),
                _intRange(
                  '플레이타임 (분)',
                  _playtime,
                  min: 30,
                  max: 120,
                  step: 10,
                  format: (v) => '${v.round()}분',
                  onChange: (v) => setState(() => _playtime = v),
                ),
                _intRange(
                  '가격 (원)',
                  _price,
                  min: 10000,
                  max: 50000,
                  step: 1000,
                  format: (v) => '${(v ~/ 1000)}k',
                  onChange: (v) => setState(() => _price = v),
                ),
                const SizedBox(height: 4),
                SwitchListTile.adaptive(
                  title: const Text('영업중만 보기'),
                  contentPadding: EdgeInsets.zero,
                  value: _onlyOpen,
                  onChanged: (v) => setState(() => _onlyOpen = v),
                ),
                const SizedBox(height: 12),
                Text('지역', style: text.titleMedium),
                const SizedBox(height: 8),
                RegionPicker(
                  selectedAreas: _areas,
                  selectedLocations: _locations,
                  onChanged: (areas, locations) => setState(() {
                    _areas = areas;
                    _locations = locations;
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_build()),
                      child: const Text('적용'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRange(String label, RangeValues v, ValueChanged<RangeValues> onChange) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: text.titleMedium),
              const Spacer(),
              Text(
                '${v.start.toStringAsFixed(1)} – ${v.end.toStringAsFixed(1)}',
                style: text.labelMedium,
              ),
            ],
          ),
          RangeSlider(
            min: 0,
            max: 5,
            divisions: 10,
            values: v,
            labels: RangeLabels(
              v.start.toStringAsFixed(1),
              v.end.toStringAsFixed(1),
            ),
            onChanged: onChange,
          ),
        ],
      ),
    );
  }

  Widget _intRange(
    String label,
    RangeValues v, {
    required double min,
    required double max,
    required double step,
    required String Function(double) format,
    required ValueChanged<RangeValues> onChange,
  }) {
    final text = Theme.of(context).textTheme;
    final divisions = ((max - min) / step).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: text.titleMedium),
              const Spacer(),
              Text('${format(v.start)} – ${format(v.end)}', style: text.labelMedium),
            ],
          ),
          RangeSlider(
            min: min,
            max: max,
            divisions: divisions,
            values: v,
            labels: RangeLabels(format(v.start), format(v.end)),
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}
