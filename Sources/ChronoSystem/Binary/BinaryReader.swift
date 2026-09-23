@usableFromInline
package struct BinaryReader {
    private let ptr: UnsafeRawPointer
    @usableFromInline package var offset: Int
    @usableFromInline package let capacity: Int

    @usableFromInline
    package init(
        ptr: UnsafeRawPointer,
        capacity: Int
    ) {
        self.ptr = ptr
        offset = 0
        self.capacity = capacity
    }
}

package extension BinaryReader {
    @usableFromInline
    @inline(__always)
    var remainingBytes: Int {
        capacity - offset
    }

    @usableFromInline
    @inline(__always)
    mutating func readBytes(count: Int) throws(BinaryError) -> UnsafeBufferPointer<UInt8> {
        guard remainingBytes >= count else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: count)
        offset &+= count
        return buffer
    }

    @usableFromInline
    @inline(__always)
    mutating func readByte() throws(BinaryError) -> UInt8 {
        guard remainingBytes >= 1 else { throw .prematureEOF }
        let value = ptr.load(fromByteOffset: offset, as: UInt8.self)
        offset &+= 1
        return value
    }

    @usableFromInline
    @inline(__always)
    mutating func read<T>(_: T.Type) throws(BinaryError) -> T {
        let size = MemoryLayout<T>.size
        guard remainingBytes >= size else { throw .prematureEOF }
        let value = ptr.loadUnaligned(fromByteOffset: offset, as: T.self)
        offset &+= size
        return value
    }

    @usableFromInline
    @inline(__always)
    mutating func readBigEndian<T: FixedWidthInteger>(_: T.Type) throws(BinaryError) -> T {
        let value = try read(T.self)
        return T(bigEndian: value)
    }

    @usableFromInline
    @inline(__always)
    mutating func readString(length: Int) throws(BinaryError) -> String {
        guard remainingBytes >= length else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: length)
        let value = String(decoding: buffer, as: UTF8.self)
        offset &+= length
        return value
    }

    @usableFromInline
    @inline(__always)
    mutating func readString(length: UInt32) throws(BinaryError) -> String {
        try readString(length: Int(length))
    }

    @usableFromInline
    @inline(__always)
    func peekBytes(count: Int) throws(BinaryError) -> UnsafeBufferPointer<UInt8> {
        guard remainingBytes >= count else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        return UnsafeBufferPointer(start: start, count: count)
    }

    @usableFromInline
    @inline(__always)
    mutating func skip(bytes: Int) throws(BinaryError) {
        guard remainingBytes >= bytes else { throw .prematureEOF }
        offset &+= bytes
    }

    mutating func skipUntil(bytes: [UInt8]) throws(BinaryError) -> Bool {
        let count = bytes.count

        while remainingBytes >= count {
            let next = try peekBytes(count: count)
            if next.elementsEqual(bytes) {
                return true
            }
            try skip(bytes: 1)
        }

        return false
    }
}
