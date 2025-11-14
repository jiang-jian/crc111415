import java.nio.charset.Charset

/**
 * 调试标签解析逻辑
 * 模拟实际执行流程
 */
fun main() {
    println("=== 标签解析调试工具 ===")
    println()
    
    // 测试用例1: 居中 + XL 字号
    val test1 = "[center]<xl>HOLOX超乐场</xl>[/center]"
    println("测试1: $test1")
    simulateParsing(test1)
    println()
    
    // 测试用例2: 居中 + 分隔线
    val test2 = "[center]===[/center]"
    println("测试2: $test2")
    simulateParsing(test2)
    println()
    
    // 测试用例3: 完整模板
    val test3 = """[center]<xl>HOLOX超乐场</xl>[/center]
[center]===[/center]
[left]**存币单号:**12345[/left]"""
    println("测试3: 完整模板")
    simulateParsing(test3)
}

fun simulateParsing(text: String) {
    var currentPos = 0
    val textLength = text.length
    val charset = Charset.forName("GB18030")
    var stepCount = 0
    
    println("文本长度: $textLength")
    println("字符映射:")
    text.forEachIndexed { index, char ->
        if (char == '\n') {
            println("  [$index] = \\n")
        } else {
            println("  [$index] = '$char'")
        }
    }
    println()
    println("开始解析:")
    println()
    
    while (currentPos < textLength) {
        stepCount++
        println("--- 步骤 $stepCount ---")
        println("currentPos = $currentPos")
        
        if (currentPos < textLength) {
            val remainingText = text.substring(currentPos)
            println("剩余文本: \"${remainingText.take(30)}${if (remainingText.length > 30) "..." else ""}\"")
        }
        
        var matched = false
        var advancePos = currentPos
        var matchType = ""
        
        // 检查 [center], [left], [right]
        if (text[currentPos] == '[') {
            val tagEnd = text.indexOf(']', currentPos)
            if (tagEnd != -1) {
                val tag = text.substring(currentPos + 1, tagEnd)
                when (tag) {
                    "center" -> {
                        matchType = "[center] - 发送居中指令"
                        advancePos = tagEnd + 1
                        matched = true
                    }
                    "/center", "/left", "/right" -> {
                        matchType = "[$tag] - 发送左对齐指令（复位）"
                        advancePos = tagEnd + 1
                        matched = true
                    }
                    "left" -> {
                        matchType = "[left] - 发送左对齐指令"
                        advancePos = tagEnd + 1
                        matched = true
                    }
                }
            }
        }
        
        // 检查 <xl>
        if (!matched && text.substring(currentPos).startsWith("<xl>")) {
            val endPos = text.indexOf("</xl>", currentPos)
            if (endPos != -1) {
                val content = text.substring(currentPos + 4, endPos)
                matchType = "<xl>$content</xl> - 发送2倍字号 + 内容 + 换行"
                advancePos = endPos + 5
                matched = true
            }
        }
        
        // 检查 **text**
        if (!matched && currentPos < textLength - 2 && text.substring(currentPos).startsWith("**")) {
            val endPos = text.indexOf("**", currentPos + 2)
            if (endPos != -1) {
                val content = text.substring(currentPos + 2, endPos)
                matchType = "**$content** - 发送加粗 + 内容"
                advancePos = endPos + 2
                matched = true
            }
        }
        
        // 检查分隔线 ===
        if (!matched && currentPos < textLength - 2) {
            val char = text[currentPos]
            if ((char == '=' || char == '-') && 
                currentPos + 2 < textLength &&
                text[currentPos + 1] == char && 
                text[currentPos + 2] == char) {
                
                val isLineStart = currentPos == 0 || 
                                  text[currentPos - 1] == '\n' || 
                                  text[currentPos - 1] == ']' || 
                                  text[currentPos - 1] == '>'
                
                val nextPos = currentPos + 3
                val isLineEnd = nextPos >= textLength || 
                                text[nextPos] == '\n' || 
                                text[nextPos] == '[' || 
                                text[nextPos] == '<'
                
                println("  检测到连续3个 '$char':")
                println("    前一个字符 [${currentPos - 1}] = '${if (currentPos > 0) text[currentPos - 1] else "N/A"}'")
                println("    后一个字符 [$nextPos] = '${if (nextPos < textLength) text[nextPos] else "EOF"}'")
                println("    isLineStart = $isLineStart")
                println("    isLineEnd = $isLineEnd")
                
                if (isLineStart && isLineEnd) {
                    matchType = "$char$char$char - 识别为分隔线！发送32个 '$char' + 换行"
                    advancePos = nextPos
                    matched = true
                } else {
                    println("    ❌ 不满足分隔线条件，当作普通字符处理")
                }
            }
        }
        
        // 未匹配，添加当前字符
        if (!matched) {
            val char = text[currentPos]
            matchType = if (char == '\n') {
                "'\\n' - 换行符"
            } else {
                "'$char' - 普通字符"
            }
            advancePos = currentPos + 1
        }
        
        println("匹配结果: $matchType")
        println("跳转到位置: $advancePos")
        println()
        
        currentPos = advancePos
        
        // 防止无限循环
        if (stepCount > 50) {
            println("⚠️ 步骤数超过50，停止模拟")
            break
        }
    }
    
    println("解析完成！总步骤数: $stepCount")
    println("=" .repeat(50))
}
