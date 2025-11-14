import 'package:flutter/material.dart';

/// 跑马灯文本组件
/// 当文本超出容器宽度时自动滚动显示
class MarqueeText extends StatefulWidget {
  /// 要显示的文本
  final String text;

  /// 文本样式
  final TextStyle? style;

  /// 滚动速度（像素/秒）
  final double speed;

  /// 两次滚动之间的暂停时间（秒）
  final double pauseDuration;

  /// 文本之间的间距
  final double spacing;

  /// 是否始终滚动（即使文本未超出宽度）
  final bool alwaysScroll;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.speed = 50.0,
    this.pauseDuration = 2.0,
    this.spacing = 50.0,
    this.alwaysScroll = false,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _needsScrolling = false;
  double _textWidth = 0;
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // 延迟执行以确保布局完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollingNeeded();
    });
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollingNeeded();
      });
    }
  }

  void _checkIfScrollingNeeded() {
    if (!mounted) return;

    // 计算文本宽度
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _textWidth = textPainter.width;
    _containerWidth = context.size?.width ?? 0;

    setState(() {
      _needsScrolling = widget.alwaysScroll || _textWidth > _containerWidth;
    });

    if (_needsScrolling) {
      _startScrolling();
    }
  }

  void _startScrolling() async {
    if (!mounted) return;

    // 等待初始暂停
    await Future.delayed(
      Duration(milliseconds: (widget.pauseDuration * 1000).toInt()),
    );

    while (mounted && _needsScrolling) {
      // 计算滚动距离和时间
      final scrollDistance = _textWidth + widget.spacing;
      final duration = Duration(
        milliseconds: ((scrollDistance / widget.speed) * 1000).toInt(),
      );

      // 滚动到末尾
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          scrollDistance,
          duration: duration,
          curve: Curves.linear,
        );
      }

      if (!mounted) break;

      // 暂停
      await Future.delayed(
        Duration(milliseconds: (widget.pauseDuration * 1000).toInt()),
      );

      if (!mounted) break;

      // 重置到起始位置
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      // 再次暂停
      await Future.delayed(
        Duration(milliseconds: (widget.pauseDuration * 1000).toInt()),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScrolling) {
      // 文本不需要滚动，直接显示
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 需要滚动，使用 ListView
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Row(
          children: [
            Text(widget.text, style: widget.style, maxLines: 1),
            SizedBox(width: widget.spacing),
          ],
        );
      },
    );
  }
}
