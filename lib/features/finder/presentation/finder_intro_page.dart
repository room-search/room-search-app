import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FinderIntroPage extends ConsumerWidget {
  const FinderIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('딱맞는 테마 찾기')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '취향에 꼭 맞는\n테마를 찾아드릴게요',
              style: text.headlineLarge,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            Text(
              '모드를 골라 시작해 보세요.',
              style: text.bodyMedium,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
            const SizedBox(height: 28),
            Expanded(
              child: _ModeCard(
                title: '위자드',
                subtitle: '질문 하나씩 답하며\n내 취향을 발견해요',
                icon: Icons.auto_awesome_rounded,
                onTap: () => context.push('/finder/wizard'),
                gradient: const [Color(0xFF7C5CFF), Color(0xFFA89AFF)],
              ).animate().fadeIn(duration: 350.ms, delay: 160.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 320.ms,
                    delay: 160.ms,
                  ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _ModeCard(
                title: '대시보드',
                subtitle: '모든 필터를 한 화면에서\n실시간 매칭을 확인해요',
                icon: Icons.tune_rounded,
                onTap: () => context.push('/finder/dashboard'),
                gradient: const [Color(0xFFFFB4A2), Color(0xFFFFB547)],
              ).animate().fadeIn(duration: 350.ms, delay: 240.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 320.ms,
                    delay: 240.ms,
                  ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _ModeCard(
                title: '함께 찾기',
                subtitle: '같은 Wi-Fi의 친구와\n방을 만들어 테마를 공유해요',
                icon: Icons.group_rounded,
                onTap: () => context.push('/finder/room'),
                gradient: const [Color(0xFF16C5A1), Color(0xFF40A3F0)],
              ).animate().fadeIn(duration: 350.ms, delay: 320.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 320.ms,
                    delay: 320.ms,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: text.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
