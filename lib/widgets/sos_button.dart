import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// Giant pulsing SOS button — the centerpiece of the Victim Home Screen.
///
/// Features:
/// - 160dp diameter with triple-ring pulse animation
/// - High-contrast red with radial gradient
/// - Haptic feedback on press
/// - Accessibility-labeled
class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnim1;
  late Animation<double> _pulseAnim2;
  late Animation<double> _pulseAnim3;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // Triple-ring pulse animation (staggered)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnim1 = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulseAnim2 = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOut),
      ),
    );
    _pulseAnim3 = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Glow breathing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isDisabled || widget.isLoading) return;

    // Heavy haptic feedback
    HapticFeedback.heavyImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Emergency SOS Button. Double tap to send emergency alert.',
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _glowController]),
        builder: (context, child) {
          return SizedBox(
            width: ErasTheme.sosButtonSize * 1.8,
            height: ErasTheme.sosButtonSize * 1.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outermost pulse ring
                _buildPulseRing(_pulseAnim1, 0.08),

                // Middle pulse ring
                _buildPulseRing(_pulseAnim2, 0.12),

                // Inner pulse ring
                _buildPulseRing(_pulseAnim3, 0.18),

                // Glow base
                Container(
                  width: ErasTheme.sosButtonSize,
                  height: ErasTheme.sosButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ErasTheme.sosRed
                            .withOpacity(_glowAnim.value * 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: ErasTheme.sosRed
                            .withOpacity(_glowAnim.value * 0.2),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),

                // Main button
                GestureDetector(
                  onTap: _handlePress,
                  child: Container(
                    width: ErasTheme.sosButtonSize,
                    height: ErasTheme.sosButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ErasTheme.sosRedLight,
                          ErasTheme.sosRed,
                          ErasTheme.sosRedDark,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'SOS',
                              style: ErasTheme.sosText,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(Animation<double> animation, double opacity) {
    final fadeOut = 1.0 -
        ((animation.value - 1.0) /
            (animation is Animation<double> ? 0.6 : 0.6));

    return Transform.scale(
      scale: animation.value,
      child: Container(
        width: ErasTheme.sosButtonSize,
        height: ErasTheme.sosButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ErasTheme.sosRed
                .withOpacity(opacity * fadeOut.clamp(0.0, 1.0)),
            width: 2,
          ),
        ),
      ),
    );
  }
}
