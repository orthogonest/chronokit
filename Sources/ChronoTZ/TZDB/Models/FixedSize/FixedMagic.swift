@frozen
package struct FixedMagic {
    @usableFromInline package static let size: Int = 4

    @usableFromInline package let data: (UInt8, UInt8, UInt8, UInt8)

    @usableFromInline
    @inline(__always)
    package init() {
        data = (0, 0, 0, 0)
    }

    @usableFromInline
    @inline(__always)
    package init(
        buffer: UnsafeBufferPointer<UInt8>
    ) {
        var data = (UInt8(0), UInt8(0), UInt8(0), UInt8(0))

        withUnsafeMutableBytes(of: &data) { ptr in
            let count = min(buffer.count, Self.size)
            ptr.copyBytes(from: buffer.prefix(count))
        }

        self.data = data
    }

    @usableFromInline
    @inline(__always)
    package init(
        bytes: [UInt8]
    ) {
        var data = (UInt8(0), UInt8(0), UInt8(0), UInt8(0))

        withUnsafeMutableBytes(of: &data) { ptr in
            let count = min(bytes.count, Self.size)
            ptr.copyBytes(from: bytes.prefix(count))
        }

        self.data = data
    }
}

package extension FixedMagic {
    @usableFromInline static let tzdb = Self(bytes: [0x54, 0x5A, 0x44, 0x42])
}

extension FixedMagic: Equatable {
    @usableFromInline
    @inline(__always)
    package static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs.data) { lhsData in
            withUnsafeBytes(of: rhs.data) { rhsData in
                lhsData.elementsEqual(rhsData)
            }
        }
    }
}

extension FixedMagic: Hashable {
    @usableFromInline
    @inline(__always)
    package func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: data) { buffer in
            hasher.combine(bytes: buffer)
        }
    }
}
