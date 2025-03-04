/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class AsianLocaleTest: BaseTestCase {
	func testSearchinLocale() {
        dismissURLBarFocused()
        waitForExistence(app.buttons["HomeView.settingsButton"], timeout: 10)
        // Set search engine to Google
		app.buttons["HomeView.settingsButton"].tap()
        app.tables.cells["Settings"].tap()
        waitForExistence(app.tables.cells["SettingsViewController.searchCell"])
		app.tables.cells["SettingsViewController.searchCell"].tap()

		app.tables.staticTexts["Google"].tap()
        app.buttons["SettingsViewController.doneButton"].tap()

		// Enter 'mozilla' on the search field
		search(searchWord: "모질라")
        app.buttons["URLBar.deleteButton"].tap()
        dismissURLBarFocused()
        checkForHomeScreen()

		search(searchWord: "モジラ")
        app.buttons["URLBar.deleteButton"].tap()
        dismissURLBarFocused()
        checkForHomeScreen()

		search(searchWord: "因特網")
        app.buttons["URLBar.deleteButton"].tap()
        dismissURLBarFocused()
        checkForHomeScreen()
	}

}
