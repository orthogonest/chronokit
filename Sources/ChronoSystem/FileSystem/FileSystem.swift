#if canImport(Darwin)
    import Darwin
    import MachO
#elseif canImport(Bionic)
    @preconcurrency import Bionic
#elseif canImport(Glibc)
    @preconcurrency import Glibc
#elseif canImport(Musl)
    @preconcurrency import Musl
#elseif os(Windows)
    @preconcurrency import ucrt
#elseif os(WASI)
    @preconcurrency import WASILibc
#elseif os(Emscripten)
    @preconcurrency import EmscriptenLibc
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

// MARK: - File Operations

package enum FileSystem {
    package static func openFile(_ path: String, mode: FileMode) throws -> Int32 {
        let fd = path.withCString { cPath in
            open(cPath, mode.flags, mode.mode)
        }
        guard fd != -1 else { throw FileSystemError.openFileFailed(errno) }
        return fd
    }

    package static func closeFile(_ fd: Int32) {
        _ = close(fd)
    }

    #if os(Windows)
        package static func fsyncFile(_ fd: Int32) throws {
            let result = _commit(fd)
            if result == -1 { throw FileSystemError.syncFailed(errno) }
        }
    #else
        package static func fsyncFile(_ fd: Int32) throws {
            let result = fsync(fd)
            if result == -1 { throw FileSystemError.syncFailed(errno) }
        }
    #endif

    package static func renameFile(from: String, to: String) throws {
        let result = from.withCString { cFrom in
            to.withCString { cTo in
                rename(cFrom, cTo)
            }
        }
        if result == -1 { throw FileSystemError.renameFailed(errno) }
    }

    #if os(Windows)
        package static func readFile(_ fd: Int32, buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
            let result = Int(Int32(_read(fd, buffer, UInt32(count))))
            guard result != -1 else { throw FileSystemError.readFileFailed(errno) }
            return result
        }
    #else
        package static func readFile(_ fd: Int32, buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
            let result = read(fd, buffer, count)
            guard result != -1 else { throw FileSystemError.readFileFailed(errno) }
            return result
        }
    #endif

    #if os(Windows)
        package static func writeFile(_ fd: Int32, buffer: UnsafeRawPointer?, count: Int) throws {
            let result = _write(fd, buffer, UInt32(count))
            guard result != -1 else { throw FileSystemError.writeFileFailed(errno) }
        }
    #else
        package static func writeFile(_ fd: Int32, buffer: UnsafeRawPointer?, count: Int) throws {
            let result = write(fd, buffer, count)
            guard result != -1 else { throw FileSystemError.writeFileFailed(errno) }
        }
    #endif
}

// MARK: - Metadata

package extension FileSystem {
    #if os(Windows)
        static func getFileSize(path: String) throws -> Int {
            var st = _stat64()
            let result = path.withCString { cPath in _stat64(cPath, &st) }
            guard result == 0 else { throw FileSystemError.fileNotFound(errno) }
            return Int(st.st_size)
        }
    #else
        static func getFileSize(path: String) throws -> Int {
            var st = stat()
            let result = path.withCString { cPath in stat(cPath, &st) }
            guard result == 0 else { throw FileSystemError.fileNotFound(errno) }
            return Int(st.st_size)
        }
    #endif

    #if os(Windows)
        static func getFileSize(_ fd: Int32) throws -> Int {
            var st = _stat64()
            guard _fstat64(fd, &st) == 0 else { throw FileSystemError.fileNotFound(errno) }
            return Int(st.st_size)
        }
    #else
        static func getFileSize(_ fd: Int32) throws -> Int {
            var st = stat()
            guard fstat(fd, &st) == 0 else { throw FileSystemError.fileNotFound(errno) }
            return Int(st.st_size)
        }
    #endif
}

// MARK: - Directory Operations

#if !os(Windows)
    extension FileSystem {
        private static func openDirectory(_ path: String) throws -> UnsafeMutablePointer<DIR> {
            let dir = path.withCString { cPath in
                opendir(cPath)
            }
            guard let dir else { throw FileSystemError.openDirectoryFailed(path: path, code: errno) }
            return dir
        }

        package static func listDirectory(at path: String, body: (String, Bool) throws -> Void) throws {
            let dir = try openDirectory(path)
            defer { closedir(dir) }

            while let ptr = readdir(dir) {
                let name = String(ptr: ptr)

                if name == "." || name == ".." { continue }

                var isDir = ptr.pointee.d_type == UInt8(DT_DIR)

                if ptr.pointee.d_type == 0 {
                    let fullPath = path.hasSuffix("/") ? "\(path)\(name)" : "\(path)/\(name)"
                    var st = stat()
                    if fullPath.withCString({ cPath in stat(cPath, &st) }) == 0 {
                        // S_ISDIR check: (mode & S_IFMT) == S_IFDIR
                        isDir = (st.st_mode & 0o170000) == 0o040000
                    }
                }

                try body(name, isDir)
            }
        }
    }

    // MARK: - Helpers

    extension String {
        init(ptr: UnsafeMutablePointer<dirent>) {
            let namePtr = withUnsafePointer(to: &ptr.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MemoryLayout.size(ofValue: ptr.pointee.d_name))
                ) {
                    $0
                }
            }
            self.init(cString: namePtr)
        }
    }
#endif
