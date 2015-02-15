//  Copyright (c) 2015 Rob Rix. All rights reserved.

import Set
import XCTest

final class PredicateSetTests: XCTestCase {
	func testPredicateSet() {
		XCTAssert(PredicateSet<Int> { $0 == 1 }.contains(1))
	}
	
	func testPredicateSetDoesNotContain() {
		XCTAssertFalse(PredicateSet<Int> { $0 == 1 }.contains(2))
	}

	func testPredicateSetFromSet() {
		let set = Set([1,2,3,4])
		let predicateSet = PredicateSet(set)
		XCTAssert(predicateSet.contains(4))
		XCTAssertFalse(predicateSet.contains(5))
	}

	func testPredicateSetFromMutiset() {
		let set = Multiset(1,1,1,1,2,3,4)
		let predicateSet = PredicateSet(set)
		XCTAssert(predicateSet.contains(4))
		XCTAssertFalse(predicateSet.contains(5))
	}
	
	func testSpecialSets() {
		XCTAssertFalse(N.contains(2.1))
		XCTAssert(Q.contains(2))
	}
	
	func testPredicateSetUnion() {
		XCTAssert(Q.union(Z).contains(1.1))
	}
	
	func testPredicateSetIntersection() {
		XCTAssert(Q.intersection(Z).contains(2))
	}

	func testPredicateSetComplement() {
		XCTAssertFalse(Q.complement(Z).contains(1.0))
	}
}

// MARK: Fixtures
func isInt(number: Float) -> Bool {
	return floor(number) == number
}

let Q = PredicateSet { $0 as Float }
let Z = Q.intersection(PredicateSet { isInt($0) })
let N = Z.intersection(PredicateSet { $0 > 0 })
