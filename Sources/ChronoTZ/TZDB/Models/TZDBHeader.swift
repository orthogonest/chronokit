package struct TZDBHeader: Equatable, Hashable {
    @usableFromInline package var magic: FixedMagic
    @usableFromInline package var version: UInt32
    @usableFromInline package var count: UInt32

    @usableFromInline
    @inline(__always)
    package init(
        magic: FixedMagic,
        version: UInt32,
        count: UInt32
    ) {
        self.magic = magic
        self.version = version
        self.count = count
    }

    @usableFromInline
    @inline(__always)
    package init(
        magic: UnsafeBufferPointer<UInt8>,
        version: UInt32,
        count: UInt32
    ) {
        self.magic = FixedMagic(buffer: magic)
        self.version = version
        self.count = count
    }

    @usableFromInline
    @inline(__always)
    package init(
        magic: [UInt8],
        version: UInt32,
        count: UInt32
    ) {
        self.magic = FixedMagic(bytes: magic)
        self.version = version
        self.count = count
    }
}

package extension TZDBHeader {
    @usableFromInline static let ianaMagicSize: Int = FixedMagic.size
    @usableFromInline static let ianaVersionSize: Int = 4
    @usableFromInline static let ianaCountSize: Int = 4
    @usableFromInline static let ianaSize: Int = ianaMagicSize + ianaVersionSize + ianaCountSize

    @usableFromInline
    @inline(__always)
    static func iana(tableSize: Int) -> Self {
        Self(
            magic: .tzdb,
            version: UInt32(1).bigEndian,
            count: UInt32(tableSize).bigEndian
        )
    }
}
