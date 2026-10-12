//
//  POC_FashionUITests.swift
//  POC-FashionUITests
//
//  Created by Bryan Samuel on 12/10/26.
//

import XCTest

final class POC_FashionUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testGenerateThreeFitsFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Verify Inputs tab is visible
        XCTAssertTrue(app.staticTexts["1. Identity & Physical Profile"].waitForExistence(timeout: 5))
        
        // 2. Tap Weights tab to verify weight studio
        app.buttons["Weights"].tap()
        XCTAssertTrue(app.staticTexts["Dynamic Variable Weighting Studio"].waitForExistence(timeout: 3))
        
        // 3. Tap Generate button
        let generateButton = app.buttons["Generate 3 Fits & Analysis"]
        XCTAssertTrue(generateButton.exists)
        generateButton.tap()
        
        // 4. Wait for 3 Fits Output or Foundation Model alert to appear
        let look1Title = app.staticTexts["Look 1: Optimal Balance"]
        let alert = app.alerts.firstMatch
        let resultAppeared = look1Title.waitForExistence(timeout: 8) || alert.waitForExistence(timeout: 3)
        XCTAssertTrue(resultAppeared)
        
        if look1Title.exists {
            // 5. Verify Correlation Card exists
            XCTAssertTrue(app.staticTexts["Body Type, Torso & Color Season Correlation"].waitForExistence(timeout: 5))
            
            // 6. Verify 3 Garments header exists
            XCTAssertTrue(app.staticTexts["Engineered Wardrobe (3 Garments)"].waitForExistence(timeout: 5))
            
            // 7. Switch to Vision Fit
            app.buttons["Vision Fit"].tap()
            XCTAssertTrue(app.staticTexts["Look 2: Vision-Focused"].waitForExistence(timeout: 3))
            Thread.sleep(forTimeInterval: 0.5)
            
            // 8. Switch to Preference Fit
            app.buttons["Preference Fit"].tap()
            XCTAssertTrue(app.staticTexts["Look 3: Preference-Focused"].waitForExistence(timeout: 3))
            Thread.sleep(forTimeInterval: 0.5)
            
            // 9. Scroll down to verify 3 Rules of Fit
            app.swipeUp()
            app.swipeUp()
            XCTAssertTrue(app.staticTexts["The 3 Rules of Fit Validation"].waitForExistence(timeout: 5))
        } else if alert.exists {
            // Alert properly displays on devices/simulators where Foundation Model weights are not installed
            XCTAssertTrue(alert.buttons["OK"].exists)
            alert.buttons["OK"].tap()
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
