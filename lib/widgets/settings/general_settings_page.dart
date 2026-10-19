/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/brightness_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'focusable_settings_tile.dart';
import 'brightness_settings_page.dart';
import 'date_time_format_page.dart';
import 'back_button_action_page.dart';
import 'wifi_usage_period_page.dart';
import 'screensaver_clock_style_page.dart';
import 'package:provider/provider.dart';


class GeneralSettingsPage extends StatelessWidget {
  static const String routeName = "general_settings_panel";

  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(localizations.system, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FocusableSettingsTile(
                  autofocus: true,
                  leading: const Icon(Icons.brightness_6),
                  title: Text(localizations.brightnessScheduler, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(BrightnessSettingsPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.screenshot_monitor),
                  title: Text(localizations.screensaverSettings, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => _openScreensaverSettings(),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.watch_later_outlined),
                  title: Text(localizations.screensaverClockStyle, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(ScreensaverClockStylePage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(localizations.dateAndTimeFormat, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(DateTimeFormatPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.arrow_back),
                  title: Text(localizations.backButtonAction, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(BackButtonActionPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.wifi),
                  title: Text(localizations.wifiUsagePeriod, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(WifiUsagePeriodPage.routeName),
                ),
                const Divider(),
                FocusableSettingsTile(
                  leading: Icon(Icons.restart_alt, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    localizations.resetSettings,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: () => _confirmReset(context, localizations),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openScreensaverSettings() async {
    const platform = MethodChannel('me.efesser.flauncher/method');
    platform.invokeMethod('openScreensaverSettings');
  }

  Future<void> _confirmReset(BuildContext context, AppLocalizations localizations) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.resetSettings),
        content: Text(localizations.resetSettingsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              localizations.resetSettings,
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (shouldReset != true || !context.mounted) {
      return;
    }

    try {
      await context.read<BrightnessService>().resetToDefaults();
      await context.read<SettingsService>().resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.settingsResetComplete)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.settingsResetFailed}: $error')),
        );
      }
    }
  }
}
