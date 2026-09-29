package struct TZDBDataPayload: Equatable, Hashable {
    @usableFromInline package let transitionCount: UInt32
    @usableFromInline package let typeCount: UInt32
    @usableFromInline package let transitions: [TZDBTransition]
    @usableFromInline package let types: [TZDBTypeDefinition]
    @usableFromInline package let posixRule: String?
    @usableFromInline package let compiledPosixRule: POSIXRule?
    @usableFromInline package let stdType: TZDBTypeDefinition?
    @usableFromInline package let dstType: TZDBTypeDefinition?

    @usableFromInline
    package init(
        transitionCount: UInt32,
        typeCount: UInt32,
        transitions: [TZDBTransition],
        types: [TZDBTypeDefinition],
        posixRule: String? = nil
    ) {
        self.transitionCount = transitionCount
        self.typeCount = typeCount
        self.transitions = transitions
        self.types = types
        self.posixRule = posixRule

        let rule = posixRule.flatMap(POSIXRule.init(rawValue:))
        compiledPosixRule = rule

        if let rule {
            stdType = try? TZDBTypeDefinition(offset: rule.stdOffset, isDST: 0)
            dstType = try? TZDBTypeDefinition(offset: rule.dstOffset, isDST: 1)
        } else {
            stdType = nil
            dstType = nil
        }
    }
}

extension TZDBDataPayload {
    func resolve(at timestamp: Int64) -> ResolvedOffset {
        // Resolve transitions is empty
        if transitions.isEmpty {
            if let rule = compiledPosixRule,
               let std = stdType,
               let dst = dstType
            {
                return resolvePOSIXState(at: timestamp, rule: rule, std: std, dst: dst)
            }

            return types.first.map { .unique($0) } ?? .invalid
        }

        // Resolve within transitions range
        if let firstTransition = transitions.first,
           let lastTransition = transitions.last,
           timestamp >= firstTransition.unixTime,
           timestamp <= lastTransition.unixTime,
           let index = findTransitionIndex(for: timestamp)
        {
            let typeIndex = transitions[index].typeIndex
            return .unique(types[Int(typeIndex)])
        }

        // Resolve after last transition (with POSIX rule)
        if let lastTransition = transitions.last,
           timestamp > lastTransition.unixTime
        {
            if let rule = compiledPosixRule,
               let std = stdType,
               let dst = dstType
            {
                return resolvePOSIXState(at: timestamp, rule: rule, std: std, dst: dst)
            }

            let idx = Int(lastTransition.typeIndex)
            if idx < types.count {
                return .unique(types[idx])
            }

            return types.last.map { .unique($0) } ?? .invalid
        }

        // Resolve before first transition range
        return types.first.map { .unique($0) } ?? .invalid
    }

    private func resolvePOSIXState(
        at timestamp: Int64,
        rule: POSIXRule,
        std: TZDBTypeDefinition,
        dst: TZDBTypeDefinition
    ) -> ResolvedOffset {
        let state = POSIXRuleResolver.resolveState(at: timestamp, rule: rule)
        switch state {
        case .ambiguous:
            return .ambiguous(earlier: dst, later: std)
        case .gap:
            return .gap
        case .standard:
            return .unique(std)
        case .dst:
            return .unique(dst)
        }
    }

    func findTransitionIndex(for timestamp: Int64) -> Int? {
        var low = 0
        var high = transitions.count - 1
        var candidateIndex: Int?

        while low <= high {
            let mid = low &+ ((high &- low) &>> 1)

            if transitions[mid].unixTime <= timestamp {
                candidateIndex = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return candidateIndex
    }
}

package struct TZDBTransition: Equatable, Hashable {
    @usableFromInline package let unixTime: Int64
    @usableFromInline package let typeIndex: UInt8

    /// RFC 8536 Section 3.2.: unixTime SHOULD be at lease -2^59
    ///
    /// -2**59 is the greatest negated power of 2 that predates the Big
    /// Bang, and avoiding earlier timestamps works around known TZif
    /// reader bugs relating to outlandishly negative timestamps
    @usableFromInline
    @inline(__always)
    package init(
        unixTime: Int64,
        typeIndex: UInt8
    ) throws {
        let minTransitionTime: Int64 = -(1 << 59)

        guard unixTime >= minTransitionTime else {
            throw TZDBError.invalidTransitionTime
        }

        self.unixTime = unixTime
        self.typeIndex = typeIndex
    }
}

extension TZDBTransition {
    @usableFromInline static let size: Int = 8 + 1
}

package struct TZDBTypeDefinition: Equatable, Hashable {
    @usableFromInline package let offset: Int32 // Second from UTC
    @usableFromInline package let isDST: UInt8 // Standard = 0; DST = 1

    /// RFC 8536 Section 3.2.: utoff MUST NOT be -2^31 (Int32.min) and SHOULD be in range [-89999, 93599]
    @usableFromInline
    @inline(__always)
    package init(
        offset: Int32,
        isDST: UInt8
    ) throws {
        guard offset != .min else {
            throw TZDBError.invalidUTOffset
        }

        guard offset >= -89999, offset <= 93599 else {
            throw TZDBError.unsupportedOffsetRange
        }

        self.offset = offset
        self.isDST = isDST
    }
}

extension TZDBTypeDefinition {
    @usableFromInline static let size: Int = 4 + 1
}

package enum ResolvedOffset {
    case unique(TZDBTypeDefinition)
    case ambiguous(earlier: TZDBTypeDefinition, later: TZDBTypeDefinition)
    case gap
    case invalid
}
