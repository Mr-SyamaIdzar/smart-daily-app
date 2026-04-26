import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class DailyFocusMemoryMatchPage extends StatefulWidget {
  const DailyFocusMemoryMatchPage({super.key});

  @override
  State<DailyFocusMemoryMatchPage> createState() =>
      _DailyFocusMemoryMatchPageState();
}

class _DailyFocusMemoryMatchPageState extends State<DailyFocusMemoryMatchPage> {
  static const int _pairCount = 8; // 16 cards total (2x8)
  static const Duration _flipBackDelay = Duration(milliseconds: 650);

  final Random _rng = Random();

  late List<String> _deck; // length = _pairCount * 2
  final Set<int> _matched = <int>{};
  final Set<int> _faceUp = <int>{};

  int _moves = 0;
  Duration _elapsed = Duration.zero;

  Timer? _timer;
  bool _busy = false;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _newGame() {
    _timer?.cancel();
    _timer = null;

    final icons = <String>[
      '🧠',
      '🎯',
      '⚡',
      '📌',
      '📚',
      '⏳',
      '🧘',
      '✅',
      '🧩',
      '🌿',
      '📝',
      '🔔',
    ];
    icons.shuffle(_rng);
    final selected = icons.take(_pairCount).toList(growable: false);
    _deck = [...selected, ...selected]..shuffle(_rng);

    setState(() {
      _matched.clear();
      _faceUp.clear();
      _moves = 0;
      _elapsed = Duration.zero;
      _busy = false;
      _timerStarted = false;
    });
  }

  void _startTimerIfNeeded() {
    if (_timerStarted) return;
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _onTapCard(int index) async {
    if (_busy) return;
    if (_matched.contains(index)) return;
    if (_faceUp.contains(index)) return;

    _startTimerIfNeeded();

    setState(() {
      _faceUp.add(index);
    });

    if (_faceUp.length % 2 == 1) return; // wait for the second card

    final faceUpList = _faceUp.toList(growable: false);
    final a = faceUpList[faceUpList.length - 2];
    final b = faceUpList[faceUpList.length - 1];

    setState(() {
      _moves += 1;
    });

    final isMatch = _deck[a] == _deck[b];
    if (isMatch) {
      setState(() {
        _matched.addAll([a, b]);
      });
      if (_matched.length == _deck.length) {
        _timer?.cancel();
        _timer = null;
        if (!mounted) return;
        await _showWinDialog();
      }
      return;
    }

    _busy = true;
    await Future<void>.delayed(_flipBackDelay);
    if (!mounted) return;
    setState(() {
      _faceUp.remove(a);
      _faceUp.remove(b);
    });
    _busy = false;
  }

  Future<void> _showWinDialog() async {
    final time = _formatDuration(_elapsed);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesai!'),
        content: Text('Waktu: $time\nMoves: $_moves'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child: const Text('Main lagi'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatDuration(_elapsed);
    final matchedPairs = (_matched.length / 2).floor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Focus — Memory Match'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _newGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              _HeaderStats(
                time: time,
                moves: _moves,
                matchedPairs: matchedPairs,
                totalPairs: _pairCount,
              ),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 420 ? 4 : 6;
                    final spacing = AppSizes.sm;
                    final totalSpacing = spacing * (crossAxisCount - 1);
                    final tileSize =
                        (constraints.maxWidth - totalSpacing) / crossAxisCount;
                    final aspect = tileSize / max(tileSize, 72);

                    return GridView.builder(
                      itemCount: _deck.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: aspect,
                      ),
                      itemBuilder: (context, i) {
                        final isMatched = _matched.contains(i);
                        final isFaceUp = _faceUp.contains(i) || isMatched;
                        return _MemoryCard(
                          label: _deck[i],
                          isFaceUp: isFaceUp,
                          isMatched: isMatched,
                          onTap: () => _onTapCard(i),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Tip: main 1–2 menit saja untuk “warm up” fokus harian.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  const _HeaderStats({
    required this.time,
    required this.moves,
    required this.matchedPairs,
    required this.totalPairs,
  });

  final String time;
  final int moves;
  final int matchedPairs;
  final int totalPairs;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Expanded(
              child: _StatTile(
                title: 'Waktu',
                value: time,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _StatTile(
                title: 'Moves',
                value: moves.toString(),
                icon: Icons.touch_app_outlined,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _StatTile(
                title: 'Pair',
                value: '$matchedPairs/$totalPairs',
                icon: Icons.grid_view_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.label,
    required this.isFaceUp,
    required this.isMatched,
    required this.onTap,
  });

  final String label;
  final bool isFaceUp;
  final bool isMatched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final faceColor = isMatched
        ? AppColors.success.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.10);
    final backColor = AppColors.surfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isFaceUp ? faceColor : backColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isFaceUp ? AppColors.primary : AppColors.border,
              width: isMatched ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isFaceUp
                ? Text(
                    label,
                    key: ValueKey('face_$label'),
                    style: const TextStyle(fontSize: 28),
                  )
                : Icon(
                    Icons.blur_on_rounded,
                    key: const ValueKey('back'),
                    color: AppColors.textHint,
                  ),
          ),
        ),
      ),
    );
  }
}

