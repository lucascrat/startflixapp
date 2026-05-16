import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../core/constants.dart';

/// Animated loading screen with progress indicator
class LoadingScreen extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String currentPhase; // "Carregando Canais", "Carregando Filmes", etc.
  final int channelsCount;
  final int moviesCount;
  final int seriesCount;

  const LoadingScreen({
    super.key,
    required this.progress,
    required this.currentPhase,
    this.channelsCount = 0,
    this.moviesCount = 0,
    this.seriesCount = 0,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentText = '${(widget.progress * 100).toInt()}%';

    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with pulse animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Text(
                  'STARTFLIX',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryRed,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Circular progress with percentage
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[800]!,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: widget.progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed,
                        ),
                      ),
                    ),
                    // Percentage text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          percentText,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Current phase text
              Text(
                widget.currentPhase,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(
                    Icons.tv,
                    '${widget.channelsCount}',
                    'Canais',
                    widget.channelsCount > 0,
                  ),
                  const SizedBox(width: 16),
                  _buildStatChip(
                    Icons.movie,
                    '${widget.moviesCount}',
                    'Filmes',
                    widget.moviesCount > 0,
                  ),
                  const SizedBox(width: 16),
                  _buildStatChip(
                    Icons.video_library,
                    '${widget.seriesCount}',
                    'Séries',
                    widget.seriesCount > 0,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Loading dots animation
              _LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String count,
    String label,
    bool isLoaded,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLoaded
            ? AppColors.primaryRed.withOpacity(0.2)
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoaded ? AppColors.primaryRed : Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isLoaded ? AppColors.primaryRed : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: GoogleFonts.outfit(
              color: isLoaded ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = math.sin((_controller.value + delay) * math.pi * 2);
            final opacity = (value + 1) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
