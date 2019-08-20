//
//  NexusTests.swift
//  FirebladeECS
//
//  Created by Christian Treffs on 09.10.17.
//

import FirebladeECS
import XCTest

class NexusTests: XCTestCase {

    var nexus: Nexus!

	override func setUp() {
		super.setUp()
        nexus = Nexus()
	}

	override func tearDown() {
        nexus = nil
		super.tearDown()
	}

	func testEntityCreate() {
        XCTAssertEqual(nexus.numEntities, 0)

		let e0 = nexus.createEntity()

		XCTAssertEqual(e0.identifier.index, 0)
        XCTAssertEqual(nexus.numEntities, 1)

        let e1 = nexus.createEntity(with: Name(name: "Entity 1"))

        XCTAssert(e1.identifier.index == 1)
        XCTAssert(nexus.numEntities == 2)

        //FIXME: XCTAssertNil(e0.name)
        //FIXME: XCTAssertEqual(e1.name, "Entity 1")
	}

    func testEntityDestroy() {
        testEntityCreate()
        XCTAssertEqual(nexus.numEntities, 2)

        let e1: Entity = nexus.get(entity: 1)!
        XCTAssertEqual(e1.identifier.index, 1)

        XCTAssertTrue(nexus.destroy(entity: e1))
        XCTAssertFalse(nexus.destroy(entity: e1))

        XCTAssertEqual(nexus.numEntities, 1)

        let e1Again: Entity? = nexus.get(entity: 1)
        XCTAssertNil(e1Again)

        XCTAssertEqual(nexus.numEntities, 1)

        nexus.clear()

        XCTAssertEqual(nexus.numEntities, 0)
    }

	func testComponentCreation() {

		XCTAssert(nexus.numEntities == 0)

		let e0: Entity = nexus.createEntity()

		let p0 = Position(x: 1, y: 2)

		e0.assign(p0)
        // component collision: e0.assign(p0)

		XCTAssert(e0.hasComponents)
		XCTAssert(e0.numComponents == 1)

		let rP0: Position = e0.get(component: Position.self)!
		XCTAssert(rP0.x == 1)
		XCTAssert(rP0.y == 2)
	}

	func testComponentDeletion() {

		let identifier: EntityIdentifier = nexus.createEntity().identifier

		let e0 = nexus.get(entity: identifier)!

		XCTAssert(e0.numComponents == 0)
		e0.remove(Position.self)
		XCTAssert(e0.numComponents == 0)

		let n0 = Name(name: "myName")
		let p0 = Position(x: 99, y: 111)

		e0.assign(n0)
		XCTAssert(e0.numComponents == 1)
		XCTAssert(e0.hasComponents)

		e0.remove(Name.self)

		XCTAssert(e0.numComponents == 0)
		XCTAssert(!e0.hasComponents)

		e0.assign(p0)

		XCTAssert(e0.numComponents == 1)
		XCTAssert(e0.hasComponents)

		e0.remove(p0)

		XCTAssert(e0.numComponents == 0)
		XCTAssert(!e0.hasComponents)

		e0.assign(n0)
		e0.assign(p0)

		XCTAssert(e0.numComponents == 2)
		let (name, position) = e0.get(components: Name.self, Position.self)

		XCTAssert(name?.name == "myName")
		XCTAssert(position?.x == 99)
		XCTAssert(position?.y == 111)

		e0.destroy()

		XCTAssert(e0.numComponents == 0)

	}
    
    func testComponentRetrieval() {
        let pos = Position(x: 1, y: 2)
        let name = Name(name: "myName")
        let vel = Velocity(a: 3)
        let entity = nexus.createEntity(with: pos, name, vel)
        
        let (rPos, rName, rVel) = entity.get(components: Position.self, Name.self, Velocity.self)
        
        
        XCTAssertTrue(rPos === pos)
        XCTAssertTrue(rName === name)
        XCTAssertTrue(rVel === vel)
        
    }

	func testComponentUniqueness() {
		let a = nexus.createEntity()
		let b = nexus.createEntity()
		let c = nexus.createEntity()

		XCTAssert(nexus.numEntities == 3)

		a.assign(Position(x: 0, y: 0))
		b.assign(Position(x: 0, y: 0))
		c.assign(Position(x: 0, y: 0))

		let pA: Position = a.get()!
		let pB: Position = b.get()!

		pA.x = 23
		pA.y = 32

		XCTAssert(pB.x != pA.x)
		XCTAssert(pB.y != pA.y)

	}

}
