import 'package:flutter/material.dart';

/// 小票样式解析器
/// 将样式标记文本转换为富文本组件
class ReceiptStyleParser {
  /// 解析带样式标记的文本，返回 TextSpan 列表
  /// [useMonospace] 是否使用等宽字体（默认 true，用于商品列表对齐）
  static List<InlineSpan> parse(
    String text, {
    double baseFontSize = 14.0,
    bool useMonospace = true,
  }) {
    final List<InlineSpan> spans = [];

    // 处理空文本
    if (text.isEmpty) {
      return [
        TextSpan(
          text: '',
          style: TextStyle(
            fontSize: baseFontSize,
            fontFamily: useMonospace ? 'monospace' : null,
          ),
        ),
      ];
    }

    // 按行处理
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 检查对齐方式
      final alignment = _extractAlignment(line);
      final cleanedLine = _removeAlignmentTags(line);

      // 解析行内样式
      final lineSpans = _parseLineStyles(cleanedLine, baseFontSize, useMonospace);

      // 如果有对齐方式，包装在 WidgetSpan 中
      if (alignment != null) {
        spans.add(
          WidgetSpan(
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: alignment,
                child: Text.rich(TextSpan(children: lineSpans)),
              ),
            ),
          ),
        );
      } else {
        spans.addAll(lineSpans);
      }

      // 添加换行（除了最后一行）
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  /// 提取对齐方式
  static Alignment? _extractAlignment(String line) {
    if (line.contains('[center]')) return Alignment.center;
    if (line.contains('[right]')) return Alignment.centerRight;
    if (line.contains('[left]')) return Alignment.centerLeft;
    return null;
  }

  /// 移除对齐标记
  static String _removeAlignmentTags(String line) {
    return line
        .replaceAll('[center]', '')
        .replaceAll('[/center]', '')
        .replaceAll('[left]', '')
        .replaceAll('[/left]', '')
        .replaceAll('[right]', '')
        .replaceAll('[/right]', '');
  }

  /// 解析行内样式
  static List<InlineSpan> _parseLineStyles(
    String text,
    double baseFontSize,
    bool useMonospace,
  ) {
    final List<InlineSpan> spans = [];

    // 处理空行
    if (text.trim().isEmpty) {
      return [
        TextSpan(
          text: '',
          style: TextStyle(
            fontSize: baseFontSize,
            fontFamily: useMonospace ? 'monospace' : null,
          ),
        ),
      ];
    }

    // 处理分隔线
    if (text.trim() == '---' || text.trim() == '===') {
      spans.add(
        WidgetSpan(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: text.trim() == '===' ? 2 : 1,
            color: Colors.black54,
          ),
        ),
      );
      return spans;
    }

    // 处理空行标记
    if (text.trim() == '<br>') {
      spans.add(const TextSpan(text: '\n'));
      return spans;
    }

    int pos = 0;
    while (pos < text.length) {
      // 查找下一个样式标记
      final nextMarkPos = _findNextMark(text, pos);

      if (nextMarkPos == -1) {
        // 没有更多标记，添加剩余文本
        if (pos < text.length) {
          spans.add(
            TextSpan(
              text: text.substring(pos),
              style: TextStyle(
                fontSize: baseFontSize,
                color: Colors.black87,
                fontFamily: useMonospace ? 'monospace' : null,
              ),
            ),
          );
        }
        break;
      }

      // 添加标记前的普通文本
      if (nextMarkPos > pos) {
        spans.add(
          TextSpan(
            text: text.substring(pos, nextMarkPos),
            style: TextStyle(
              fontSize: baseFontSize,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
        );
      }

      // 解析样式标记
      final result = _parseStyleMark(text, nextMarkPos, baseFontSize, useMonospace);
      if (result != null) {
        spans.add(result.span);
        pos = result.endPos;
      } else {
        // 无法解析，当作普通文本
        spans.add(
          TextSpan(
            text: text[nextMarkPos],
            style: TextStyle(
              fontSize: baseFontSize,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
        );
        pos = nextMarkPos + 1;
      }
    }

    return spans;
  }

  /// 查找下一个样式标记位置
  static int _findNextMark(String text, int startPos) {
    final marks = ['***', '**', '*', '__', '~~', '<small>', '<large>', '<xl>'];
    int nearestPos = -1;

    for (final mark in marks) {
      final pos = text.indexOf(mark, startPos);
      if (pos != -1 && (nearestPos == -1 || pos < nearestPos)) {
        nearestPos = pos;
      }
    }

    return nearestPos;
  }

  /// 解析单个样式标记
  static _StyleParseResult? _parseStyleMark(
    String text,
    int startPos,
    double baseFontSize,
    bool useMonospace,
  ) {
    // 粗斜体 ***text***
    if (text.substring(startPos).startsWith('***')) {
      final endPos = text.indexOf('***', startPos + 3);
      if (endPos != -1) {
        final content = text.substring(startPos + 3, endPos);
        return _StyleParseResult(
          span: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: baseFontSize,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 3,
        );
      }
    }

    // 粗体 **text**
    if (text.substring(startPos).startsWith('**')) {
      final endPos = text.indexOf('**', startPos + 2);
      if (endPos != -1) {
        final content = text.substring(startPos + 2, endPos);
        return _StyleParseResult(
          span: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: baseFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 2,
        );
      }
    }

    // 斜体 *text*
    if (text.substring(startPos).startsWith('*')) {
      final endPos = text.indexOf('*', startPos + 1);
      if (endPos != -1) {
        final content = text.substring(startPos + 1, endPos);
        return _StyleParseResult(
          span: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: baseFontSize,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 1,
        );
      }
    }

    // 下划线 __text__
    if (text.substring(startPos).startsWith('__')) {
      final endPos = text.indexOf('__', startPos + 2);
      if (endPos != -1) {
        final content = text.substring(startPos + 2, endPos);
        return _StyleParseResult(
          span: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: baseFontSize,
              decoration: TextDecoration.underline,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 2,
        );
      }
    }

    // 删除线 ~~text~~
    if (text.substring(startPos).startsWith('~~')) {
      final endPos = text.indexOf('~~', startPos + 2);
      if (endPos != -1) {
        final content = text.substring(startPos + 2, endPos);
        return _StyleParseResult(
          span: TextSpan(
            text: content,
            style: TextStyle(
              fontSize: baseFontSize,
              decoration: TextDecoration.lineThrough,
              fontFamily: useMonospace ? 'monospace' : null,
              color: Colors.black54,
            ),
          ),
          endPos: endPos + 2,
        );
      }
    }

    // 小号字体 <small>text</small>
    if (text.substring(startPos).startsWith('<small>')) {
      final endPos = text.indexOf('</small>', startPos);
      if (endPos != -1) {
        final content = text.substring(startPos + 7, endPos);
        // 递归解析内部样式（去除Markdown标记但保留样式效果）
        final innerText = content
            .replaceAll('***', '')
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('__', '')
            .replaceAll('~~', '');
        return _StyleParseResult(
          span: TextSpan(
            text: innerText,
            style: TextStyle(
              fontSize: baseFontSize * 0.85,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 8,
        );
      }
    }

    // 大号字体 <large>text</large>
    if (text.substring(startPos).startsWith('<large>')) {
      final endPos = text.indexOf('</large>', startPos);
      if (endPos != -1) {
        final content = text.substring(startPos + 7, endPos);
        // 递归解析内部样式（去除Markdown标记但保留样式效果）
        final innerText = content
            .replaceAll('***', '')
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('__', '')
            .replaceAll('~~', '');
        return _StyleParseResult(
          span: TextSpan(
            text: innerText,
            style: TextStyle(
              fontSize: baseFontSize * 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 8,
        );
      }
    }

    // 超大号字体 <xl>text</xl>
    if (text.substring(startPos).startsWith('<xl>')) {
      final endPos = text.indexOf('</xl>', startPos);
      if (endPos != -1) {
        final content = text.substring(startPos + 4, endPos);
        // 递归解析内部样式（去除Markdown标记但保留样式效果）
        final innerText = content
            .replaceAll('***', '')
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('__', '')
            .replaceAll('~~', '');
        return _StyleParseResult(
          span: TextSpan(
            text: innerText,
            style: TextStyle(
              fontSize: baseFontSize * 1.6,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: useMonospace ? 'monospace' : null,
            ),
          ),
          endPos: endPos + 5,
        );
      }
    }

    return null;
  }
}

/// 样式解析结果
class _StyleParseResult {
  final InlineSpan span;
  final int endPos;

  _StyleParseResult({required this.span, required this.endPos});
}
