package com.holox.ailand_pos.mingtech

/**
 * 明泰MT3-URF1-R333读卡器协议定义
 * 
 * 报文格式（推测，需根据实际测试调整）：
 * [0xAA][CMD][LEN][PAYLOAD...][CS]
 * 
 * CS = Checksum (XOR所有字节)
 */
object Protocol {
    // 设备标识
    const val VENDOR_ID = 0x23A4
    const val PRODUCT_ID = 0x020C
    
    // USB端点
    const val ENDPOINT_IN = 0x81
    const val ENDPOINT_OUT = 0x01
    const val PACKET_SIZE = 64
    
    // 协议头
    const val FRAME_HEADER: Byte = 0xAA.toByte()
    
    // 命令码（根据行业标准推测，需实测验证）
    object Command {
        const val GET_STATUS: Byte = 0x20        // 获取读卡器状态
        const val POLL_CARD: Byte = 0x30         // 寻卡（返回UID）
        const val AUTH_SECTOR: Byte = 0x40       // 认证扇区
        const val READ_BLOCK: Byte = 0x50        // 读取块
        const val WRITE_BLOCK: Byte = 0x51       // 写入块（预留）
        const val HALT_CARD: Byte = 0x60         // 停止操作卡片
    }
    
    // 状态码
    object Status {
        const val SUCCESS: Byte = 0x00
        const val NO_CARD: Byte = 0x01
        const val AUTH_FAILED: Byte = 0x02
        const val READ_FAILED: Byte = 0x03
        const val TIMEOUT: Byte = 0x04
        const val INVALID_PARAM: Byte = 0x05
        const val DEVICE_ERROR: Byte = 0xFF.toByte()
    }
    
    // M1卡常量
    object M1 {
        const val UID_LENGTH_4 = 4    // Mifare Classic 1K
        const val UID_LENGTH_7 = 7    // Mifare Classic 4K
        const val BLOCK_SIZE = 16     // 每个块16字节
        const val SECTOR_SIZE = 4     // 每个扇区4个块
        const val KEY_LENGTH = 6      // 密钥长度6字节
        
        // 默认密钥
        val DEFAULT_KEY_A = byteArrayOf(
            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
        )
        val DEFAULT_KEY_B = byteArrayOf(
            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
        )
    }
    
    /**
     * 构建命令帧
     * 
     * @param cmd 命令码
     * @param payload 载荷数据
     * @return 完整的命令帧（包含校验和）
     */
    fun buildFrame(cmd: Byte, payload: ByteArray = byteArrayOf()): ByteArray {
        val len = payload.size.toByte()
        val frame = mutableListOf<Byte>()
        
        frame.add(FRAME_HEADER)
        frame.add(cmd)
        frame.add(len)
        frame.addAll(payload.toList())
        
        // 计算校验和（XOR所有字节）
        var checksum: Byte = 0
        for (b in frame) {
            checksum = (checksum.toInt() xor b.toInt()).toByte()
        }
        frame.add(checksum)
        
        // 填充到64字节（HID包大小）
        while (frame.size < PACKET_SIZE) {
            frame.add(0x00)
        }
        
        return frame.toByteArray()
    }
    
    /**
     * 验证响应帧校验和
     */
    fun verifyChecksum(frame: ByteArray): Boolean {
        if (frame.isEmpty()) return false
        
        var checksum: Byte = 0
        for (i in 0 until frame.size - 1) {
            checksum = (checksum.toInt() xor frame[i].toInt()).toByte()
        }
        
        return checksum == frame.last()
    }
    
    /**
     * 解析响应帧
     * 
     * @return Pair<状态码, 数据载荷>
     */
    fun parseResponse(frame: ByteArray): Pair<Byte, ByteArray>? {
        if (frame.size < 4) return null  // 最小帧: [AA][CMD][LEN][CS]
        if (frame[0] != FRAME_HEADER) return null
        
        if (!verifyChecksum(frame)) {
            return null  // 校验失败
        }
        
        val status = frame[1]  // 第二字节为状态码
        val len = frame[2].toInt() and 0xFF
        
        if (len == 0) {
            return Pair(status, byteArrayOf())
        }
        
        if (frame.size < 3 + len + 1) return null  // 数据不完整
        
        val payload = frame.copyOfRange(3, 3 + len)
        return Pair(status, payload)
    }
    
    /**
     * 构建寻卡命令
     */
    fun buildPollCardCommand(): ByteArray {
        return buildFrame(Command.POLL_CARD)
    }
    
    /**
     * 构建认证命令
     * 
     * @param sector 扇区号（0-15）
     * @param key 密钥（6字节）
     * @param useKeyA true=使用KeyA，false=使用KeyB
     */
    fun buildAuthCommand(sector: Int, key: ByteArray, useKeyA: Boolean): ByteArray {
        require(key.size == M1.KEY_LENGTH) { "密钥必须为6字节" }
        require(sector in 0..15) { "扇区号必须在0-15之间" }
        
        val payload = mutableListOf<Byte>()
        payload.add(sector.toByte())           // 扇区号
        payload.add(if (useKeyA) 0x60 else 0x61)  // 0x60=KeyA, 0x61=KeyB
        payload.addAll(key.toList())           // 6字节密钥
        
        return buildFrame(Command.AUTH_SECTOR, payload.toByteArray())
    }
    
    /**
     * 构建读块命令
     * 
     * @param block 块号（0-63 for 1K, 0-255 for 4K）
     */
    fun buildReadBlockCommand(block: Int): ByteArray {
        require(block >= 0) { "块号不能为负数" }
        
        val payload = byteArrayOf(block.toByte())
        return buildFrame(Command.READ_BLOCK, payload)
    }
    
    /**
     * 构建获取状态命令
     */
    fun buildGetStatusCommand(): ByteArray {
        return buildFrame(Command.GET_STATUS)
    }
    
    /**
     * 格式化UID显示
     */
    fun formatUid(uid: ByteArray): String {
        return uid.joinToString(":") { "%02X".format(it) }
    }
    
    /**
     * 格式化块数据显示（十六进制）
     */
    fun formatBlockData(data: ByteArray): String {
        return data.joinToString(" ") { "%02X".format(it) }
    }
}
