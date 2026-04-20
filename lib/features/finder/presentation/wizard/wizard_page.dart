import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/finder_controller.dart';
import '../../application/finder_state.dart';
import '../widgets/choice_card.dart';
import '../widgets/live_match_counter.dart';
import '../widgets/region_picker.dart';

class WizardPage extends ConsumerStatefulWidget {
  const WizardPage({super.key});

  @override
  ConsumerState<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends ConsumerState<WizardPage> {
  final _pageCtl = PageController();
  int _index = 0;

  int get _stepCount => 5;

  void _next() {
    if (_index < _stepCount - 1) {
      _pageCtl.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.push('/finder/results');
    }
  }

  void _prev() {
    if (_index == 0) {
      context.pop();
    } else {
      _pageCtl.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goResults() => context.push('/finder/results');

  void _resetAll() {
    ref.read(finderControllerProvider.notifier).reset();
    if (_pageCtl.hasClients) {
      _pageCtl.jumpToPage(0);
    }
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(finderControllerProvider);
    final ctl = ref.read(finderControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prev,
        ),
        title: Text('${_index + 1} / $_stepCount'),
        actions: [
          TextButton(
            onPressed: _resetAll,
            child: const Text('초기화'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: LayoutBuilder(
              builder: (ctx, c) {
                final full = c.maxWidth;
                return Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: full * ((_index + 1) / _stepCount),
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageCtl,
              onPageChanged: (i) => setState(() => _index = i),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step(
                  title: '관심 지역',
                  hint: '어느 지역에서 찾아드릴까요? (여러 개 선택 가능)',
                  child: _LocationStep(state: state, ctl: ctl),
                ),
                _Step(
                  title: '공포 취향',
                  hint: '얼마나 무서워도 괜찮나요?',
                  child: _FearStep(state: state, ctl: ctl),
                ),
                _Step(
                  title: '난이도 · 활동성',
                  hint: '원하는 도전 강도와 몸을 쓰는 정도를 골라 주세요',
                  child: _DifficultyActivityStep(state: state, ctl: ctl),
                ),
                _Step(
                  title: '스토리 · 문제',
                  hint: '원하는 경험의 결을 고르세요',
                  child: _StoryProblemStep(state: state, ctl: ctl),
                ),
                _Step(
                  title: '시간 · 예산',
                  hint: '플레이 시간과 가격 범위를 알려주세요',
                  child: _TimeBudgetStep(state: state, ctl: ctl),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text('지금 조건으로',
                          style: text.labelMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          )),
                      const SizedBox(width: 8),
                      LiveMatchCounter(state: state),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goResults,
                          icon: const Icon(Icons.bolt_rounded),
                          label: const Text('바로 결과 보기'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(_index == _stepCount - 1 ? '결과 보기' : '다음'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineLarge)
              .animate()
              .fadeIn(duration: 260.ms)
              .slideY(begin: 0.08, end: 0, duration: 260.ms),
          const SizedBox(height: 4),
          Text(
            hint,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ).animate().fadeIn(duration: 260.ms, delay: 60.ms),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: child.animate().fadeIn(duration: 260.ms, delay: 80.ms),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.state, required this.ctl});
  final FinderState state;
  final FinderController ctl;

  @override
  Widget build(BuildContext context) {
    return RegionPicker(
      selectedAreas: state.areas,
      selectedLocations: state.locations,
      onChanged: (areas, locations) {
        ctl.setAreas(areas);
        ctl.setLocations(locations);
      },
    );
  }
}

/// Fear tolerance range labels (matches FinderState.effectiveFear bounds).
const _fearHintByTolerance = <FearTolerance?, String>{
  null: '점수 0.0 – 5.0',
  FearTolerance.none: '점수 0.0 – 1.0',
  FearTolerance.mild: '점수 0.0 – 2.0',
  FearTolerance.moderate: '점수 1.5 – 3.5',
  FearTolerance.strong: '점수 2.5 – 4.5',
  FearTolerance.lover: '점수 3.5 – 5.0',
};

class _FearStep extends StatelessWidget {
  const _FearStep({required this.state, required this.ctl});
  final FinderState state;
  final FinderController ctl;

  @override
  Widget build(BuildContext context) {
    final options = <_Choice<FearTolerance?>>[
      _Choice(null, '상관없어요', '공포 정도에 관계없이 추천', Icons.all_inclusive_rounded),
      _Choice(FearTolerance.none, '하나도 안 무서운 걸', '공포 요소 거의 없는 테마',
          Icons.mood_rounded),
      _Choice(FearTolerance.mild, '살짝만 긴장되는', '긴장감은 있지만 무섭지 않게',
          Icons.sentiment_satisfied_alt_rounded),
      _Choice(FearTolerance.moderate, '적당히', '적당한 긴장과 스릴',
          Icons.sentiment_neutral_rounded),
      _Choice(FearTolerance.strong, '많이 무서워도 OK', '본격 공포도 괜찮아요',
          Icons.sentiment_dissatisfied_rounded),
      _Choice(FearTolerance.lover, '공포 매니아', '가장 무서운 걸로 주세요',
          Icons.mood_bad_rounded),
    ];
    return _ChoiceColumn(
      options: options,
      value: state.fearTolerance,
      onChanged: ctl.setFearTolerance,
      rangeHintOf: (v) => _fearHintByTolerance[v],
    );
  }
}

/// Generic range-choice option descriptor.
class _RangeOption {
  const _RangeOption({
    required this.label,
    required this.sub,
    required this.icon,
    required this.range,
  });
  final String label;
  final String sub;
  final IconData icon;
  final RangeValues range;
}

String _scoreHint(RangeValues r, {double min = 0, double max = 5}) {
  if (r.start <= min && r.end >= max) return '점수 전체 범위';
  return '점수 ${r.start.toStringAsFixed(1)} – ${r.end.toStringAsFixed(1)}';
}

String _minuteHint(RangeValues r) {
  if (r.start <= 30 && r.end >= 120) return '플레이타임 전체';
  return '${r.start.round()} – ${r.end.round()}분';
}

String _priceHint(RangeValues r) {
  if (r.start <= 10000 && r.end >= 50000) return '가격 전체';
  return '${(r.start ~/ 1000)}k – ${(r.end ~/ 1000)}k원';
}

class _RangeChoiceColumn extends StatelessWidget {
  const _RangeChoiceColumn({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.hintBuilder,
  });

  final List<_RangeOption> options;
  final RangeValues value;
  final ValueChanged<RangeValues> onChanged;
  final String Function(RangeValues) hintBuilder;

  bool _matches(RangeValues a, RangeValues b) =>
      (a.start - b.start).abs() < 0.01 && (a.end - b.end).abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          ChoiceCard(
            icon: options[i].icon,
            title: options[i].label,
            subtitle: options[i].sub,
            rangeHint: hintBuilder(options[i].range),
            selected: _matches(options[i].range, value),
            onTap: () => onChanged(options[i].range),
          )
              .animate()
              .fadeIn(duration: 220.ms, delay: (40 * i).ms)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 220.ms,
                delay: (40 * i).ms,
              ),
          if (i != options.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Difficulty / activity / story / problem share the same 0-5 preset buckets.
const _scoreAny = RangeValues(0, 5);

List<_RangeOption> _difficultyOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '난이도에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: _scoreAny,
      ),
      _RangeOption(
        label: '입문 · 쉬운편',
        sub: '방탈출이 처음이거나 가볍게',
        icon: Icons.emoji_people_rounded,
        range: RangeValues(0, 2),
      ),
      _RangeOption(
        label: '중급 · 보통',
        sub: '몇 번 해본 분들께 적당한 정도',
        icon: Icons.trending_up_rounded,
        range: RangeValues(2, 3.5),
      ),
      _RangeOption(
        label: '고급 · 도전적',
        sub: '난이도 높은 테마를 원해요',
        icon: Icons.whatshot_rounded,
        range: RangeValues(3, 4.5),
      ),
      _RangeOption(
        label: '전문가급',
        sub: '가장 어려운 테마로 도전',
        icon: Icons.military_tech_rounded,
        range: RangeValues(4, 5),
      ),
    ];

List<_RangeOption> _activityOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '활동성에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: _scoreAny,
      ),
      _RangeOption(
        label: '조용하게',
        sub: '앉아서 풀어가는 추리형',
        icon: Icons.event_seat_rounded,
        range: RangeValues(0, 2),
      ),
      _RangeOption(
        label: '적당히 움직이기',
        sub: '조금 이동하며 즐기는 수준',
        icon: Icons.directions_walk_rounded,
        range: RangeValues(2, 3.5),
      ),
      _RangeOption(
        label: '활발하게',
        sub: '뛰거나 몸을 많이 쓰는 테마',
        icon: Icons.directions_run_rounded,
        range: RangeValues(3.5, 5),
      ),
    ];

List<_RangeOption> _storyOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '스토리 비중에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: _scoreAny,
      ),
      _RangeOption(
        label: '가볍게',
        sub: '스토리보다는 문제 풀이 위주',
        icon: Icons.bubble_chart_rounded,
        range: RangeValues(0, 2),
      ),
      _RangeOption(
        label: '적당한 서사',
        sub: '기본 스토리 + 문제 풀이 균형',
        icon: Icons.menu_book_rounded,
        range: RangeValues(2, 3.5),
      ),
      _RangeOption(
        label: '스토리 진심',
        sub: '몰입감 있는 서사 중심',
        icon: Icons.auto_stories_rounded,
        range: RangeValues(3.5, 5),
      ),
    ];

List<_RangeOption> _problemOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '문제 난도에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: _scoreAny,
      ),
      _RangeOption(
        label: '단순한 문제',
        sub: '직관적이고 가볍게 풀리는',
        icon: Icons.extension_rounded,
        range: RangeValues(0, 2),
      ),
      _RangeOption(
        label: '보통',
        sub: '적당한 두뇌 활용 정도',
        icon: Icons.psychology_alt_rounded,
        range: RangeValues(2, 3.5),
      ),
      _RangeOption(
        label: '복잡한 문제',
        sub: '고난도 퍼즐 · 추리 선호',
        icon: Icons.psychology_rounded,
        range: RangeValues(3.5, 5),
      ),
    ];

List<_RangeOption> _playtimeOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '플레이 시간에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: RangeValues(30, 120),
      ),
      _RangeOption(
        label: '짧게',
        sub: '30 – 60분 이내로',
        icon: Icons.timer_rounded,
        range: RangeValues(30, 60),
      ),
      _RangeOption(
        label: '보통',
        sub: '60 – 90분',
        icon: Icons.timelapse_rounded,
        range: RangeValues(60, 90),
      ),
      _RangeOption(
        label: '길게',
        sub: '90 – 120분, 깊이 있게',
        icon: Icons.hourglass_bottom_rounded,
        range: RangeValues(90, 120),
      ),
    ];

