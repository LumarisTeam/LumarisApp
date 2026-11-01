import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // Keep in sync with MacosShell's 52px header and 80px traffic-light inset.
  private let flutterToolbarHeight: CGFloat = 52
  private let windowControlsWidth: CGFloat = 80
  private weak var toolbarFlutterController: FlutterViewController?
  private var forwardingToolbarDrag = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    toolbarFlutterController = flutterViewController

    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    styleMask.insert(.fullSizeContentView)
    isMovableByWindowBackground = false

    // AppKit positions the native traffic lights in the unified toolbar row.
    // Flutter paints the toolbar itself through the transparent title bar.
    let windowToolbar = NSToolbar(identifier: "FlutterWindowToolbar")
    windowToolbar.allowsUserCustomization = false
    windowToolbar.showsBaselineSeparator = false
    toolbar = windowToolbar
    if #available(macOS 11.0, *) {
      toolbarStyle = .unified
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override func sendEvent(_ event: NSEvent) {
    let point = event.locationInWindow
    let inFlutterToolbar = point.x >= windowControlsWidth
      && point.y >= frame.height - flutterToolbarHeight

    // AppKit normally intercepts clicks in a transparent title bar. Forward
    // only the Flutter header area; native window buttons keep AppKit events.
    if let controller = toolbarFlutterController {
      switch event.type {
      case .leftMouseDown where inFlutterToolbar:
        if !NSApp.isActive {
          NSApp.activate(ignoringOtherApps: true)
        }
        makeKeyAndOrderFront(nil)
        forwardingToolbarDrag = true
        controller.mouseDown(with: event)
        return
      case .leftMouseDragged where forwardingToolbarDrag:
        controller.mouseDragged(with: event)
        return
      case .leftMouseUp where forwardingToolbarDrag:
        forwardingToolbarDrag = false
        controller.mouseUp(with: event)
        return
      case .rightMouseDown where inFlutterToolbar:
        controller.rightMouseDown(with: event)
        return
      case .rightMouseUp where inFlutterToolbar:
        controller.rightMouseUp(with: event)
        return
      case .mouseMoved where inFlutterToolbar:
        controller.mouseMoved(with: event)
        return
      default:
        break
      }
    }
    super.sendEvent(event)
  }
}
