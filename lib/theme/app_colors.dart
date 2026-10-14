import 'package:flutter/material.dart';

import '../models/event_item.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.card,
    required this.nav,
    required this.text,
    required this.muted,
    required this.faint,
    required this.meta,
    required this.line,
    required this.fill,
    required this.handle,
    required this.indigo,
    required this.indigoDeep,
    required this.indigoSoft,
    required this.chipText,
    required this.amber,
    required this.green,
    required this.greenDeep,
    required this.danger,
    required this.dangerBorder,
    required this.onAccent,
    required this.dropdown,
    required this.joined,
    required this.googleButton,
    required this.googleButtonText,
  });

  final Brightness brightness;
  final Color bg;
  final Color card;
  final Color nav;
  final Color text;
  final Color muted;
  final Color faint;
  final Color meta;
  final Color line;
  final Color fill;
  final Color handle;
  final Color indigo;
  final Color indigoDeep;
  final Color indigoSoft;
  final Color chipText;
  final Color amber;
  final Color green;
  final Color greenDeep;
  final Color danger;
  final Color dangerBorder;
  final Color onAccent;
  final Color dropdown;
  final Color joined;
  final Color googleButton;
  final Color googleButtonText;

  bool get isLight => brightness == Brightness.light;

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0F1117),
    card: Color(0xFF181C2E),
    nav: Color(0xFF13172A),
    text: Color(0xFFF0F2F8),
    muted: Color(0xFF6B7280),
    faint: Color(0xFF4B5563),
    meta: Color(0xFF9CA3AF),
    line: Color(0x14FFFFFF),
    fill: Color(0x0DFFFFFF),
    handle: Color(0x26FFFFFF),
    indigo: Color(0xFF818CF8),
    indigoDeep: Color(0xFF6366F1),
    indigoSoft: Color(0x2E818CF8),
    chipText: Color(0xFFA5B4FC),
    amber: Color(0xFFF59E0B),
    green: Color(0xFF34D399),
    greenDeep: Color(0xFF10B981),
    danger: Color(0xFFF87171),
    dangerBorder: Color(0x55F87171),
    onAccent: Color(0xFFFFFFFF),
    dropdown: Color(0xFF22263A),
    joined: Color(0xFF14532D),
    googleButton: Color(0xFFFFFFFF),
    googleButtonText: Color(0xFF111827),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF3F5FB),
    card: Color(0xFFFFFFFF),
    nav: Color(0xFFFFFFFF),
    text: Color(0xFF111827),
    muted: Color(0xFF6B7280),
    faint: Color(0xFF9CA3AF),
    meta: Color(0xFF6B7280),
    line: Color(0x140F172A),
    fill: Color(0x0A111827),
    handle: Color(0x33111827),
    indigo: Color(0xFF4F46E5),
    indigoDeep: Color(0xFF4338CA),
    indigoSoft: Color(0x1F4F46E5),
    chipText: Color(0xFF4338CA),
    amber: Color(0xFFD97706),
    green: Color(0xFF059669),
    greenDeep: Color(0xFF047857),
    danger: Color(0xFFDC2626),
    dangerBorder: Color(0x55DC2626),
    onAccent: Color(0xFFFFFFFF),
    dropdown: Color(0xFFFFFFFF),
    joined: Color(0xFF047857),
    googleButton: Color(0xFF111827),
    googleButtonText: Color(0xFFFFFFFF),
  );

  TypeStyle typeStyle(EventType type) {
    if (isLight) {
      return switch (type) {
        EventType.conference => const TypeStyle(color: Color(0xFF2563EB), background: Color(0x1F2563EB), label: 'Конференция'),
        EventType.olympiad => const TypeStyle(color: Color(0xFFD97706), background: Color(0x1FD97706), label: 'Олимпиада'),
        EventType.seminar => const TypeStyle(color: Color(0xFF059669), background: Color(0x1F059669), label: 'Семинар'),
        EventType.workshop => const TypeStyle(color: Color(0xFF7C3AED), background: Color(0x1F7C3AED), label: 'Воркшоп'),
        EventType.cultural => const TypeStyle(color: Color(0xFFDB2777), background: Color(0x1FDB2777), label: 'Культура'),
      };
    }
    return switch (type) {
      EventType.conference => const TypeStyle(color: Color(0xFF60A5FA), background: Color(0x1F60A5FA), label: 'Конференция'),
      EventType.olympiad => const TypeStyle(color: Color(0xFFF59E0B), background: Color(0x1FF59E0B), label: 'Олимпиада'),
      EventType.seminar => const TypeStyle(color: Color(0xFF34D399), background: Color(0x1F34D399), label: 'Семинар'),
      EventType.workshop => const TypeStyle(color: Color(0xFFA78BFA), background: Color(0x1FA78BFA), label: 'Воркшоп'),
      EventType.cultural => const TypeStyle(color: Color(0xFFF472B6), background: Color(0x1FF472B6), label: 'Культура'),
    };
  }

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? bg,
    Color? card,
    Color? nav,
    Color? text,
    Color? muted,
    Color? faint,
    Color? meta,
    Color? line,
    Color? fill,
    Color? handle,
    Color? indigo,
    Color? indigoDeep,
    Color? indigoSoft,
    Color? chipText,
    Color? amber,
    Color? green,
    Color? greenDeep,
    Color? danger,
    Color? dangerBorder,
    Color? onAccent,
    Color? dropdown,
    Color? joined,
    Color? googleButton,
    Color? googleButtonText,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      card: card ?? this.card,
      nav: nav ?? this.nav,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      meta: meta ?? this.meta,
      line: line ?? this.line,
      fill: fill ?? this.fill,
      handle: handle ?? this.handle,
      indigo: indigo ?? this.indigo,
      indigoDeep: indigoDeep ?? this.indigoDeep,
      indigoSoft: indigoSoft ?? this.indigoSoft,
      chipText: chipText ?? this.chipText,
      amber: amber ?? this.amber,
      green: green ?? this.green,
      greenDeep: greenDeep ?? this.greenDeep,
      danger: danger ?? this.danger,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      onAccent: onAccent ?? this.onAccent,
      dropdown: dropdown ?? this.dropdown,
      joined: joined ?? this.joined,
      googleButton: googleButton ?? this.googleButton,
      googleButtonText: googleButtonText ?? this.googleButtonText,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    if (t < 0.5) return this;
    return other;
  }
}

class TypeStyle {
  const TypeStyle({required this.color, required this.background, required this.label});

  final Color color;
  final Color background;
  final String label;
}

abstract final class AppColors {
  static AppPalette of(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>();
    return palette ?? AppPalette.dark;
  }
}
