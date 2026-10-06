import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/daily.dart';
import '../core/puzzle.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../help/help_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../stats/stats_view.dart';
import 'game_controller.dart';
import 'widgets/chain_row.dart';
import 'widgets/game_over_panel.dart';
import 'widgets/tile_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.storage, required this.clock});

  final Storage storage;
  final Clock clock;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final GameController _controller = GameController(
    storage: widget.storage,
    clock: widget.clock,
  );
  final ScrollController _scroll = ScrollController();
  Timer? _midnightTimer;

  /// Tentativo di cui si sta animando la catena. Intanto l'input è bloccato e
  /// la fine partita non viene ancora mostrata.
  int? _revealing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
    if (!widget.storage.loadSettings().helpSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openHelp());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshDay();
  }

  /// Ricontrolla la data poco dopo la mezzanotte, se l'app è aperta.
  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final Duration wait =
        timeUntilNextPuzzle(widget.clock.now()) + const Duration(seconds: 1);
    _midnightTimer = Timer(wait, () {
      _refreshDay();
      _scheduleMidnight();
    });
  }

  void _refreshDay() {
    if (!_controller.refreshDay()) return;
    setState(() => _revealing = null);
    _scheduleMidnight();
  }

  Future<void> _openHelp() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HelpScreen()));
    final Settings settings = widget.storage.loadSettings();
    if (!settings.helpSeen) {
      await widget.storage.saveSettings(settings.copyWith(helpSeen: true));
    }
  }

  void _openStats() {
    unawaited(
      showStatsSheet(
        context,
        stats: _controller.stats,
        currentStreak: _controller.currentStreak,
        highlightAttempts: _controller.status == GameStatus.won
            ? _controller.attempts.length
            : null,
      ),
    );
  }

  void _share() {
    unawaited(
      SharePlus.instance.share(ShareParams(text: _controller.shareText)),
    );
  }

  void _submit() {
    if (_controller.submit() == null) return;
    setState(() => _revealing = _controller.attempts.length - 1);
    _scrollToEnd();
  }

  void _onRevealed() {
    setState(() => _revealing = null);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final bool showInput = !_controller.isOver || _revealing != null;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.puzzleTitle(_controller.daily.number)),
            centerTitle: true,
            leading: IconButton(
              key: const ValueKey('open-help'),
              tooltip: l10n.helpTooltip,
              icon: const Icon(Icons.help_outline),
              onPressed: _openHelp,
            ),
            actions: [
              IconButton(
                key: const ValueKey('open-stats'),
                tooltip: l10n.statsTooltip,
                icon: const Icon(Icons.bar_chart),
                onPressed: _openStats,
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _Header(controller: _controller),
                  const Divider(height: 1),
                  Expanded(child: _history(context, l10n)),
                  if (showInput) ...[
                    const Divider(height: 1),
                    _InputArea(
                      controller: _controller,
                      enabled: _revealing == null,
                      onSubmit: _submit,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _history(BuildContext context, AppLocalizations l10n) {
    final List<Attempt> attempts = _controller.attempts;
    final bool showGameOver = _controller.isOver && _revealing == null;
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (attempts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.historyHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        for (int i = 0; i < attempts.length; i++)
          if (i == _revealing)
            AnimatedChainRow(
              key: ValueKey('attempt-$i'),
              tiles: _controller.puzzle.tilesInOrder(attempts[i].order),
              result: attempts[i].result,
              outcome: attempts[i].outcome,
              number: i + 1,
              onRevealed: _onRevealed,
            )
          else
            ChainRow(
              key: ValueKey('attempt-$i'),
              tiles: _controller.puzzle.tilesInOrder(attempts[i].order),
              result: attempts[i].result,
              outcome: attempts[i].outcome,
              number: i + 1,
            ),
        if (showGameOver)
          GameOverPanel(
            controller: _controller,
            clock: widget.clock,
            onShare: _share,
          ),
      ],
    );
  }
}

/// Partenza e obiettivo, ben visibili.
class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Puzzle puzzle = controller.puzzle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _NumberCard(label: l10n.startLabel, value: puzzle.start),
          ),
          const ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward),
            ),
          ),
          Expanded(
            child: _NumberCard(
              label: l10n.targetLabel,
              value: puzzle.target,
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight
              ? colors.tertiaryContainer
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$value',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? colors.onTertiaryContainer : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slot, tessere disponibili e pulsanti.
class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final GameController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Puzzle puzzle = controller.puzzle;
    final List<int?> slots = controller.slots;
    // Durante l'animazione si resta sul tentativo appena verificato.
    final int done = controller.attempts.length;
    final int current = (enabled ? done + 1 : done).clamp(1, maxAttempts);
    final bool warnDuplicate = enabled && controller.isDuplicate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            warnDuplicate
                ? l10n.alreadyTried
                : l10n.attemptCounter(current, maxAttempts),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: warnDuplicate ? theme.colorScheme.error : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _spacedRow([
            for (int s = 0; s < slots.length; s++)
              SlotButton(
                key: ValueKey('slot-$s'),
                index: s,
                operation: slots[s] == null ? null : puzzle.tiles[slots[s]!],
                onTap: enabled ? () => controller.clearSlot(s) : null,
              ),
          ]),
          const SizedBox(height: 16),
          _spacedRow([
            for (int t = 0; t < puzzle.tiles.length; t++)
              TileButton(
                key: ValueKey('tile-$t'),
                operation: puzzle.tiles[t],
                used: controller.isTileUsed(t),
                onTap: enabled ? () => controller.placeTile(t) : null,
              ),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('clear'),
                  onPressed: enabled && !controller.slotsEmpty
                      ? controller.clearSlots
                      : null,
                  child: Text(l10n.clearButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const ValueKey('check'),
                  onPressed: enabled && controller.canSubmit ? onSubmit : null,
                  child: Text(l10n.checkButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Su schermi stretti le caselle si riducono invece di uscire dai bordi.
  Widget _spacedRow(List<Widget> children) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}
