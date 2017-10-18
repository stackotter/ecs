//
//  HashingTests.swift
//  FirebladeECSTests
//
//  Created by Christian Treffs on 16.10.17.
//

import Darwin
import XCTest
@testable import FirebladeECS

class HashingTests: XCTestCase {

	func testCollisionsInCritialRange() {

		var hashSet: Set<Int> = Set<Int>()

		var range: CountableRange<EntityIdentifier> = 0 ..< 1_000_000

		let maxComponents: Int = 1000
		let components: [Int] = (0..<maxComponents).map { _ in makeComponent() }

		var index: Int = 0
		while let eId: EntityIdentifier = range.popLast() {

			let entityId: EntityIdentifier = eId
			let c = (index % maxComponents)
			index += 1

			let cH: ComponentTypeHash = components[c]

			let h: Int = EntityComponentHash.compose(entityId: entityId, componentTypeHash: cH)

			let (collisionFree, _) = hashSet.insert(h)
			XCTAssert(collisionFree)

			XCTAssert(EntityComponentHash.decompose(h, with: cH) == entityId)
			XCTAssert(EntityComponentHash.decompose(h, with: entityId) == cH)
		}
	}

	func testMeasureCombineHash() {
		let a: Set<Int> = Set<Int>.init([1, 2, 3, 4, 5, 6])
		let b: Set<Int> = Set<Int>.init([10, 9, 8, 7, 6])
		let c: Set<Int> = Set<Int>.init([10, 9, 12, 7, 6])

		let input: ContiguousArray<Int> = ContiguousArray<Int>(arrayLiteral: a.hashValue, b.hashValue, c.hashValue)
		measure {
			for _ in 0..<1_000_000 {
				let hashRes: Int = FirebladeECS.hash(combine: input)
				_ = hashRes
			}
		}
	}

	func testMeasureSetOfSetHash() {
		let a: Set<Int> = Set<Int>.init([1, 2, 3, 4, 5, 6])
		let b: Set<Int> = Set<Int>.init([10, 9, 8, 7, 6])
		let c: Set<Int> = Set<Int>.init([10, 9, 12, 7, 6])

		let input = Set<Set<Int>>(arrayLiteral: a, b, c)
		measure {
			for _ in 0..<1_000_000 {
				let hash: Int = input.hashValue
				_ = hash
			}
		}
	}

}

// MARK: - helper
extension HashingTests {

	func makeComponent() -> Int {
		let upperBound: Int = 44
		let high = UInt(arc4random()) << UInt(upperBound)
		let low = UInt(arc4random())
		assert(high.leadingZeroBitCount < 64-upperBound)
		assert(high.trailingZeroBitCount >= upperBound)
		assert(low.leadingZeroBitCount >= 32)
		assert(low.trailingZeroBitCount <= 32)
		let rand: UInt = high | low
		let cH = Int(bitPattern: rand)
		return cH
	}
}