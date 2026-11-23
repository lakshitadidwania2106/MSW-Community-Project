import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Phone-shaped window so the app previews like a mobile device
    let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
    let h = min(940, screen.height - 20)
    self.setFrame(NSRect(x: screen.midX - 230, y: screen.midY - h / 2, width: 460, height: h), display: true)
    self.title = "MSW Community"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
