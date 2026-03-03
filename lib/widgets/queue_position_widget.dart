// =============================================================================
// GETINLINE FLUTTER - widgets/queue_position_widget.dart
// Reusable Queue Position Display Widget
// =============================================================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QueuePositionWidget extends StatelessWidget {
  final int position;
  final int totalInQueue;
  final bool isLarge;
  final Color? color;

  const QueuePositionWidget({
    Key? key,
    required this.position,
    this.totalInQueue = 0,
    this.isLarge = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.primary;
    
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [displayColor, displayColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: displayColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLarge ? _buildLargeWidget() : _buildCompactWidget(),
    );
  }

  Widget _buildLargeWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$position',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Queue Position',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getPositionMessage(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.queue, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          'Position: $position',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (totalInQueue > 0) ...[
          const Text(' / ', style: TextStyle(color: Colors.white)),
          Text('$totalInQueue', style: const TextStyle(color: Colors.white)),
        ],
      ],
    );
  }

  String _getPositionMessage() {
    if (position == 1) return 'Your turn next!';
    if (position == 2) return '1 person ahead';
    return '${position - 1} people ahead';
  }
}

// Animated version
class AnimatedQueuePosition extends StatefulWidget {
  final int position;
  final Duration duration;

  const AnimatedQueuePosition({
    Key? key,
    required this.position,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<AnimatedQueuePosition> createState() => _AnimatedQueuePositionState();
}

class _AnimatedQueuePositionState extends State<AnimatedQueuePosition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedQueuePosition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: QueuePositionWidget(position: widget.position, isLarge: true),
    );
  }
}
