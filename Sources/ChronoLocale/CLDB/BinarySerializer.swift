package enum BinarySerializer {
    /// Flattens a high-level compiled CLDBLayout structure into a monolithic, hardware-aligned raw byte array.
    /// - Parameter layout: The populated layout context containing sorted indexes, packed data blocks, and strings.
    /// - Returns: A primitive `[UInt8]` array ready for storage or embedding via `embedInCode`.
    package static func serialize(_ layout: CLDBLayout) -> [UInt8] {
        let headerSize = MemoryLayout<LocaleHeaderLayout>.size
        let indexTableSize = layout.indexes.count * MemoryLayout<LocaleIndexNodeLayout>.size
        let blockArraySize = layout.blocks.count * MemoryLayout<LocaleBlockLayout>.size
        let totalStructuralSize = headerSize + indexTableSize + blockArraySize

        var outputBytes = [UInt8]()
        outputBytes.reserveCapacity(totalStructuralSize)

        var header = layout.header
        withUnsafeBytes(of: &header) { buffer in
            outputBytes.append(contentsOf: buffer)
        }

        for var indexNode in layout.indexes {
            withUnsafeBytes(of: &indexNode) { buffer in
                outputBytes.append(contentsOf: buffer)
            }
        }

        for var block in layout.blocks {
            withUnsafeBytes(of: &block) { buffer in
                outputBytes.append(contentsOf: buffer)
            }
        }

        let outputCount = outputBytes.count
        let stringPoolOffset = layout.header.stringPoolOffset
        assert(
            outputCount == stringPoolOffset,
            "Structural byte size (\(outputCount)) drifts from header.stringPoolOffset (\(stringPoolOffset))."
        )

        outputBytes.append(contentsOf: layout.stringPool)

        return outputBytes
    }
}
