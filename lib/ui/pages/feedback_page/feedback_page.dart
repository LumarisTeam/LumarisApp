import 'dart:typed_data';

import 'package:feedback_sdk/feedback_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// 匿名反馈表单页：描述 + 联系方式 + 图片（≤6）+ 字数统计 + 提交。
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();

  final List<_PickedImage> _images = [];
  bool _submitting = false;

  /// 幂等 request_id：同一份内容重试时复用，内容变更时重置。
  String? _requestId;

  FeedbackConfig get _config => FeedbackSdk.instance.config;

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _markDirty() => _requestId = null;

  Future<void> _pickImages() async {
    final remaining = _config.maxImageCount - _images.length;
    if (remaining <= 0) {
      showClubSnackBar(context, Text(context.l10n.feedbackImageTooMany));
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
    } catch (_) {
      if (!mounted) return;
      showClubSnackBar(context, Text(context.l10n.feedbackPickImageFailed));
      return;
    }
    if (result == null || !mounted) return;

    final picked = result.files
        .where((f) => f.bytes != null)
        .take(remaining)
        .map((f) => _PickedImage(
              f.name.isNotEmpty
                  ? f.name
                  : 'feedback_${DateTime.now().millisecondsSinceEpoch}.jpg',
              f.bytes!,
            ))
        .toList();

    if (picked.isEmpty) {
      showClubSnackBar(context, Text(context.l10n.feedbackPickImageFailed));
      return;
    }

    setState(() {
      _images.addAll(picked);
      _requestId = null;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _requestId = null;
    });
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    final contact = _contactController.text.trim();

    if (content.isEmpty) {
      showClubSnackBar(context, Text(context.l10n.feedbackContentRequired));
      return;
    }
    if (contact.isEmpty) {
      showClubSnackBar(context, Text(context.l10n.feedbackContactRequired));
      return;
    }

    setState(() => _submitting = true);
    try {
      // 三段式上传每张图片，收集 attachment_id。
      final attachmentIds = <int>[];
      for (final img in _images) {
        attachmentIds.add(await FeedbackSdk.instance.uploadImage(
          filename: img.filename,
          raw: img.bytes,
        ));
      }

      // school 运行时可能切换，提交时用当前学校覆盖 init 时的值。
      final school =
          ref.read(schoolStoreProvider).school?.code.toLowerCase() ?? '';
      final extra = <String, dynamic>{
        if (school.isNotEmpty) 'school': school,
      };

      // 复用同一 request_id 保证失败重试幂等。
      _requestId ??= FeedbackSdk.instance.newRequestId();
      await FeedbackSdk.instance.submit(
        content: content,
        contact: contact,
        attachmentIds: attachmentIds,
        page: 'FeedbackPage',
        extra: extra,
        requestId: _requestId,
      );

      if (!mounted) return;
      showClubSnackBar(context, Text(context.l10n.feedbackSubmitSuccess));
      setState(() {
        _submitting = false;
        _images.clear();
        _contentController.clear();
        _contactController.clear();
        _requestId = null;
      });
      Navigator.of(context).maybePop();
    } on FeedbackException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showClubSnackBar(context, Text(e.userMessage));
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showClubSnackBar(context, Text(FeedbackApi.toFeedback(e).userMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: ClubAppBar(title: l10n.feedback),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.clubColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context, l10n.feedbackContentLabel,
                required: true),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _contentController,
              minLines: 5,
              maxLines: 8,
              maxLength: _config.maxContentLength,
              placeholder: l10n.feedbackContentHint,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: CupertinoColors.black,
                ),
                border: Border.all(
                  color: CupertinoDynamicColor.withBrightness(
                    color: Color(0x33000000),
                    darkColor: Color(0x33FFFFFF),
                  ),
                  width: 1,
                ),
              ),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            _buildFieldLabel(context, l10n.feedbackContactLabel,
                required: true),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _contactController,
              maxLength: _config.maxContactLength,
              placeholder: l10n.feedbackContactHint,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: CupertinoColors.black,
                ),
                border: Border.all(
                  color: CupertinoDynamicColor.withBrightness(
                    color: Color(0x33000000),
                    darkColor: Color(0x33FFFFFF),
                  ),
                  width: 1,
                ),
              ),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            _buildFieldLabel(context, l10n.feedbackImagesLabel),
            const SizedBox(height: 8),
            _buildImageGrid(context),
            const SizedBox(height: 32),
            SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                    onPressed: _submitting ? null : _submit,
                    child: Text(l10n.feedbackSubmit)))
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
    BuildContext context,
    String text, {
    bool required = false,
  }) {
    final colors = context.clubColors;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.label,
          ),
        ),
        if (required) Text(' *', style: TextStyle(color: colors.danger)),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < _images.length; i++) _buildImageThumb(context, i),
        if (_images.length < _config.maxImageCount) _buildAddTile(context),
      ],
    );
  }

  Widget _buildAddTile(BuildContext context) {
    final colors = context.clubColors;
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.separator),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: colors.secondaryLabel),
            const SizedBox(height: 4),
            Text(
              context.l10n.feedbackAddImage,
              style: TextStyle(fontSize: 11, color: colors.secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumb(BuildContext context, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _images[index].bytes,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickedImage {
  final String filename;
  final Uint8List bytes;

  const _PickedImage(this.filename, this.bytes);
}
