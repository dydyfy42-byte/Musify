/*
 *     Copyright (C) 2025 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:billie/API/musify.dart';
import 'package:billie/extensions/l10n.dart';
import 'package:billie/main.dart';
import 'package:billie/screens/search_page.dart';
import 'package:billie/services/data_manager.dart';
import 'package:billie/services/router_service.dart';
import 'package:billie/services/settings_manager.dart';
import 'package:billie/services/update_manager.dart';
import 'package:billie/style/app_colors.dart';
import 'package:billie/style/app_themes.dart';
import 'package:billie/utilities/common_variables.dart';
import 'package:billie/utilities/flutter_bottom_sheet.dart';
import 'package:billie/utilities/flutter_toast.dart';
import 'package:billie/utilities/url_launcher.dart';
import 'package:billie/utilities/utils.dart';
import 'package:billie/widgets/bottom_sheet_bar.dart';
import 'package:billie/widgets/confirmation_dialog.dart';
import 'package:billie/widgets/custom_bar.dart';
import 'package:billie/widgets/index_app_icon.dart';
import 'package:billie/widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor = Theme.of(context).colorScheme.secondaryContainer;
    final inactivatedColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n!.settings)),
      body: SingleChildScrollView(
        padding: commonSingleChildScrollViewPadding,
        child: Column(
          children: <Widget>[
            _buildPreferencesSection(
              context,
              primaryColor,
              activatedColor,
              inactivatedColor,
            ),
            if (!offlineMode.value)
              _buildOnlineFeaturesSection(
                context,
                activatedColor,
                inactivatedColor,
                primaryColor,
              ),
            _buildVoxinAppsSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    Color primaryColor,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.preferences),
        CustomBar(
          context.l10n!.accentColor,
          FluentIcons.color_24_filled,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => _showAccentColorPicker(context),
        ),
        CustomBar(
          context.l10n!.themeMode,
          FluentIcons.weather_sunny_28_filled,
          onTap: () =>
              _showThemeModePicker(context, activatedColor, inactivatedColor),
        ),
        CustomBar(
          context.l10n!.language,
          FluentIcons.translate_24_filled,
          onTap: () =>
              _showLanguagePicker(context, activatedColor, inactivatedColor),
        ),
        CustomBar(
          context.l10n!.audioQuality,
          Icons.music_note,
          onTap: () => _showAudioQualityPicker(
            context,
            activatedColor,
            inactivatedColor,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: useProxy,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.useProxy,
              FluentIcons.shield_24_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) {
                  useProxy.value = value;
                  addOrUpdateData('settings', 'useProxy', value);
                  showToast(context, context.l10n!.settingChangedMsg);
                },
              ),
            );
          },
        ),
        CustomBar(
          context.l10n!.dynamicColor,
          FluentIcons.toggle_left_24_filled,
          trailing: Switch(
            value: useSystemColor.value,
            onChanged: (value) => _toggleSystemColor(context, value),
          ),
        ),
        if (themeMode == ThemeMode.dark)
          CustomBar(
            context.l10n!.pureBlackTheme,
            FluentIcons.color_background_24_filled,
            trailing: Switch(
              value: usePureBlackColor.value,
              onChanged: (value) => _togglePureBlack(context, value),
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: predictiveBack,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.predictiveBack,
              FluentIcons.position_backward_24_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) => _togglePredictiveBack(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: offlineMode,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.offlineMode,
              FluentIcons.cellular_off_24_regular,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleOfflineMode(context, value),
              ),
            );
          },
        ),
        if (!isFdroidBuild)
          ValueListenableBuilder<bool?>(
            valueListenable: shouldWeCheckUpdates,
            builder: (_, value, __) {
              return CustomBar(
                context.l10n!.automaticUpdateChecks,
                FluentIcons.arrow_sync_24_filled,
                borderRadius: commonCustomBarRadiusLast,
                trailing: Switch(
                  value: value ?? false,
                  onChanged: (value) =>
                      _toggleAutomaticUpdateChecks(context, value),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOnlineFeaturesSection(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
    Color primaryColor,
  ) {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: sponsorBlockSupport,
          builder: (_, value, __) {
            return CustomBar(
              'SponsorBlock',
              FluentIcons.presence_blocked_24_regular,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleSponsorBlock(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: playNextSongAutomatically,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.automaticSongPicker,
              FluentIcons.music_note_2_play_20_filled,
              trailing: Switch(
                value: value,
                onChanged: (value) {
                  audioHandler.changeAutoPlayNextStatus();
                  showToast(context, context.l10n!.settingChangedMsg);
                },
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: defaultRecommendations,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.originalRecommendations,
              FluentIcons.channel_share_24_regular,
              borderRadius: commonCustomBarRadiusLast,
              trailing: Switch(
                value: value,
                onChanged: (value) =>
                    _toggleDefaultRecommendations(context, value),
              ),
            );
          },
        ),

        _buildToolsSection(context),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.tools),
        CustomBar(
          context.l10n!.clearCache,
          FluentIcons.broom_24_filled,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () async {
            final cleared = await clearCache();
            showToast(
              context,
              cleared ? '${context.l10n!.cacheMsg}!' : context.l10n!.error,
            );
          },
        ),
        CustomBar(
          context.l10n!.clearSearchHistory,
          FluentIcons.history_24_filled,
          onTap: () => _showClearSearchHistoryDialog(context),
        ),
        CustomBar(
          context.l10n!.clearRecentlyPlayed,
          FluentIcons.receipt_play_24_filled,
          onTap: () => _showClearRecentlyPlayedDialog(context),
        ),
        CustomBar(
          context.l10n!.backupUserData,
          FluentIcons.cloud_sync_24_filled,
          onTap: () => _backupUserData(context),
        ),
        CustomBar(
          context.l10n!.restoreUserData,
          FluentIcons.cloud_add_24_filled,
          onTap: () async {
            try {
              final response = await restoreData(context);
              if (context.mounted) {
                showToast(context, response);
              }
            } catch (e) {
              logger.log('Error restoring data', e, null);
              if (context.mounted) {
                showToast(context, context.l10n!.error);
              }
            }
          },
        ),
        if (!isFdroidBuild)
          CustomBar(
            context.l10n!.downloadAppUpdate,
            FluentIcons.arrow_download_24_filled,
            borderRadius: commonCustomBarRadiusLast,
            onTap: checkAppUpdates,
          ),
      ],
    );
  }



  Widget _buildVoxinAppsSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: 'تطبيقات أخرى من Voxin'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const IndexAppIcon(size: 40),
            title: const Text(
              'Index',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: const Text('تطبيق مشاهدة الأفلام والمسلسلات'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchURL(Uri.parse('https://indexdownload.netlify.app/')),
          ),
        ),
      ],
    );
  }



  void _showAccentColorPicker(BuildContext context) {
    showCustomBottomSheet(
      context,
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: availableColors.length,
        itemBuilder: (context, index) {
          final color = availableColors[index];
          final isSelected = color == primaryColorSetting;

          return GestureDetector(
            onTap: () {
              //TODO: migrate this
              addOrUpdateData(
                'settings',
                'accentColor',
                // ignore: deprecated_member_use
                color.value,
              );
              Billie.updateAppState(
                context,
                newAccentColor: color,
                useSystemColor: false,
              );
              showToast(context, context.l10n!.accentChangeMsg);
              Navigator.pop(context);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: themeMode == ThemeMode.light
                      ? color.withAlpha(150)
                      : color,
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showThemeModePicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableModes.length,
        itemBuilder: (context, index) {
          final mode = availableModes[index];
          final borderRadius = getItemBorderRadius(
            index,
            availableModes.length,
          );

          final modeNames = [
            context.l10n!.themeModeSystem,
            context.l10n!.themeModeLight,
            context.l10n!.themeModeDark,
          ];

          return BottomSheetBar(
            modeNames[mode.index],
            () {
              addOrUpdateData('settings', 'themeIndex', mode.index);
              Billie.updateAppState(context, newThemeMode: mode);
              Navigator.pop(context);
            },
            themeMode == mode ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableLanguages = appLanguages.keys.toList();
    final activeLanguageCode = Localizations.localeOf(context).languageCode;
    final activeScriptCode = Localizations.localeOf(context).scriptCode;
    final activeLanguageFullCode = activeScriptCode != null
        ? '$activeLanguageCode-$activeScriptCode'
        : activeLanguageCode;

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableLanguages.length,
        itemBuilder: (context, index) {
          final language = availableLanguages[index];
          final newLocale = getLocaleFromLanguageCode(appLanguages[language]);
          final newLocaleFullCode = newLocale.scriptCode != null
              ? '${newLocale.languageCode}-${newLocale.scriptCode}'
              : newLocale.languageCode;

          final borderRadius = getItemBorderRadius(
            index,
            availableLanguages.length,
          );

          return BottomSheetBar(
            language,
            () {
              addOrUpdateData('settings', 'language', newLocaleFullCode);
              Billie.updateAppState(context, newLocale: newLocale);
              showToast(context, context.l10n!.languageMsg);
              Navigator.pop(context);
            },
            activeLanguageFullCode == newLocaleFullCode
                ? activatedColor
                : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _showAudioQualityPicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableQualities = ['low', 'medium', 'high'];
    final qualityNames = [
      context.l10n!.audioQualityLow,
      context.l10n!.audioQualityMedium,
      context.l10n!.audioQualityHigh,
    ];

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableQualities.length,
        itemBuilder: (context, index) {
          final quality = availableQualities[index];
          final isCurrentQuality = audioQualitySetting.value == quality;
          final borderRadius = getItemBorderRadius(
            index,
            availableQualities.length,
          );

          return BottomSheetBar(
            qualityNames[index],
            () {
              addOrUpdateData('settings', 'audioQuality', quality);
              audioQualitySetting.value = quality;
              showToast(context, context.l10n!.audioQualityMsg);
              Navigator.pop(context);
            },
            isCurrentQuality ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _toggleSystemColor(BuildContext context, bool value) {
    addOrUpdateData('settings', 'useSystemColor', value);
    useSystemColor.value = value;
    Billie.updateAppState(
      context,
      newAccentColor: primaryColorSetting,
      useSystemColor: value,
    );
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePureBlack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'usePureBlackColor', value);
    usePureBlackColor.value = value;
    Billie.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePredictiveBack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'predictiveBack', value);
    predictiveBack.value = value;
    transitionsBuilder = value
        ? const PredictiveBackPageTransitionsBuilder()
        : const CupertinoPageTransitionsBuilder();
    Billie.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleOfflineMode(BuildContext context, bool value) {
    addOrUpdateData('settings', 'offlineMode', value);
    offlineMode.value = value;

    // Trigger router refresh and notify about the change
    NavigationManager.refreshRouter();
    offlineModeChangeNotifier.value = !offlineModeChangeNotifier.value;

    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleSponsorBlock(BuildContext context, bool value) {
    addOrUpdateData('settings', 'sponsorBlockSupport', value);
    sponsorBlockSupport.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleAutomaticUpdateChecks(BuildContext context, bool value) {
    addOrUpdateData('settings', 'shouldWeCheckUpdates', value);
    shouldWeCheckUpdates.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleDefaultRecommendations(BuildContext context, bool value) {
    addOrUpdateData('settings', 'defaultRecommendations', value);
    defaultRecommendations.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _showClearSearchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearSearchHistoryQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit: () => {
            Navigator.of(context).pop(),
            searchHistoryNotifier.value = [],
            deleteData('user', 'searchHistory'),
            showToast(context, '${context.l10n!.searchHistoryMsg}!'),
          },
        );
      },
    );
  }

  void _showClearRecentlyPlayedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearRecentlyPlayedQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit: () => {
            Navigator.of(context).pop(),
            userRecentlyPlayed = [],
            deleteData('user', 'recentlyPlayedSongs'),
            showToast(context, '${context.l10n!.recentlyPlayedMsg}!'),
          },
        );
      },
    );
  }

  Future<void> _backupUserData(BuildContext context) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(context.l10n!.folderRestrictions),
            actions: <Widget>[
              TextButton(
                child: Text(context.l10n!.understand.toUpperCase()),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      final response = await backupData(context);
      if (context.mounted) {
        showToast(context, response);
      }
    } catch (e) {
      logger.log('Error backing up data', e, null);
      if (context.mounted) {
        showToast(context, context.l10n!.error);
      }
    }
  }
}
