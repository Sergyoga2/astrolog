import XCTest

/// UI Tests for Birth Chart creation and display flow
/// Tests the complete flow from entering birth data to viewing the chart
final class BirthChartUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Start at main app (logged in state)
        app.launchArguments = ["--uitesting", "--authenticated", "--no-birth-data"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Birth Data Entry Tests

    func testBirthDataEntryScreenElements() throws {
        // Navigate to birth chart creation
        app.tabBars.buttons["Карта"].tap()

        // Should prompt for birth data entry
        XCTAssertTrue(app.staticTexts["Введите данные рождения"].waitForExistence(timeout: 3))

        // Verify all input fields exist
        XCTAssertTrue(app.datePickers.firstMatch.exists)
        XCTAssertTrue(app.buttons["Выбрать место"].exists)
        XCTAssertTrue(app.buttons["Создать карту"].exists)
    }

    func testDatePickerInteraction() throws {
        app.tabBars.buttons["Карта"].tap()

        let datePicker = app.datePickers.firstMatch
        if datePicker.exists {
            datePicker.tap()

            // Adjust date (iOS native picker)
            // Note: Date picker interaction varies by iOS version
            if let dateWheel = datePicker.pickerWheels.firstMatch as? XCUIElement {
                dateWheel.adjust(toPickerWheelValue: "15")
            }
        }
    }

    func testLocationSearch() throws {
        app.tabBars.buttons["Карта"].tap()

        // Tap location selection button
        app.buttons["Выбрать место"].tap()

        // Should show location search screen
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))

        // Enter city name
        searchField.tap()
        searchField.typeText("Moscow")

        // Wait for results
        let firstResult = app.tables.cells.firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))

        // Select first result
        firstResult.tap()

        // Should return to birth data entry with location selected
        XCTAssertTrue(app.staticTexts["Moscow"].exists)
    }

    func testTimeToggle() throws {
        app.tabBars.buttons["Карта"].tap()

        // Look for "Time unknown" toggle
        let timeUnknownToggle = app.switches["Время неизвестно"]

        if timeUnknownToggle.exists {
            // Toggle on
            timeUnknownToggle.tap()

            // Time picker should be disabled or hidden
            let timePicker = app.datePickers["TimePicker"]
            if timePicker.exists {
                XCTAssertFalse(timePicker.isEnabled)
            }

            // Toggle off
            timeUnknownToggle.tap()

            // Time picker should be enabled again
            if timePicker.exists {
                XCTAssertTrue(timePicker.isEnabled)
            }
        }
    }

    func testCreateBirthChart() throws {
        app.tabBars.buttons["Карта"].tap()

        // Fill in birth data
        let datePicker = app.datePickers.firstMatch
        if datePicker.exists {
            datePicker.tap()
            // Use default date
        }

        // Select location
        app.buttons["Выбрать место"].tap()
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("London")

        let firstResult = app.tables.cells.firstMatch
        if firstResult.waitForExistence(timeout: 5) {
            firstResult.tap()
        }

        // Create chart
        app.buttons["Создать карту"].tap()

        // Should show loading indicator
        let loadingIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2))

        // Should navigate to chart view
        let chartTitle = app.staticTexts["Натальная карта"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 10))
    }

    // MARK: - Chart Display Tests

    func testChartDisplayElements() throws {
        // Assuming chart is already created
        createSampleChart()

        // Verify chart visualization exists
        let chartView = app.otherElements["BirthChartView"]
        XCTAssertTrue(chartView.exists)

        // Verify tabs or sections
        XCTAssertTrue(app.buttons["Планеты"].exists || app.staticTexts["Планеты"].exists)
        XCTAssertTrue(app.buttons["Дома"].exists || app.staticTexts["Дома"].exists)
        XCTAssertTrue(app.buttons["Аспекты"].exists || app.staticTexts["Аспекты"].exists)
    }

    func testPlanetsList() throws {
        createSampleChart()

        // Navigate to planets section
        if app.buttons["Планеты"].exists {
            app.buttons["Планеты"].tap()
        }

        // Should show list of planets
        XCTAssertTrue(app.staticTexts["Sun"].exists || app.staticTexts["Солнце"].exists)
        XCTAssertTrue(app.staticTexts["Moon"].exists || app.staticTexts["Луна"].exists)
        XCTAssertTrue(app.staticTexts["Mercury"].exists || app.staticTexts["Меркурий"].exists)
    }

    func testHousesList() throws {
        createSampleChart()

        // Navigate to houses section
        if app.buttons["Дома"].exists {
            app.buttons["Дома"].tap()
        }

        // Should show 12 houses
        let housesList = app.scrollViews.firstMatch
        if housesList.exists {
            // Look for house numbers
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Дом 1' OR label CONTAINS 'House 1'")).firstMatch.exists)
        }
    }

    func testAspectsList() throws {
        createSampleChart()

        // Navigate to aspects section
        if app.buttons["Аспекты"].exists {
            app.buttons["Аспекты"].tap()
        }

        // Should show aspects
        let aspectsList = app.scrollViews.firstMatch
        if aspectsList.exists {
            // Look for aspect types
            let aspectExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Conjunction' OR label CONTAINS 'Trine' OR label CONTAINS 'Square'")).firstMatch.exists
            XCTAssertTrue(aspectExists)
        }
    }

    func testPlanetDetailView() throws {
        createSampleChart()

        // Tap on planets section
        if app.buttons["Планеты"].exists {
            app.buttons["Планеты"].tap()
        }

        // Tap on Sun/Солнце
        let sunCell = app.staticTexts["Sun"].firstMatch
        if sunCell.exists {
            sunCell.tap()

            // Should show detail view with interpretation
            let detailView = app.scrollViews.firstMatch
            XCTAssertTrue(detailView.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Chart Interaction Tests

    func testZoomChartVisualization() throws {
        createSampleChart()

        let chartView = app.otherElements["BirthChartView"]
        if chartView.exists {
            // Pinch to zoom
            chartView.pinch(withScale: 2.0, velocity: 1.0)

            // Chart should be zoomed
            // (Visual verification needed in manual testing)
        }
    }

    func testRotateChart() throws {
        createSampleChart()

        let chartView = app.otherElements["BirthChartView"]
        if chartView.exists {
            // Rotate gesture
            chartView.rotate(3.14, withVelocity: 1.0)

            // Chart should be rotated
        }
    }

    func testChartScrolling() throws {
        createSampleChart()

        // Navigate to planets list
        if app.buttons["Планеты"].exists {
            app.buttons["Планеты"].tap()
        }

        // Scroll down the list
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()

            // Should be able to see more planets
            XCTAssertTrue(app.staticTexts["Pluto"].exists || app.staticTexts["Плутон"].exists)
        }
    }

    // MARK: - Chart Sharing Tests

    func testShareChartButton() throws {
        createSampleChart()

        // Look for share button
        let shareButton = app.buttons["Share"] // Or localized version

        if shareButton.exists {
            shareButton.tap()

            // Should show share sheet
            let shareSheet = app.otherElements["ActivityListView"]
            XCTAssertTrue(shareSheet.waitForExistence(timeout: 3))

            // Dismiss share sheet
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        }
    }

    // MARK: - Chart Editing Tests

    func testEditBirthData() throws {
        createSampleChart()

        // Look for edit button
        let editButton = app.buttons["Редактировать"]

        if editButton.exists {
            editButton.tap()

            // Should return to birth data entry with filled values
            XCTAssertTrue(app.buttons["Сохранить изменения"].waitForExistence(timeout: 2))
        }
    }

    func testDeleteChart() throws {
        createSampleChart()

        // Look for delete option (might be in menu)
        let moreButton = app.buttons["More"] // Or ellipsis button

        if moreButton.exists {
            moreButton.tap()

            let deleteButton = app.buttons["Удалить карту"]
            if deleteButton.exists {
                deleteButton.tap()

                // Should show confirmation alert
                let alert = app.alerts.firstMatch
                XCTAssertTrue(alert.waitForExistence(timeout: 2))

                // Confirm deletion
                alert.buttons["Удалить"].tap()

                // Should navigate back to empty state
                XCTAssertTrue(app.staticTexts["Введите данные рождения"].waitForExistence(timeout: 3))
            }
        }
    }

    // MARK: - Accessibility Tests

    func testChartAccessibility() throws {
        createSampleChart()

        let chartView = app.otherElements["BirthChartView"]
        XCTAssertTrue(chartView.isAccessibilityElement || chartView.children(matching: .any).count > 0)
    }

    func testPlanetListAccessibility() throws {
        createSampleChart()

        if app.buttons["Планеты"].exists {
            app.buttons["Планеты"].tap()
        }

        // Each planet should have accessibility label
        let sunCell = app.staticTexts["Sun"].firstMatch
        if sunCell.exists {
            XCTAssertNotNil(sunCell.accessibilityLabel)
        }
    }

    // MARK: - Helper Methods

    private func createSampleChart() {
        app.tabBars.buttons["Карта"].tap()

        // Quick chart creation for testing
        // Select location
        if app.buttons["Выбрать место"].exists {
            app.buttons["Выбрать место"].tap()
            let searchField = app.searchFields.firstMatch
            searchField.tap()
            searchField.typeText("Paris")

            let firstResult = app.tables.cells.firstMatch
            if firstResult.waitForExistence(timeout: 5) {
                firstResult.tap()
            }
        }

        // Create chart
        if app.buttons["Создать карту"].exists {
            app.buttons["Создать карту"].tap()

            // Wait for chart to load
            let chartView = app.otherElements["BirthChartView"]
            _ = chartView.waitForExistence(timeout: 10)
        }
    }
}
