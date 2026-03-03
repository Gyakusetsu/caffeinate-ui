import Foundation

enum UpdateStatus: Equatable {
    case unknown
    case upToDate
    case updateAvailable(latestVersion: String, url: URL)
}

protocol UpdateCheckerServiceProtocol {
    func checkForUpdate() async -> UpdateStatus
}

final class UpdateCheckerService: UpdateCheckerServiceProtocol {
    private let currentVersion: String
    private let session: URLSession

    init(currentVersion: String? = nil, session: URLSession = .shared) {
        self.currentVersion = currentVersion
            ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "0.0.0"
        self.session = session
    }

    func checkForUpdate() async -> UpdateStatus {
        guard let url = URL(string: "https://api.github.com/repos/Gyakusetsu/caffeinate-ui/releases/latest") else {
            return .unknown
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return .unknown
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)

            guard let current = SemanticVersion(string: currentVersion),
                  let latest = SemanticVersion(string: release.tagName) else {
                return .unknown
            }

            if current < latest {
                let releaseURL = URL(string: release.htmlUrl)
                    ?? URL(string: "https://github.com/Gyakusetsu/caffeinate-ui/releases")!
                return .updateAvailable(latestVersion: release.tagName, url: releaseURL)
            }

            return .upToDate
        } catch {
            return .unknown
        }
    }
}

private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
    }
}
