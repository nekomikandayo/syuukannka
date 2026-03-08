import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_model.dart';
import '../providers/habits_provider.dart';

/// 新しい習慣を登録する画面。
class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController(text: '10');

  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final minutes = int.tryParse(_minutesController.text.trim());
    if (minutes == null || minutes <= 0) {
      return;
    }

    final habit = Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      currentStreak: 0,
      reminderTime: ReminderTime(hour: _reminderTime.hour, minute: _reminderTime.minute),
      lastCompletedDate: null,
      targetDurationSeconds: minutes * 60,
    );

    ref.read(habitsProvider.notifier).addHabit(habit);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('習慣を追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '習慣名',
                hintText: '例：読書、プログラミング学習',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '習慣名を入力してください';
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _minutesController,
              decoration: const InputDecoration(
                labelText: '目標時間（分）',
                hintText: '例：10',
                border: OutlineInputBorder(),
                suffixText: '分',
              ),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '目標時間を入力してください';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return '1以上の分数を入力してください';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('リマインド時刻'),
              subtitle: Text(
                '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.schedule),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: _pickReminderTime,
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
