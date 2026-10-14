import 'package:flutter/material.dart';

import '../data/university_data.dart';
import '../models/event_item.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'sheet_scaffold.dart';

Future<void> showAddEventSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddEventSheet(controller: controller),
  );
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet({required this.controller});

  final AppController controller;

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  var _type = EventType.seminar;
  String? _branchId;
  String? _departmentId;
  String? _directionId;
  int? _course;
  DateTime? _start;
  DateTime? _end;
  var _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _title.text.trim().isNotEmpty &&
      _start != null &&
      _end != null &&
      _end!.isAfter(_start!) &&
      _branchId != null &&
      _directionId != null &&
      _course != null &&
      !_saving;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final branch = UniversityData.branch(_branchId);
    final dept = UniversityData.department(_branchId, _departmentId);
    final direction = dept?.directions.where((item) => item.id == _directionId).firstOrNull;

    return SheetScaffold(
      eyebrow: 'Новое мероприятие',
      title: 'Добавить мероприятие',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          _field('Название', _title, 'Введите название'),
          _field('Описание', _description, 'Краткое описание', maxLines: 3),
          _dateTile('Начало', _start, (value) => setState(() => _start = value)),
          _dateTile('Окончание', _end, (value) => setState(() => _end = value)),
          if (_start != null && _end != null && !_end!.isAfter(_start!))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Окончание должно быть позже начала', style: TextStyle(color: colors.danger, fontSize: 12)),
            ),
          _field('Место проведения', _location, 'Аудитория / корпус'),
          _label('Тип'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventType.values.map((type) {
              final style = colors.typeStyle(type);
              final selected = _type == type;
              return ChoiceChip(
                label: Text(style.label),
                selected: selected,
                selectedColor: style.background,
                backgroundColor: colors.fill,
                labelStyle: TextStyle(color: selected ? style.color : colors.muted, fontWeight: FontWeight.w600),
                side: BorderSide(color: selected ? style.color : colors.line),
                onSelected: (_) => setState(() => _type = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _dropdown<String>(
            label: 'Филиал',
            value: _branchId,
            hint: 'Выберите филиал',
            items: UniversityData.branches.map((item) => DropdownMenuItem(value: item.id, child: Text('${item.name} филиал'))).toList(),
            onChanged: (value) => setState(() {
              _branchId = value;
              _departmentId = null;
              _directionId = null;
              _course = null;
            }),
          ),
          if (branch != null)
            _dropdown<String>(
              label: 'Кафедра',
              value: _departmentId,
              hint: 'Выберите кафедру',
              items: branch.departments.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))).toList(),
              onChanged: (value) => setState(() {
                _departmentId = value;
                _directionId = null;
                _course = null;
              }),
            ),
          if (dept != null)
            _dropdown<String>(
              label: 'Направление',
              value: _directionId,
              hint: 'Выберите направление',
              items: dept.directions.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))).toList(),
              onChanged: (value) => setState(() {
                _directionId = value;
                _course = null;
              }),
            ),
          if (direction != null)
            _dropdown<int>(
              label: 'Курс',
              value: _course,
              hint: 'Выберите курс',
              items: direction.courses.map((item) => DropdownMenuItem(value: item, child: Text('$item курс'))).toList(),
              onChanged: (value) => setState(() => _course = value),
            ),
        ],
      ),
      footer: GradientButton(
        label: _saving ? 'Сохранение…' : 'Добавить мероприятие',
        colors: [colors.greenDeep, colors.green],
        onPressed: _canSave ? _submit : null,
      ),
    );
  }

  Future<void> _submit() async {
    final start = _start;
    final end = _end;
    final branchId = _branchId;
    final directionId = _directionId;
    final course = _course;
    if (start == null || end == null || branchId == null || directionId == null || course == null) return;
    setState(() => _saving = true);
    final event = EventItem(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      start: start,
      end: end,
      location: _location.text.trim(),
      type: _type,
      directionId: directionId,
      course: course,
      branchId: branchId,
    );
    final error = await widget.controller.addEvent(event);
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: colors.text),
            decoration: _decoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime? value, ValueChanged<DateTime> onPick) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          Material(
            color: colors.fill,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final picked = await _pickDateTime(context, value);
                if (picked != null) onPick(picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.line),
                ),
                child: Text(
                  value == null ? 'Дата и время' : '${formatDay(value)} · ${formatTime(value)}',
                  style: TextStyle(color: value == null ? colors.muted : colors.text),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          DropdownButtonFormField<T>(
            key: ValueKey('$label-$value'),
            initialValue: value,
            isExpanded: true,
            hint: Text(hint, style: TextStyle(color: colors.muted)),
            dropdownColor: colors.dropdown,
            style: TextStyle(color: colors.text, fontSize: 14),
            decoration: _decoration(hint),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    final colors = AppColors.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.faint),
      filled: true,
      fillColor: colors.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.line),
      ),
    );
  }
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
  final now = DateTime.now();
  final base = initial ?? now;
  final date = await showDatePicker(
    context: context,
    initialDate: base,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 3),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(base),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