List<_RangeOption> _priceOptions() => const [
      _RangeOption(
        label: '상관없어요',
        sub: '가격에 관계없이 추천',
        icon: Icons.all_inclusive_rounded,
        range: RangeValues(10000, 50000),
      ),
      _RangeOption(
        label: '저렴하게',
        sub: '인당 25,000원 이하',
        icon: Icons.savings_rounded,
        range: RangeValues(10000, 25000),
      ),
      _RangeOption(
        label: '적당히',
        sub: '인당 2 – 3.5만원대',
        icon: Icons.account_balance_wallet_rounded,
        range: RangeValues(20000, 35000),
      ),
      _RangeOption(
        label: '프리미엄',
        sub: '인당 3.5만원 이상도 OK',
        icon: Icons.diamond_rounded,
        range: RangeValues(35000, 50000),
      ),
    ];

class _DifficultyActivityStep extends StatelessWidget {
  const _DifficultyActivityStep({required this.state, required this.ctl});
  final FinderState state;
  final FinderController ctl;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('난이도', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _difficultyOptions(),
          value: state.difficulty,
          onChanged: ctl.setDifficulty,
          hintBuilder: (r) => _scoreHint(r),
        ),
        const SizedBox(height: 20),
        Text('활동성', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _activityOptions(),
          value: state.activity,
          onChanged: ctl.setActivity,
          hintBuilder: (r) => _scoreHint(r),
        ),
      ],
    );
  }
}

