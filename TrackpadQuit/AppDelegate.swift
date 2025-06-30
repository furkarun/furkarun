import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var gestureMonitor: MultiTouchMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // run without dock icon
        NSApp.setActivationPolicy(.accessory)
        gestureMonitor = MultiTouchMonitor { [weak self] in
            self?.quitFrontmostApplication()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        gestureMonitor = nil
    }

    private func quitFrontmostApplication() {
        if let app = NSWorkspace.shared.frontmostApplication {
            app.terminate()
        }
    }
}
