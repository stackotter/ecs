//
//  EntityTests.swift
//  FirebladeECSTests
//
//  Created by Christian Treffs on 22.10.17.
//

#if DEBUG
@testable import FirebladeECS
import XCTest

class EntityTests: XCTestCase {
    func testEntityIdentifierAndIndex() {
        let min = EntityIdentifier(.min)
        XCTAssertEqual(min.id, Int(UInt32.min))

        let uRand = UInt32.random(in: UInt32.min...UInt32.max)
        let rand = EntityIdentifier(uRand)
        XCTAssertEqual(rand.id, Int(uRand))

        let max = EntityIdentifier(.max)
        XCTAssertEqual(max, EntityIdentifier.invalid)
        XCTAssertEqual(max.id, Int(UInt32.max))
    }
}
#endif
