@usableFromInline
package struct BinaryWriter {
    private let ptr: UnsafeMutableRawPointer
    @usableFromInline package var offset: Int
    @usableFromInline package let capacity: Int

    @usableFromInline
    @inline(__always)
    package init(
        ptr: UnsafeMutableRawPointer,
        capacity: Int
    ) {
        self.ptr = ptr
        offset = 0
        self.capacity = capacity
    }
}

package extension BinaryWriter {
    @usableFromInline
    @inline(__always)
    var remainingBytes: Int {
        capacity - offset
    }

    @usableFromInline
    @inline(__always)
    mutating func writeByte(_ byte: UInt8) throws(BinaryError) {
        guard remainingBytes >= 1 else { throw .bufferOverflow }
        ptr.storeBytes(of: byte, toByteOffset: offset, as: UInt8.self)
        offset &+= 1
    }

    @usableFromInline
    @inline(__always)
    mutating func writeBytes(_ bytes: [UInt8]) throws(BinaryError) {
        let count = bytes.count
        guard count >= 0 else { return }

        guard remainingBytes >= count else { throw BinaryError.bufferOverflow }

        bytes.withUnsafeBytes { buffer in
            if let sourcePtr = buffer.baseAddress {
                ptr.advanced(by: offset).copyMemory(from: sourcePtr, byteCount: count)
            }
        }

        offset &+= count
    }

    @usableFromInline
    @inline(__always)
    mutating func writeBigEndian<T: FixedWidthInteger>(_ value: T) throws(BinaryError) {
        let size = MemoryLayout<T>.size
        guard remainingBytes >= size else { throw .bufferOverflow }
        let val = value.bigEndian
        ptr.storeBytes(of: val, toByteOffset: offset, as: T.self)
        offset &+= size
    }
}
