//
//  ShiftTemplateControllerTests.swift
//  Tests
//
//  Created by Christian Tietze on 14/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import UIKit
import XCTest

class ShiftTemplateControllerTests: CoreDataTestCase {
    let storeURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("test.sqlite"))
    lazy var controller: ShiftTemplateController = {
        let modelURL = NSBundle.mainBundle().URLForResource(kShiftEntityName, withExtension: "momd")
        return ShiftTemplateController(storeURL: self.storeURL)
    }()
    
    override func tearDown() {
        if let storeURL: NSURL! = self.storeURL {
            if NSFileManager.defaultManager().fileExistsAtPath(storeURL!.path!) {
                var error: NSError?
                let success = NSFileManager.defaultManager().removeItemAtURL(storeURL, error: &error)
                XCTAssertTrue(success, "couldn't clean up test database file")
            }
        }
        super.tearDown()
    }
    
    func testInitializer() {
        XCTAssertNotNil(self.controller, "Should have a persistent stack");
    }
    
}
