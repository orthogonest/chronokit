/// An ultra-fast, non-cryptographic 32-bit FNV-1a hash implementation.
/// Designed for high-performance identifier mapping with zero heap allocations.
public enum FNV1a {
    @usableFromInline static let prime32: UInt32 = 0x0100_0193
    @usableFromInline static let offset32: UInt32 = 0x811C_9DC5

    /// Computes the 32-bit FNV-1a hash code for a given sequence of raw bytes.
    /// - Parameter bytes: A sequence of unsigned 8-bit integers (e.g., raw memory or UTF-8 view).
    /// - Returns: A deterministic UInt32 integer key.
    @inlinable
    public static func hash32<S: Sequence>(_ bytes: S) -> UInt32 where S.Element == UInt8 {
        var hash = offset32
        for byte in bytes {
            hash ^= UInt32(byte)
            hash = hash &* prime32
        }
        return hash
    }

    /// Computes the 32-bit FNV-1a hash code for a given string sequence.
    /// - Parameter string: The string identifier token to process.
    /// - Returns: A deterministic UInt32 integer key.
    @inlinable
    public static func hash32(_ string: String) -> UInt32 {
        return hash32(string.utf8)
    }
}
