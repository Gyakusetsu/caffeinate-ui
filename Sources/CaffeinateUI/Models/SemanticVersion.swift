import Foundation

struct SemanticVersion: Comparable, Equatable {
    let major: Int
    let minor: Int
    let patch: Int

    init?(string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        let stripped = trimmed.hasPrefix("v") ? String(trimmed.dropFirst()) : trimmed
        let parts = stripped.split(separator: ".").compactMap { Int($0) }
        guard parts.count >= 2, parts.count <= 3 else { return nil }
        self.major = parts[0]
        self.minor = parts[1]
        self.patch = parts.count == 3 ? parts[2] : 0
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}
