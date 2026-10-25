import Cocoa
import Carbon
import ServiceManagement

let overrides: [String: String] = [
    "en": "GB",
]

func flagEmoji(_ region: String) -> String {
    region.uppercased().unicodeScalars
        .compactMap { UnicodeScalar(0x1F1E6 - 0x41 + $0.value) }
        .map(String.init).joined()
}

func region(forLanguage lang: String) -> String? {
    if let r = overrides[lang] { return r }
    let full = Locale.Language(identifier: lang).maximalIdentifier  
    return Locale.Language(identifier: full).region?.identifier
}

func stringProp(_ src: TISInputSource, _ key: CFString) -> String? {
    guard let ptr = TISGetInputSourceProperty(src, key) else { return nil }
    return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
}
func sourceID(_ src: TISInputSource) -> String { stringProp(src, kTISPropertyInputSourceID) ?? "" }
func sourceName(_ src: TISInputSource) -> String { stringProp(src, kTISPropertyLocalizedName) ?? "?" }

func language(_ src: TISInputSource) -> String {
    guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceLanguages) else { return "" }
    let langs = Unmanaged<CFArray>.fromOpaque(ptr).takeUnretainedValue() as? [String] ?? []
    return langs.first ?? ""
}

func flag(for src: TISInputSource) -> String {
    guard let r = region(forLanguage: language(src)) else { return "⌨️" }
    return flagEmoji(r)
}

func keyboardSources() -> [TISInputSource] {
    let filter: [CFString: Any] = [
        kTISPropertyInputSourceCategory!: kTISCategoryKeyboardInputSource!,
        kTISPropertyInputSourceIsSelectCapable!: true,
    ]
    guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() else { return [] }
    return (list as NSArray).map { $0 as! TISInputSource }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ note: Notification) {
        refresh()
        for name in [kTISNotifySelectedKeyboardInputSourceChanged as String,
                     "AppleSelectedInputSourcesChangedNotification"] {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(changed),
                name: NSNotification.Name(name), object: nil, suspensionBehavior: .deliverImmediately)
        }
    }

    @objc func changed() {
        refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { self.refresh() }
    }

    func refresh() {
        let current = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let currentID = sourceID(current)
        item.button?.title = flag(for: current)
        item.button?.toolTip = sourceName(current)

        let menu = NSMenu()
        for src in keyboardSources() {
            let mi = NSMenuItem(title: "\(flag(for: src))  \(sourceName(src))",
                                action: #selector(select(_:)), keyEquivalent: "")
            mi.target = self
            mi.representedObject = src
            mi.state = (sourceID(src) == currentID) ? .on : .off
            menu.addItem(mi)
        }
        menu.addItem(.separator())

        let login = NSMenuItem(title: "Open at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(login)

        menu.addItem(NSMenuItem(title: "Quit FlagBar",
                                action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
    }

    @objc func select(_ sender: NSMenuItem) {
        TISSelectInputSource((sender.representedObject as! TISInputSource))
    }

    @objc func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change the login setting"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        refresh()
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory) 
let delegate = AppDelegate()
app.delegate = delegate
app.run()
