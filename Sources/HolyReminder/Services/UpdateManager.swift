import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let body: String
    let prerelease: Bool
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case body
        case prerelease
    }
}

struct UpdateInfo {
    let version: String
    let url: URL
    let changelog: String
    let isPrerelease: Bool
}

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var availableUpdate: UpdateInfo?
    @Published var isChecking: Bool = false
    @Published var lastError: String?
    
    private let repoOwner = "lou1s19"
    private let repoName = "Holy-Reminder"
    
    private init() {}
    
    var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func checkForUpdates(manual: Bool = false) {
        guard !isChecking else { return }
        isChecking = true
        lastError = nil
        
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else {
            self.isChecking = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isChecking = false
                
                if let error = error {
                    if manual { self?.lastError = "Netzwerkfehler: \(error.localizedDescription)" }
                    print("❌ Update check failed: \(error)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                    self?.handleRelease(release, manual: manual)
                } catch {
                    if manual { self?.lastError = "Fehler beim Lesen der Serverantwort." }
                    print("❌ JSON decode error: \(error)")
                }
            }
        }.resume()
    }
    
    private func handleRelease(_ release: GitHubRelease, manual: Bool) {
        let serverVersionString = release.tagName.replacingOccurrences(of: "v", with: "")
        let currentVersionString = self.currentVersion
        
        if isVersion(serverVersionString, newerThan: currentVersionString) {
            print("✅ New version available: \(serverVersionString)")
            if let url = URL(string: release.htmlUrl) {
                self.availableUpdate = UpdateInfo(
                    version: release.tagName,
                    url: url,
                    changelog: release.body,
                    isPrerelease: release.prerelease
                )
            }
        } else {
            print("INFO: App is up to date (\(currentVersionString))")
            if manual {
                self.lastError = "Du hast die neueste Version (\(currentVersionString))."
            }
        }
    }
    
    private func isVersion(_ v1: String, newerThan v2: String) -> Bool {
        return v1.compare(v2, options: .numeric) == .orderedDescending
    }
}
