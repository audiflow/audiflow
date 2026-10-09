import 'package:flutter/material.dart';

import '../styles/borders.dart';
import 'app_colors.dart';
import 'color_scheme.dart';
import 'text_styles.dart';

/// Application theme configuration.
///
/// Builds the light and dark themes from [AppColors] tokens and the
/// matching [AppColorScheme]. Component theming is centralized here so
/// stock Material widgets follow the redesign (warm neutral ground,
/// white surfaces, one accent) without per-screen overrides.
class AppTheme {
  AppTheme._();

  /// Light theme.
  static ThemeData light() => _build(AppColorScheme.light(), AppColors.light);

  /// Dark theme.
  static ThemeData dark() => _build(AppColorScheme.dark(), AppColors.dark);

  static ThemeData _build(ColorScheme scheme, AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [colors],
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: colors.ink,
        displayColor: colors.ink,
      ),
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      dividerColor: colors.hairline,
      appBarTheme: _appBar(colors),
      cardTheme: _card(colors),
      listTileTheme: _listTile(colors),
      bottomSheetTheme: _bottomSheet(colors),
      dialogTheme: _dialog(colors),
      popupMenuTheme: _popupMenu(colors),
      snackBarTheme: _snackBar(scheme, colors),
      inputDecorationTheme: _inputDecoration(colors),
      elevatedButtonTheme: _elevatedButton(colors),
      filledButtonTheme: _filledButton(colors),
      textButtonTheme: _textButton(colors),
      outlinedButtonTheme: _outlinedButton(colors),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: _navigationBar(colors),
      navigationRailTheme: _navigationRail(colors),
      tabBarTheme: _tabBar(colors),
      segmentedButtonTheme: _segmentedButton(colors),
      chipTheme: _chip(colors),
      switchTheme: _switch(colors),
      sliderTheme: _slider(colors),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.progressTrack,
        circularTrackColor: colors.progressTrack,
      ),
      checkboxTheme: _checkbox(colors),
      radioTheme: RadioThemeData(
        fillColor: _selected(colors.accent, colors.inkTertiary),
      ),
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        space: 1,
        thickness: 1,
      ),
    );
  }

  /// Resolves to [selected] when the widget is selected, else [other].
  static WidgetStateProperty<T> _selected<T>(T selected, T other) {
    return WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? selected : other,
    );
  }

  static AppBarTheme _appBar(AppColors colors) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.bg,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.rowTitle.copyWith(
        fontSize: 17,
        color: colors.ink,
      ),
    );
  }

  static CardThemeData _card(AppColors colors) {
    // Elevation 1 with a near-transparent shadow approximates the
    // spec's `0 1px 2px` at 5%; Card cannot take a BoxShadow list.
    return CardThemeData(
      color: colors.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.groupedSurface,
      ),
    );
  }

  static ListTileThemeData _listTile(AppColors colors) {
    return ListTileThemeData(
      iconColor: colors.inkSecondary,
      textColor: colors.ink,
      titleTextStyle: AppTextStyles.body.copyWith(color: colors.ink),
      subtitleTextStyle: AppTextStyles.meta.copyWith(
        color: colors.inkSecondary,
      ),
      minVerticalPadding: 12,
    );
  }

  static BottomSheetThemeData _bottomSheet(AppColors colors) {
    return BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.sheet),
    );
  }

  static DialogThemeData _dialog(AppColors colors) {
    return DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.xl),
      titleTextStyle: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
      contentTextStyle: AppTextStyles.body.copyWith(color: colors.inkSecondary),
    );
  }

  static PopupMenuThemeData _popupMenu(AppColors colors) {
    return PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.lg),
      textStyle: AppTextStyles.body.copyWith(color: colors.ink),
    );
  }

  static SnackBarThemeData _snackBar(ColorScheme scheme, AppColors colors) {
    // Light mode inverts to an ink fill, so the action takes the opposite
    // mode's accent. Dark mode raises a sunken surface instead: the light
    // accent on a light ink fill misses 4.5:1, and a bright block on a dark
    // screen is glaring. `brand` is never text.
    final isDark = scheme.brightness == Brightness.dark;
    return SnackBarThemeData(
      backgroundColor: isDark ? colors.surfaceSunken : colors.ink,
      contentTextStyle: AppTextStyles.body.copyWith(
        color: isDark ? colors.ink : colors.bg,
      ),
      actionTextColor: isDark ? colors.accent : scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
    );
  }

  static InputDecorationThemeData _inputDecoration(AppColors colors) {
    const noBorder = OutlineInputBorder(
      borderRadius: AppBorders.md,
      borderSide: BorderSide.none,
    );
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceSunken,
      hintStyle: AppTextStyles.body.copyWith(color: colors.inkTertiary),
      prefixIconColor: colors.inkTertiary,
      suffixIconColor: colors.inkTertiary,
      border: noBorder,
      enabledBorder: noBorder,
      focusedBorder: noBorder.copyWith(
        borderSide: BorderSide(color: colors.accent, width: 1.5),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButton(AppColors colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 0,
        textStyle: AppTextStyles.label,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const StadiumBorder(),
      ),
    );
  }

  static FilledButtonThemeData _filledButton(AppColors colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        textStyle: AppTextStyles.label,
        shape: const StadiumBorder(),
      ),
    );
  }

  static TextButtonThemeData _textButton(AppColors colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.accent,
        textStyle: AppTextStyles.label,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(AppColors colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        textStyle: AppTextStyles.label,
        side: BorderSide(color: colors.outline),
        shape: const StadiumBorder(),
      ),
    );
  }

  static NavigationBarThemeData _navigationBar(AppColors colors) {
    return NavigationBarThemeData(
      backgroundColor: colors.bg,
      indicatorColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return AppTextStyles.caption.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? colors.accent : colors.inkTertiary,
        );
      }),
      iconTheme: _selected(
        IconThemeData(color: colors.accent),
        IconThemeData(color: colors.inkTertiary),
      ),
    );
  }

  static NavigationRailThemeData _navigationRail(AppColors colors) {
    return NavigationRailThemeData(
      backgroundColor: colors.bg,
      indicatorColor: Colors.transparent,
      selectedIconTheme: IconThemeData(color: colors.accent),
      unselectedIconTheme: IconThemeData(color: colors.inkTertiary),
      selectedLabelTextStyle: AppTextStyles.caption.copyWith(
        color: colors.accent,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: AppTextStyles.caption.copyWith(
        color: colors.inkTertiary,
      ),
    );
  }

  static TabBarThemeData _tabBar(AppColors colors) {
    return TabBarThemeData(
      labelColor: colors.accent,
      unselectedLabelColor: colors.inkTertiary,
      labelStyle: AppTextStyles.label,
      unselectedLabelStyle: AppTextStyles.label.copyWith(
        fontWeight: FontWeight.w500,
      ),
      indicatorColor: colors.accent,
      dividerColor: colors.hairline,
    );
  }

  static SegmentedButtonThemeData _segmentedButton(AppColors colors) {
    // Segmented controls sit on a sunken track; the selected segment is
    // raised onto a white surface rather than tinted.
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: _selected(colors.surface, colors.surfaceSunken),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colors.ink
              : colors.inkSecondary;
          // Without this a disabled control looks fully interactive; 0.38
          // is Material's disabled-content opacity.
          return states.contains(WidgetState.disabled)
              ? color.withValues(alpha: 0.38)
              : color;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: colors.surfaceSunken)),
        textStyle: const WidgetStatePropertyAll(AppTextStyles.label),
      ),
    );
  }

  static ChipThemeData _chip(AppColors colors) {
    return ChipThemeData(
      backgroundColor: colors.surface,
      selectedColor: colors.accentTint,
      labelStyle: AppTextStyles.caption.copyWith(
        color: colors.ink,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: AppTextStyles.caption.copyWith(
        color: colors.accent,
        fontWeight: FontWeight.w600,
      ),
      side: WidgetStateBorderSide.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return BorderSide(color: isSelected ? colors.accent : colors.outline);
      }),
      shape: const StadiumBorder(),
      checkmarkColor: colors.accent,
    );
  }

  static SwitchThemeData _switch(AppColors colors) {
    return SwitchThemeData(
      thumbColor: _selected(colors.onAccent, colors.surface),
      trackColor: _selected(colors.accent, colors.outline),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  static SliderThemeData _slider(AppColors colors) {
    return SliderThemeData(
      activeTrackColor: colors.accent,
      thumbColor: colors.accent,
      overlayColor: colors.accent.withValues(alpha: 0.12),
      inactiveTrackColor: colors.progressTrack,
    );
  }

  static CheckboxThemeData _checkbox(AppColors colors) {
    return CheckboxThemeData(
      fillColor: _selected(colors.accent, Colors.transparent),
      checkColor: WidgetStatePropertyAll(colors.onAccent),
      side: BorderSide(color: colors.inkQuaternary),
    );
  }
}
