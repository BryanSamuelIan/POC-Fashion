//
//  POC_FashionUITests.swift
//  POC-FashionUITests
//
//  Created by Bryan Samuel on 12/10/26.
//

import XCTest

final class POC_FashionUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        
        // 4. Wait for 3 Fits Output to appear
        XCTAssertTrue(app.staticTexts["Diagnostic Analysis: Body Shape, Torso & Color"].waitForExistence(timeout: 10))
        
        // 5. Verify Look 1 (Balanced) is displayed
        XCTAssertTrue(app.staticTexts["Look 1: Optimal Balance"].exists)
        
        // 6. Switch to Vision Fit
        app.buttons["Vision Fit"].tap()
        XCTAssertTrue(app.staticTexts["Look 2: Vision-Focused"].waitForExistence(timeout: 3))
        
        // 7. Switch to Preference Fit
        app.buttons["Preference Fit"].tap()
        XCTAssertTrue(app.staticTexts["Look 3: Preference-Focused"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