class _StoryProblemStep extends StatelessWidget {
  const _StoryProblemStep({required this.state, required this.ctl});
  final FinderState state;
  final FinderController ctl;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('스토리', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _storyOptions(),
          value: state.story,
          onChanged: ctl.setStory,
          hintBuilder: (r) => _scoreHint(r),
        ),
        const SizedBox(height: 20),
        Text('문제수준', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _problemOptions(),
          value: state.problem,
          onChanged: ctl.setProblem,
          hintBuilder: (r) => _scoreHint(r),
        ),
      ],
    );
  }
}

class _TimeBudgetStep extends StatelessWidget {
  const _TimeBudgetStep({required this.state, required this.ctl});
  final FinderState state;
  final FinderController ctl;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('플레이타임', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _playtimeOptions(),
          value: state.playtime,
          onChanged: ctl.setPlaytime,
          hintBuilder: _minuteHint,
        ),
        const SizedBox(height: 20),
        Text('가격', style: text.titleMedium),
        const SizedBox(height: 8),
        _RangeChoiceColumn(
          options: _priceOptions(),
          value: state.price,
          onChanged: ctl.setPrice,
          hintBuilder: _priceHint,
        ),
      ],
    );
  }
}

class _Choice<T> {
  const _Choice(this.value, this.label, this.sub, this.icon);
  final T value;
  final String label;
  final String sub;
  final IconData icon;
}

class _ChoiceColumn<T> extends StatelessWidget {
  const _ChoiceColumn({
    required this.options,
    required this.value,
    required this.onChanged,
    this.rangeHintOf,
  });

  final List<_Choice<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String? Function(T)? rangeHintOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          ChoiceCard(
            icon: options[i].icon,
            title: options[i].label,
            subtitle: options[i].sub,
            rangeHint: rangeHintOf?.call(options[i].value),
            selected: options[i].value == value,
            onTap: () => onChanged(options[i].value),
          )
              .animate()
              .fadeIn(duration: 220.ms, delay: (40 * i).ms)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 220.ms,
                delay: (40 * i).ms,
              ),
          if (i != options.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
