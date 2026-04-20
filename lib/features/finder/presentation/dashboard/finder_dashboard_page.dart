import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/finder_controller.dart';
import '../widgets/live_match_counter.dart';
import '../widgets/region_picker.dart';

class FinderDashboardPage extends ConsumerWidget {
  const FinderDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(finderControllerProvider);
    final ctl = ref.read(finderControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          IconButton(
            tooltip: '초기화',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctl.reset,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('지금 조건에', style: text.labelMedium),
                const SizedBox(height: 2),
                LiveMatchCounter(state: state),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _sectionTitle(context, '점수 범위'),
                _rangeRow(
                  context,
                  '난이도',
                  state.difficulty,
                  0,
                  5,
                  (v) => ctl.setDifficulty(v),
                ),
                _rangeRow(
                  context,
                  '공포도',
                  state.fear,
                  0,
                  5,
                  (v) => ctl.setFear(v),
                ),
                _rangeRow(
                  context,
                  '활동성',
                  state.activity,
                  0,
                  5,
                  (v) => ctl.setActivity(v),
                ),
                _rangeRow(
                  context,
                  '스토리',
                  state.story,
                  0,
                  5,
                  (v) => ctl.setStory(v),
                ),
                _rangeRow(
                  context,
                  '문제수준',
                  state.problem,
                  0,
                  5,
                  (v) => ctl.setProblem(v),
                ),
                _rangeRow(
                  context,
                  '인테리어',
                  state.interior,
                  0,
                  5,
                  (v) => ctl.setInterior(v),
                ),
                const SizedBox(height: 12),
                _sectionTitle(context, '시간 · 가격'),
                _rangeRow(
                  context,
                  '플레이타임',
                  state.playtime,
                  30,
                  120,
                  (v) => ctl.setPlaytime(v),
                  divisions: 9,
                  formatter: (v) => '${v.round()}분',
                ),
                _rangeRow(
                  context,
                  '가격',
                  state.price,
                  10000,
                  50000,
                  (v) => ctl.setPrice(v),
                  divisions: 40,
                  formatter: (v) => '${(v ~/ 1000)}k',
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('영업중만 보기'),
                  value: state.onlyOpen,
                  onChanged: ctl.setOnlyOpen,
                ),
                const SizedBox(height: 12),
                _sectionTitle(context, '지역'),
                RegionPicker(
                  selectedAreas: state.areas,
                  selectedLocations: state.locations,
                  onChanged: (areas, locations) {
                    ctl.setAreas(areas);
                    ctl.setLocations(locations);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            onPressed: () => context.push('/finder/results'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('결과 보기'),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2400.ms, color: scheme.primary.withValues(alpha: 0.35)),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String s) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(s, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _rangeRow(
    BuildContext context,
    String label,
    RangeValues value,
    double min,
    double max,
    ValueChanged<RangeValues> onChange, {
    int divisions = 10,
    String Function(double)? formatter,
  }) {
    final text = Theme.of(context).textTheme;
    final fmt = formatter ?? (double v) => v.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: text.labelLarge),
              const Spacer(),
              Text('${fmt(value.start)} – ${fmt(value.end)}', style: text.labelMedium),
            ],
          ),
          RangeSlider(
            values: value,
            min: min,
            max: max,
            divisions: divisions,
            labels: RangeLabels(fmt(value.start), fmt(value.end)),
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}
