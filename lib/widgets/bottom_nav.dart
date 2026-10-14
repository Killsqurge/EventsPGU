import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tab,
    required this.onTab,
    required this.controller,
    required this.onAdd,
  });

  final int tab;
  final ValueChanged<int> onTab;
  final AppController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.nav,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _item(context, 0, Icons.home_rounded, 'Главная', colors.indigo),
              if (controller.isAdmin)
                SizedBox(
                  width: 76,
                  child: InkWell(
                    onTap: onAdd,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            gradient: LinearGradient(colors: [colors.greenDeep, colors.green]),
                          ),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.add, color: colors.onAccent),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Добавить',
                          style: TextStyle(color: colors.faint, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              _item(context, 1, Icons.star_rounded, 'Избранное', colors.amber, badge: controller.favorites.length),
              _item(context, 2, Icons.person_rounded, 'Профиль', colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label, Color active, {int badge = 0}) {
    final selected = tab == index;
    final color = selected ? active : AppColors.of(context).faint;
    return Expanded(
      child: InkWell(
        onTap: () => onTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
