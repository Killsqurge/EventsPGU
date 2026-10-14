import 'package:flutter/material.dart';

import '../data/university_data.dart';
import '../models/academic_filter.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import 'sheet_scaffold.dart';

Future<void> showFilterSheet(BuildContext context, AppController controller) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FilterSheet(controller: controller),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller});

  final AppController controller;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late AcademicFilter _local;
  var _step = _Step.branch;

  @override
  void initState() {
    super.initState();
    _local = widget.controller.filter;
    if (_local.directionId != null) {
      _step = _Step.course;
    } else if (_local.departmentId != null) {
      _step = _Step.direction;
    } else if (_local.branchId != null) {
      _step = _Step.department;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final branch = UniversityData.branch(_local.branchId);
    final dept = UniversityData.department(_local.branchId, _local.departmentId);
    final dir = UniversityData.direction(_local.directionId);
    final crumb = [branch?.name, dept?.name, dir?.name].whereType<String>().join(' › ');

    return SheetScaffold(
      eyebrow: switch (_step) {
        _Step.branch => 'Филиал',
        _Step.department => 'Кафедра',
        _Step.direction => 'Направление',
        _Step.course => 'Курс',
      },
      title: crumb.isEmpty ? 'Фильтр' : crumb,
      leading: _step == _Step.branch
          ? null
          : IconButton(
              onPressed: _back,
              icon: Icon(Icons.chevron_left, color: colors.text),
            ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _local = AcademicFilter.empty;
            _step = _Step.branch;
          }),
          child: Text('Сброс', style: TextStyle(color: colors.muted)),
        ),
      ],
      body: switch (_step) {
        _Step.branch => _options(
            UniversityData.branches
                .map(
                  (item) => _Option(
                    title: '${item.name} филиал',
                    selected: _local.branchId == item.id,
                    onTap: () => setState(() {
                      _local = AcademicFilter(branchId: item.id);
                      _step = _Step.department;
                    }),
                  ),
                )
                .toList(),
          ),
        _Step.department => _options(
            (branch?.departments ?? [])
                .map(
                  (item) => _Option(
                    title: item.name,
                    selected: _local.departmentId == item.id,
                    onTap: () => setState(() {
                      _local = AcademicFilter(branchId: _local.branchId, departmentId: item.id);
                      _step = _Step.direction;
                    }),
                  ),
                )
                .toList(),
          ),
        _Step.direction => _options(
            (dept?.directions ?? [])
                .map(
                  (item) => _Option(
                    title: item.name,
                    selected: _local.directionId == item.id,
                    onTap: () => setState(() {
                      _local = AcademicFilter(
                        branchId: _local.branchId,
                        departmentId: _local.departmentId,
                        directionId: item.id,
                      );
                      _step = _Step.course;
                    }),
                  ),
                )
                .toList(),
          ),
        _Step.course => _options([
            _Option(
              title: 'Все курсы',
              selected: _local.course == null,
              showCheck: true,
              onTap: () => setState(() {
                _local = AcademicFilter(
                  branchId: _local.branchId,
                  departmentId: _local.departmentId,
                  directionId: _local.directionId,
                );
              }),
            ),
            ...(dir?.courses ?? []).map(
              (course) => _Option(
                title: '$course курс',
                selected: _local.course == course,
                showCheck: true,
                onTap: () => setState(() {
                  _local = AcademicFilter(
                    branchId: _local.branchId,
                    departmentId: _local.departmentId,
                    directionId: _local.directionId,
                    course: course,
                  );
                }),
              ),
            ),
          ]),
      },
      footer: GradientButton(
        label: 'Сохранить и показать',
        colors: [colors.indigoDeep, colors.indigo],
        onPressed: () async {
          await widget.controller.setFilter(_local);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _back() {
    setState(() {
      if (_step == _Step.department) {
        _local = AcademicFilter.empty;
        _step = _Step.branch;
      } else if (_step == _Step.direction) {
        _local = AcademicFilter(branchId: _local.branchId);
        _step = _Step.department;
      } else if (_step == _Step.course) {
        _local = AcademicFilter(branchId: _local.branchId, departmentId: _local.departmentId);
        _step = _Step.direction;
      }
    });
  }

  Widget _options(List<_Option> options) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      children: options,
    );
  }
}

enum _Step { branch, department, direction, course }

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.selected,
    required this.onTap,
    this.showCheck = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.indigoSoft : colors.fill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? colors.indigo : colors.line,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: TextStyle(color: colors.text, fontWeight: FontWeight.w600)),
                ),
                if (showCheck && selected)
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: colors.indigo,
                    child: Icon(Icons.check, size: 14, color: colors.onAccent),
                  )
                else if (!showCheck)
                  Icon(Icons.chevron_right, color: colors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
