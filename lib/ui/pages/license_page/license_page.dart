import 'dart:async' show Future;

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extensions.dart';
import '../../components/loading_state_view.dart';
import '../../components/page_app_bar.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  String _licenseText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLicense();
  }

  Future<void> _loadLicense() async {
    try {
      final licenseContent = await rootBundle.loadString('LICENSE');
      setState(() {
        _licenseText = licenseContent;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _licenseText = context.l10n.licenseLoadFailed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(title: context.l10n.openSourceLicense),
      body: _loading
          ? Center(
              child: LoadingStateView(
                title: context.l10n.licenseLoading,
                subtitle: context.l10n.licenseLoadingSubtitle,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(_licenseText),
            ),
    );
  }
}
