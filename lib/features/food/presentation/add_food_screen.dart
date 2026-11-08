import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/food_entry.dart';
import '../providers/food_log_provider.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _calories = TextEditingController();
  final TextEditingController _protein = TextEditingController();
  final TextEditingController _carbs = TextEditingController();
  final TextEditingController _fat = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: s.back,
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(s.addFood),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: <Widget>[
              Text(s.manualEntryTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 7),
              Text(s.manualEntryDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      )),
              const SizedBox(height: 24),
              _FieldLabel(text: s.foodName),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: s.foodNameHint),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty ? s.requiredField : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel(text: s.caloriesKcal),
              const SizedBox(height: 8),
              TextFormField(
                controller: _calories,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: '0'),
                validator: (String? value) {
                  final int? parsed = int.tryParse(value ?? '');
                  return parsed == null || parsed < 0 ? s.enterValidNumber : null;
                },
              ),
              const SizedBox(height: 20),
              Text(s.macrosOptional,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(child: _MacroField(controller: _protein, label: s.protein)),
                  const SizedBox(width: 9),
                  Expanded(child: _MacroField(controller: _carbs, label: s.carbs)),
                  const SizedBox(width: 9),
                  Expanded(child: _MacroField(controller: _fat, label: s.fat)),
                ],
              ),
              const SizedBox(height: 12),
              Text(s.nutrientsMayBeUnknown,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      )),
              const SizedBox(height: 28),
              FilledButton(onPressed: _save, child: Text(s.saveFood)),
            ],
          ),
        ),
      ),
    );
  }

  double? _optionalValue(TextEditingController controller) {
    if (controller.text.trim().isEmpty) return null;
    return double.tryParse(controller.text.trim());
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(foodLogProvider.notifier).add(
          FoodEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: _name.text.trim(),
            caloriesKcal: int.parse(_calories.text.trim()),
            proteinGrams: _optionalValue(_protein),
            carbsGrams: _optionalValue(_carbs),
            fatGrams: _optionalValue(_fat),
            loggedAt: DateTime.now(),
          ),
        );
    if (mounted) context.pop();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      );
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '—'),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) return null;
            final double? parsed = double.tryParse(value);
            return parsed == null || parsed < 0 ? s.enterValidNumber : null;
          },
        ),
      ],
    );
  }
}
