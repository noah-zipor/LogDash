import AppKit

class AppServiceLauncher: AppServiceProtocol {
    func getInstalledApps(completion: @escaping ([AppEntry]) -> Void) {
        Task {
            let appDirectories = ["/Applications", "/System/Applications"]

            let allApps = await withTaskGroup(of: [AppEntry].self) { group in
                for directory in appDirectories {
                    group.addTask {
                        return self.scanDirectory(directory)
                    }
                }

                var results: [AppEntry] = []
                for await partialResult in group {
                    results.append(contentsOf: partialResult)
                }
                return results
            }

            let sortedApps = allApps.sorted(by: { $0.name < $1.name })
            await MainActor.run {
                completion(sortedApps)
            }
        }
    }

    private func scanDirectory(_ path: String) -> [AppEntry] {
        let fileManager = FileManager.default
        var results: [AppEntry] = []

        do {
            let content = try fileManager.contentsOfDirectory(atPath: path)
            for item in content where item.hasSuffix(".app") {
                let fullPath = (path as NSString).appendingPathComponent(item)
                let name = (item as NSString).deletingPathExtension

                // We don't load the icon here anymore. It's too slow.
                // The icon will be fetched dynamically in the View.
                results.append(AppEntry(
                    name: name,
                    bundleIdentifier: fullPath,
                    icon: nil
                ))
            }
        } catch {
            print("Error scanning \(path): \(error)")
        }
        return results
    }

    func launchApp(app: AppEntry) {
        let url = URL(fileURLWithPath: app.bundleIdentifier)
        let configuration = NSWorkspace.OpenConfiguration()

        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { (app, error) in
            if let error = error {
                print("Failed to launch app: \(error.localizedDescription)")
            }
        }
    }
}
