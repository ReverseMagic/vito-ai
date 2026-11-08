import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(s.activity)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: <Widget>[
          Text(s.activityTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          Text(s.activityDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  )),
          const SizedBox(height: 20),
          _Metric(icon: Icons.directions_walk_outlined, label: s.steps, detail: s.noActivityData),
          const SizedBox(height: 12),
          _Metric(icon: Icons.local_fire_department_outlined, label: s.burnedCalories, detail: s.noActivityData),
          const SizedBox(height: 12),
          _Metric(icon: Icons.fitness_center_outlined, label: s.workouts, detail: s.noWorkoutsYet),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.detail});

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 23),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(detail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            )),
                  ],
                ),
              ),
              const Text('—'),
            ],
          ),
        ),
      );
}
