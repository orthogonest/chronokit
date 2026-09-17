import ChronoSystem

struct TimeZoneRegistry {
    private let buffer: [UInt8]
    private let header: TZDBHeader
    private let indexEntries: [TZDBIndexEntry]
}

extension TimeZoneRegistry {
    var indexNames: [String] {
        indexEntries.map(\.nameString)
    }
}

extension TimeZoneRegistry {
    init(bytes: [UInt8]) throws {
        buffer = bytes

        var decodedHeader: TZDBHeader?
        var decodedEntries: [TZDBIndexEntry] = []

        try buffer.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                throw TZDBError.invalidHeader
            }

            var reader = BinaryReader(ptr: baseAddress, capacity: buffer.count)

            // Header
            let magic = try reader.readBytes(count: TZDBHeader.ianaMagicSize)
            let version = try reader.readBigEndian(UInt32.self)
            let count = try reader.readBigEndian(UInt32.self)
            let header = TZDBHeader(magic: magic, version: version, count: count)
            guard header.magic == .tzdb else { throw TZDBError.invalidHeader }
            decodedHeader = header

            // Index Entry
            var tempIndexEntries: [TZDBIndexEntry] = []
            tempIndexEntries.reserveCapacity(Int(header.count))
            for _ in 0 ..< Int(header.count) {
                let name = try reader.readBytes(count: TZDBIndexEntry.nameSize)
                let offset = try reader.readBigEndian(UInt32.self)
                let size = try reader.readBigEndian(UInt32.self)
                let entry = TZDBIndexEntry(name: name, offset: offset, size: size)
                tempIndexEntries.append(entry)
            }
            decodedEntries = tempIndexEntries
        }

        guard let decodedHeader else { throw TZDBError.invalidHeader }

        header = decodedHeader
        indexEntries = decodedEntries
    }

    func getEntry(named name: String) -> TZDBIndexEntry? {
        return indexEntries.first {
            $0.nameString == name
        }
    }

    func getPayload(for entry: TZDBIndexEntry) throws -> [UInt8] {
        let offset = Int(entry.offset)
        let size = Int(entry.size)

        guard offset + size <= buffer.count else {
            throw FileSystemError.outOfBounds
        }

        return Array(buffer[offset ..< (offset + size)])
    }
}
