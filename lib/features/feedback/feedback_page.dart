import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../core/app_navigator.dart';
import '../../l10n/generated/app_localizations.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const _feedbackLimit = 150;
  static const _attachmentSize = 90.0;
  // 给删除按钮预留外沿，确保超出缩略图的区域也可以点击。
  static const _attachmentInset = EdgeInsets.only(top: 6, right: 6);
  static const _foregroundColor = Color(0xFF222732);
  static const _mutedColor = Color(0xFF888D98);
  static const _captionColor = Color(0xFFA5ACBE);
  static const _hintColor = Color(0xFFC9CDD4);
  static const _controlSurface = Color(0xFFF5F6FA);
  static const _selectedSurface = Color(0xFFD1E9FF);
  static const _disabledSubmit = Color(0xFFA8D8FF);
  static const _borderRadius = BorderRadius.all(Radius.circular(12));

  final _feedbackController = TextEditingController();
  final _contactController = TextEditingController();
  final _picker = ImagePicker();
  final _attachments = <XFile>[];
  int? _rating;
  bool _loadingMedia = false;

  AppLocalizations get _strings => AppLocalizations.of(context)!;
  Color get _actionColor => Theme.of(context).colorScheme.primary;
  bool get _highContrast => MediaQuery.highContrastOf(context);
  Color get _secondaryColor => _highContrast ? _foregroundColor : _mutedColor;

  BorderSide get _controlBorder => _highContrast
      ? const BorderSide(color: _foregroundColor)
      : BorderSide.none;

  @override
  void initState() {
    super.initState();
    NativeBridge.sendRouteReady(AppRoutes.feedback);
    if (Platform.isAndroid) {
      _restoreAttachments();
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _restoreAttachments() async {
    // Android 可能在系统相册打开时回收进程，重新进入页面时尝试找回选中的文件。
    await _loadAttachments(() async {
      final result = await _picker.retrieveLostData();
      if (result.exception case final error?) {
        throw error;
      }
      return result.files ?? [];
    });
  }

  Future<void> _pickAttachments() async {
    FocusScope.of(context).unfocus();
    await _loadAttachments(
      () => _picker.pickMultipleMedia(requestFullMetadata: false),
    );
  }

  Future<void> _loadAttachments(Future<List<XFile>> Function() load) async {
    if (_loadingMedia) return;
    setState(() => _loadingMedia = true);
    try {
      final selected = await load();
      if (!mounted || selected.isEmpty) return;

      setState(() {
        final paths = _attachments.map((attachment) => attachment.path).toSet();
        _attachments.addAll(
          selected.where((attachment) => paths.add(attachment.path)),
        );
      });
    } on PlatformException {
      if (mounted) _showMessage(_strings.feedbackMediaReadFailed);
    } on MissingPluginException {
      if (mounted) _showMessage(_strings.feedbackGalleryUnavailable);
    } finally {
      if (mounted) setState(() => _loadingMedia = false);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (kDebugMode) {
      final payload = {
        'rating': _rating,
        'feedback': _feedbackController.text.trim(),
        'contact': _contactController.text.trim(),
        'attachments': _attachments
            .map((attachment) => attachment.path)
            .toList(),
      };
      debugPrint('Feedback submit: ${jsonEncode(payload)}');
    }
    // 当前只演示提交成功后的页面状态，附件保存在本次页面会话中。
    _feedbackController.clear();
    _contactController.clear();
    setState(() {
      _rating = null;
      _attachments.clear();
    });
    _showMessage(_strings.feedbackSubmitted);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: _highContrast ? _foregroundColor : _hintColor,
      ),
      filled: true,
      fillColor: _controlSurface,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: _controlBorder,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: _actionColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heading = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: _foregroundColor,
      fontWeight: FontWeight.w600,
    );
    final caption = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: _highContrast ? _foregroundColor : _captionColor,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _foregroundColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => AppNavigator.pop(context),
          ),
        title: Text(
          _strings.feedbackTitle,
          style: heading?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(_strings.feedbackRating, style: heading),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var score = 1; score <= 5; score++)
                        _ratingButton(score),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(_strings.feedbackLabel, style: heading),
                  const SizedBox(height: 10),
                  _feedbackInput(caption),
                  const SizedBox(height: 18),
                  Text(_strings.feedbackAttachments, style: heading),
                  const SizedBox(height: 8),
                  Text(_strings.feedbackAttachmentsHint, style: caption),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Padding(
                        padding: _attachmentInset,
                        child: SizedBox.square(
                          dimension: _attachmentSize,
                          child: IconButton(
                            tooltip: _strings.feedbackPickMedia,
                            onPressed: _loadingMedia ? null : _pickAttachments,
                            style: IconButton.styleFrom(
                              backgroundColor: _controlSurface,
                              disabledBackgroundColor: _controlSurface,
                              foregroundColor: _secondaryColor,
                              side: _controlBorder,
                              shape: RoundedRectangleBorder(
                                borderRadius: _borderRadius,
                              ),
                            ),
                            icon: _loadingMedia
                                ? SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _actionColor,
                                    ),
                                  )
                                : const Icon(Icons.add),
                          ),
                        ),
                      ),
                      for (final attachment in _attachments)
                        _attachmentTile(attachment),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(_strings.feedbackContact, style: heading),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactController,
                    style: const TextStyle(color: _foregroundColor),
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(_strings.feedbackContactHint),
                  ),
                  const SizedBox(height: 12),
                  Text(_strings.feedbackThanks, style: caption),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _feedbackController,
                  builder: (context, feedback, child) {
                    final canSubmit =
                        _rating != null &&
                        feedback.text.trim().isNotEmpty &&
                        !_loadingMedia;
                    return FilledButton(
                      onPressed: canSubmit ? _submit : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _actionColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _disabledSubmit,
                        disabledForegroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: _borderRadius,
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Text(_strings.feedbackSubmit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackInput(TextStyle? caption) {
    final counterHeight = MediaQuery.textScalerOf(
      context,
    ).scale(caption?.fontSize ?? 12);
    return Stack(
      children: [
        TextField(
          controller: _feedbackController,
          style: const TextStyle(color: _foregroundColor),
          minLines: 5,
          maxLines: 5,
          maxLength: _feedbackLimit,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: _inputDecoration(_strings.feedbackHint).copyWith(
            counterText: '',
            contentPadding: EdgeInsets.fromLTRB(14, 14, 14, counterHeight + 20),
          ),
        ),
        PositionedDirectional(
          end: 12,
          bottom: 12,
          child: IgnorePointer(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _feedbackController,
              builder: (context, feedback, _) {
                final remaining =
                    (_feedbackLimit - feedback.text.characters.length).clamp(
                      0,
                      _feedbackLimit,
                    );
                return Text(
                  '$remaining/$_feedbackLimit',
                  style: caption?.copyWith(
                    color: _highContrast ? _foregroundColor : _hintColor,
                  ),
                  semanticsLabel: _strings.feedbackRemaining(remaining),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingButton(int score) {
    final selected = _rating == score;
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        onPressed: () => setState(() => _rating = score),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? _selectedSurface : _controlSurface,
          foregroundColor: selected && !_highContrast
              ? _actionColor
              : _secondaryColor,
          side: selected ? BorderSide(color: _actionColor) : _controlBorder,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('$score'),
      ),
    );
  }

  Widget _attachmentTile(XFile attachment) {
    final type = attachment.mimeType ?? lookupMimeType(attachment.name);
    final isVideo = type?.startsWith('video/') ?? false;
    return SizedBox.square(
      key: ValueKey(attachment.path),
      dimension: _attachmentSize + _attachmentInset.top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: _attachmentInset,
            child: ClipRRect(
              borderRadius: _borderRadius,
              child: ColoredBox(
                color: _controlSurface,
                child: isVideo
                    ? Center(
                        child: Icon(
                          Icons.videocam_outlined,
                          color: _secondaryColor,
                        ),
                      )
                    : Image.file(
                        File(attachment.path),
                        fit: BoxFit.cover,
                        cacheWidth: 256,
                        semanticLabel: attachment.name,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: _secondaryColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              alignment: Alignment.topRight,
              padding: EdgeInsets.zero,
              tooltip: _strings.feedbackRemoveMedia(attachment.name),
              onPressed: () => setState(() => _attachments.remove(attachment)),
              icon: const CircleAvatar(
                radius: 11,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
