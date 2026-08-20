import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _category = TextEditingController();
  String _conditionType = 'arrive';
  double _radius = 100;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await context.read<ReminderProvider>().addReminder(
          title: _title.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          category: _category.text.trim().isEmpty ? null : _category.text.trim(),
          conditionType: _conditionType,
          radiusMeters: _radius,
          // NOTE: latitude/longitude wiring goes here once a place is picked
          // on the map screen. See map_screen.dart / location_service.dart.
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New reminder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Give it a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Category (optional)', hintText: 'e.g. errand, work, personal'),
                ),
                const SizedBox(height: 20),
                const Text('Trigger when I', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(label: const Text('Arrive'), selected: _conditionType == 'arrive', onSelected: (_) => setState(() => _conditionType = 'arrive')),
                    ChoiceChip(label: const Text('Leave'), selected: _conditionType == 'leave', onSelected: (_) => setState(() => _conditionType = 'leave')),
                    ChoiceChip(label: const Text('Time'), selected: _conditionType == 'time', onSelected: (_) => setState(() => _conditionType = 'time')),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Trigger radius: ${_radius.round()} m', style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: _radius,
                  min: 25,
                  max: 500,
                  divisions: 19,
                  label: '${_radius.round()} m',
                  onChanged: (v) => setState(() => _radius = v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save reminder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
