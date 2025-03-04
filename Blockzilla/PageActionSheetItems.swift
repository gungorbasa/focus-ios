/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Telemetry
import Glean

class PageActionSheetItems {

    let app = UIApplication.shared
    let url: URL!

    init(url: URL) {
        self.url = url
    }

    var canOpenInFirefox: Bool {
        return app.canOpenURL(URL(string: "firefox://")!)
    }

    var canOpenInChrome: Bool {
        return app.canOpenURL(URL(string: "googlechrome://")!)
    }
    
    var canAddToShortcuts: Bool {
        let shortcut = Shortcut(url: self.url)
        return ShortcutsManager.shared.canSave(shortcut: shortcut)
    }
    
    lazy var addToShortcutsItem = PhotonActionSheetItem(title: UIConstants.strings.shareMenuAddToShortcuts, iconString: "icon_shortcuts_add") { action in
        let shortcut = Shortcut(url: self.url)
        ShortcutsManager.shared.addToShortcuts(shortcut: shortcut)
        GleanMetrics.Shortcuts.shortcutAddedCounter.add()
        TipManager.shortcutsTip = false
    }
    
    lazy var removeFromShortcutsItem = PhotonActionSheetItem(title: UIConstants.strings.shareMenuRemoveFromShortcuts, iconString: "icon_shortcuts_remove") { action in
        let shortcut = Shortcut(url: self.url)
        ShortcutsManager.shared.removeFromShortcuts(shortcut: shortcut)
        GleanMetrics.Shortcuts.shortcutRemovedCounter["removed_from_browser_menu"].add()
    }

    lazy var openInFireFoxItem = PhotonActionSheetItem(title: UIConstants.strings.shareOpenInFirefox, iconString: "open_in_firefox_icon") { action in
        guard let escaped = self.url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowed),
            let firefoxURL = URL(string: "firefox://open-url?url=\(escaped)&private=true"),
            self.app.canOpenURL(firefoxURL) else {
                return
        }

        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.open, object: TelemetryEventObject.menu, value: "firefox")
        self.app.open(firefoxURL, options: [:])
    }

    lazy var openInChromeItem = PhotonActionSheetItem(title: UIConstants.strings.shareOpenInChrome, iconString: "open_in_chrome_icon") { action in
        // Code pulled from https://github.com/GoogleChrome/OpenInChrome
        // Replace the URL Scheme with the Chrome equivalent.
        var chromeScheme: String?
        if self.url.scheme == "http" {
            chromeScheme = "googlechrome"
        } else if self.url.scheme == "https" {
            chromeScheme = "googlechromes"
        }

        // Proceed only if a valid Google Chrome URI Scheme is available.
        guard let scheme = chromeScheme,
            let rangeForScheme = self.url.absoluteString.range(of: ":"),
            let chromeURL = URL(string: scheme + self.url.absoluteString[rangeForScheme.lowerBound...]) else { return }

        // Open the URL with Chrome.
        self.app.open(chromeURL, options: [:])
    }

    lazy var openInDefaultBrowserItem = PhotonActionSheetItem(title: UIConstants.strings.shareOpenInDefaultBrowser, iconString: "icon_favicon") { action in
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.open, object: TelemetryEventObject.menu, value: "default")
        self.app.open(self.url, options: [:])
    }

    lazy var findInPageItem = PhotonActionSheetItem(title: UIConstants.strings.shareMenuFindInPage, iconString: "icon_searchfor") { action in
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UIConstants.strings.findInPageNotification)))
    }

    lazy var requestDesktopItem = PhotonActionSheetItem(title: UIConstants.strings.shareMenuRequestDesktop, iconString: "request_desktop_site_activity") { action in
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.requestDesktop)
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UIConstants.strings.requestDesktopNotification)))
    }

    lazy var requestMobileItem = PhotonActionSheetItem(title: UIConstants.strings.shareMenuRequestMobile, iconString: "request_mobile_site_activity") { action in
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.requestMobile)
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: UIConstants.strings.requestMobileNotification)))
    }
}
