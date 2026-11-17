import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

/// Tactile 3D extruded pill button with press depression and top specular glint.
class Tactile3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String title;
  final String? subtitle;
  final Color color;
  final Color shadeColor;
  final Color textColor;
  final Widget? icon;
  final Widget? rightBadge;
  final Widget? child;
  final double? width;
  final double height;
  final double extrusionDepth;
  final bool disabled;
  final EdgeInsetsGeometry padding;

  const Tactile3DButton({
    super.key,
    required this.onPressed,
    this.title = '',
    this.subtitle,
    required this.color,
    required this.shadeColor,
    this.textColor = Colors.white,
    this.icon,
    this.rightBadge,
    this.child,
    this.width,
    this.height = 54,
    this.extrusionDepth = 5,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<Tactile3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.onPressed == null;
    final translateY =
        (_isPressed && !isDisabled) ? widget.extrusionDepth - 1 : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double? effectiveWidth = widget.width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);

        final Widget content = widget.child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  if (widget.title.isNotEmpty ||
                      (widget.subtitle != null && widget.subtitle!.isNotEmpty))
                    const SizedBox(width: 8),
                ],
                if (widget.title.isNotEmpty ||
                    (widget.subtitle != null && widget.subtitle!.isNotEmpty))
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.title.isNotEmpty)
                          Text(
                            widget.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: widget.textColor,
                            ),
                          ),
                        if (widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty)
                          Text(
                            widget.subtitle!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.textColor.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (widget.rightBadge != null) widget.rightBadge!,
              ],
            );

        final Widget topFace = Transform.translate(
          offset: Offset(0, translateY),
          child: Container(
            width: effectiveWidth,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: (_isPressed && !isDisabled)
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 12,
                    right: 12,
                    height: widget.height * 0.42,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: widget.padding,
                    child: content,
                  ),
                ],
              ),
            ),
          ),
        );

        return MouseRegion(
          cursor:
              isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Opacity(
            opacity: widget.disabled ? 0.6 : 1.0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  isDisabled ? null : (_) => setState(() => _isPressed = true),
              onTapUp:
                  isDisabled ? null : (_) => setState(() => _isPressed = false),
              onTapCancel:
                  isDisabled ? null : () => setState(() => _isPressed = false),
              onTap: isDisabled
                  ? null
                  : () {
                      AudioService.maybeOf(context)?.playClick();
                      widget.onPressed?.call();
                    },
              child: SizedBox(
                width: effectiveWidth,
                height: widget.height + widget.extrusionDepth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: widget.height,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.shadeColor,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: widget.extrusionDepth),
                      child: topFace,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
