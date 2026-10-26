import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

/// 课表个性化使用的简约 HSV 取色器。
///
/// 不引入第三方取色包；三个滑杆分别控制色相、饱和度和明度。拖动时只更新
/// 取色器本地预览，松手时才通过 [onChanged] 提交，避免逐帧重建页面。
Future<void> showScheduleColorPicker({
  required BuildContext context,
  required String title,
  required Color initialColor,
  required ValueChanged<Color> onChanged,
  VoidCallback? onReset,
  String? resetLabel,
}) {
  var hsv = HSVColor.fromColor(initialColor);

  return showMcBottomSheet<void>(
    context: context,
    showHandle: true,
    maxHeight: MediaQuery.sizeOf(context).height * 0.8,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          void update(HSVColor value) {
            setState(() => hsv = value);
          }

          void commit() => onChanged(hsv.toColor());

          final currentColor = hsv.toColor();
          final hex = currentColor
              .toARGB32()
              .toRadixString(16)
              .padLeft(8, '0')
              .substring(2)
              .toUpperCase();

          return Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (onReset != null)
                        TextButton(
                          onPressed: () {
                            onReset();
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(resetLabel ?? context.l10n.resetColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: McRadii.controlBorder,
                      border: Border.all(
                        color: context.mc.colors.separator,
                        width: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#$hex',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.mc.colors.secondaryLabel,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PickerSlider(
                    label: 'H',
                    value: hsv.hue,
                    max: 360,
                    onChanged: (value) => update(hsv.withHue(value)),
                    onChangeEnd: commit,
                  ),
                  _PickerSlider(
                    label: 'S',
                    value: hsv.saturation,
                    max: 1,
                    onChanged: (value) => update(hsv.withSaturation(value)),
                    onChangeEnd: commit,
                  ),
                  _PickerSlider(
                    label: 'V',
                    value: hsv.value,
                    max: 1,
                    onChanged: (value) => update(hsv.withValue(value)),
                    onChangeEnd: commit,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _PickerSlider extends StatelessWidget {
  const _PickerSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0, max).toDouble(),
            max: max,
            onChanged: onChanged,
            onChangeEnd: (_) => onChangeEnd(),
          ),
        ),
      ],
    );
  }
}
