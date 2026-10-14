import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.footer,
    this.leading,
    this.actions = const [],
  });

  final String eyebrow;
  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.88;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.handle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    children: [
                      ?leading,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eyebrow, style: TextStyle(color: colors.muted, fontSize: 12)),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colors.text, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...actions,
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colors.text),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.line),
                Expanded(child: body),
                if (footer != null) ...[
                  Divider(height: 1, color: colors.line),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: footer,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final List<Color> colors;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed == null ? null : LinearGradient(colors: colors),
        color: onPressed == null ? palette.fill : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: onPressed == null ? palette.muted : palette.onAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
