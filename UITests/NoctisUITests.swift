import XCTest

final class NoctisUITests: XCTestCase {
    @MainActor private func application(milestone: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["NOCTIS_TEST_SESSION"] = UUID().uuidString
        if milestone { app.launchEnvironment["NOCTIS_TEST_MILESTONE"] = "1" }
        app.launch()
        XCTAssertTrue(app.staticTexts["Сегодня"].waitForExistence(timeout: 15))
        return app
    }

    @MainActor func testNavigationAndHabitPersistence() {
        let app = application()
        capture(app, "01-home-obsidian")
        app.buttons["tab_character"].tap()
        XCTAssertTrue(app.staticTexts["ЛИЧНЫЙ ПРОГРЕСС"].waitForExistence(timeout: 5))
        capture(app, "02-profile")
        app.buttons["tab_chronicle"].tap()
        XCTAssertTrue(app.staticTexts["Календарь активности"].waitForExistence(timeout: 5))
        capture(app, "03-history")
        app.buttons["tab_sanctuary"].tap()
        XCTAssertTrue(app.staticTexts["Тема оформления"].waitForExistence(timeout: 5))
        app.buttons["tab_rituals"].tap()
        reveal(app.buttons["Добавить привычку"], in: app)
        app.buttons["Добавить привычку"].tap()
        let name = app.textFields["ritualTitle"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Тестовая привычка")
        reveal(app.buttons["saveRitual"], in: app)
        app.buttons["saveRitual"].tap()
        XCTAssertTrue(app.staticTexts["Сегодня"].waitForExistence(timeout: 5))
        let complete = app.buttons["Выполнить: Тестовая привычка"]
        reveal(complete, in: app)
        complete.tap()
        XCTAssertTrue(app.buttons["Отменить выполнение: Тестовая привычка"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        let undo = app.buttons["Отменить выполнение: Тестовая привычка"]
        reveal(undo, in: app)
        XCTAssertTrue(undo.waitForExistence(timeout: 10))
        undo.tap()
        XCTAssertTrue(complete.exists)
        app.buttons["Действия с привычкой Тестовая привычка"].tap()
        app.buttons["В архив"].tap()
        app.buttons["В архив"].tap()
        XCTAssertTrue(complete.waitForNonExistence(timeout: 5))
        app.buttons["tab_sanctuary"].tap()
        let restore = app.buttons["Восстановить Тестовая привычка"]
        reveal(restore, in: app)
        restore.tap()
        app.buttons["tab_rituals"].tap()
        let restored = app.buttons["Выполнить: Тестовая привычка"]
        reveal(restored, in: app)
        XCTAssertTrue(restored.exists)
    }

    @MainActor func testAllThemesAndPersistence() {
        let app = application()
        for theme in ["graphite", "midnight", "paper", "obsidian"] {
            app.buttons["tab_sanctuary"].tap()
            let button = app.buttons["theme_\(theme)"]
            XCTAssertTrue(button.waitForExistence(timeout: 5))
            button.tap()
            XCTAssertTrue(button.isSelected)
            capture(app, "theme-\(theme)")
            app.buttons["tab_rituals"].tap()
            XCTAssertTrue(app.staticTexts["Сегодня"].exists)
            capture(app, "home-\(theme)")
        }
        app.buttons["tab_sanctuary"].tap()
        app.buttons["theme_paper"].tap()
        app.terminate()
        app.launch()
        app.buttons["tab_sanctuary"].tap()
        XCTAssertTrue(app.buttons["theme_paper"].isSelected)
        app.buttons["tab_rituals"].tap()
        reveal(app.buttons["Добавить привычку"], in: app)
        app.buttons["Добавить привычку"].tap()
        XCTAssertTrue(app.textFields["ritualTitle"].waitForExistence(timeout: 5))
        capture(app, "editor-paper")
    }

    @MainActor func testMilestoneCelebrationDoesNotRepeatAfterUndo() {
        let app = application(milestone: true)
        let complete = app.buttons["Выполнить: Прочитать 10 страниц"]
        reveal(complete, in: app)
        complete.tap()
        XCTAssertTrue(app.staticTexts["Отличная работа!"].waitForExistence(timeout: 5))
        capture(app, "milestone-5")
        app.buttons["dismissMilestone"].tap()
        app.buttons["Отменить выполнение: Прочитать 10 страниц"].tap()
        complete.tap()
        XCTAssertFalse(app.staticTexts["Отличная работа!"].exists)
        app.terminate()
        app.launch()
        let undo = app.buttons["Отменить выполнение: Прочитать 10 страниц"]
        reveal(undo, in: app)
        undo.tap()
        complete.tap()
        XCTAssertFalse(app.staticTexts["Отличная работа!"].exists)
    }

    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<8 {
            let bottom = app.buttons["tab_rituals"].exists ? app.buttons["tab_rituals"].frame.minY : app.frame.maxY
            if element.exists && element.isHittable && element.frame.maxY < bottom - 4 && element.frame.minY > 65 { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable, "Element should be reachable by scrolling: \(element)")
    }

    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        // Allow the finite entrance transition to finish before saving reference screenshots.
        Thread.sleep(forTimeInterval: 0.8)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
