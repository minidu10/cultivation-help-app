import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';

/// The signed-in frame: four tabs in a bottom bar with the crop-doctor
/// camera in a notch at the centre, where a thumb reaches it first.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      extendBody: true,
      body: shell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'scan',
        tooltip: l10n.navScan,
        shape: const CircleBorder(),
        onPressed: () => showScanComingSoon(context),
        child: const Icon(Icons.photo_camera_outlined),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: l10n.navHome, selected: shell.currentIndex == 0, onTap: () => _go(0)),
            _NavItem(icon: Icons.grass_outlined, selectedIcon: Icons.grass, label: l10n.navCrops, selected: shell.currentIndex == 1, onTap: () => _go(1)),
            const SizedBox(width: 72),
            _NavItem(icon: Icons.support_agent_outlined, selectedIcon: Icons.support_agent, label: l10n.navAdvisor, selected: shell.currentIndex == 2, onTap: () => _go(2)),
            _NavItem(icon: Icons.menu, selectedIcon: Icons.menu_open, label: l10n.navMore, selected: shell.currentIndex == 3, onTap: () => _go(3)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder until photo diagnosis lands: says what is coming instead of
/// a dead button.
Future<void> showScanComingSoon(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.biotech_outlined, size: 32),
          ),
          const SizedBox(height: 16),
          Text(l10n.scanComingTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.scanComingBody, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.tonal(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    ),
  );
}
