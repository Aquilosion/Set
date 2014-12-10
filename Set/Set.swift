//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A set of unique elements.
public struct Set<Element: Hashable>: CollectionType, ExtensibleCollectionType, SequenceType {
	// MARK: Constructors

	/// Constructs a `Set` with the elements of `sequence`.
	public init<S: SequenceType where S.Generator.Element == Element>(_ sequence: S) {
		self.values = [:]
		extend(sequence)
	}

	/// Constructs the empty `Set`.
	public init() {
		self.values = [:]
	}

	/// Constructs a `Set` with a hint as to the capacity it should allocate.
	public init(minimumCapacity: Int) {
		self.values = [Element:Unit](minimumCapacity: minimumCapacity)
	}


	// MARK: Properties

	/// The number of entries in the set.
	public var count: Int { return values.count }

	/// True iff `count == 0`
	public var isEmpty: Bool {
		return self.values.isEmpty
	}


	// MARK: Primitive methods

	/// True iff `element` is in the receiver, as defined by its hash and equality.
	public func contains(element: Element) -> Bool {
		return values[element] != nil
	}

	/// Inserts `element` into the receiver, if it doesn’t already exist.
	public mutating func insert(element: Element) {
		values[element] = Unit()
	}

	/// Removes `element` from the receiver, if it’s a member.
	public mutating func remove(element: Element) {
		values.removeValueForKey(element)
	}


	// MARK: Algebraic operations

	/// Returns the union of the receiver and `set`.
	public func union(set: Set) -> Set {
		return self + set
	}

	/// Returns the intersection of the receiver and `set`.
	public func intersection(set: Set) -> Set {
		return Set(self.count <= set.count ?
			filter(self) { set.contains($0) }
		:	filter(set) { self.contains($0) })
	}

	/// Returns a new set with all elements from the receiver which are not contained in `set`.
	public func difference(set: Set) -> Set {
		return Set(filter(self) { !set.contains($0) })
	}


	// MARK: Higher-order functions

	/// Returns a new set with the result of applying `transform` to each element.
	public func map<Result>(transform: Element -> Result) -> Set<Result> {
		return flatMap { [transform($0)] }
	}

	/// Applies `transform` to each element and returns a new set which is the union of each resulting set.
	public func flatMap<Result, S: SequenceType where S.Generator.Element == Result>(transform: Element -> S) -> Set<Result> {
		return reduce(Set<Result>()) { $0 + transform($1) }
	}

	/// Combines each element of the receiver with an accumulator value using `combine`, starting with `initial`.
	public func reduce<Into>(initial: Into, combine: (Into, Element) -> Into) -> Into {
		return Swift.reduce(self, initial, combine)
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<Element> {
		return GeneratorOf(values.keys.generate())
	}


	// MARK: CollectionType

	public var startIndex: DictionaryIndex<Element, Unit> { return values.startIndex }
	public var endIndex: DictionaryIndex<Element, Unit> { return values.endIndex }

	public subscript(v: ()) -> Element {
		get { return values[values.startIndex].0 }
		set { insert(newValue) }
	}

	public subscript(index: DictionaryIndex<Element, Unit>) -> Element {
		return values[index].0
	}


	// MARK: ExtensibleCollectionType

	/// In theory, reserve capacity for `n` elements. However, Dictionary does not implement reserveCapacity(), so we just silently ignore it.
	public func reserveCapacity(n: Set<Element>.Index.Distance) {}

	/// Inserts each element of `sequence` into the receiver.
	public mutating func extend<S: SequenceType where S.Generator.Element == Element>(sequence: S) {
		// Note that this should just be for each in sequence; this is working around a compiler crasher.
		for each in [Element](sequence) {
			insert(each)
		}
	}

	/// Appends `element` onto the `Set`.
	public mutating func append(element: Element) {
		insert(element)
	}


	// MARK: Private

	/// The underlying dictionary.
	private var values: [Element: Unit]
}


/// Extends a `set` with the elements of a `sequence`.
public func += <S: SequenceType> (inout set: Set<S.Generator.Element>, sequence: S) {
	set.extend(sequence)
}

/// Returns a new set with all elements from `set` which are not contained in `other`.
public func - <Element> (set: Set<Element>, other: Set<Element>) -> Set<Element> {
	return set.difference(other)
}

/// Removes all elements in `other` from `set`.
public func -= <Element> (inout set: Set<Element>, other: Set<Element>) {
	for element in other {
		set.remove(element)
	}
}

/// Intersects with `set` with `other`.
public func &= <Element> (inout set: Set<Element>, other: Set<Element>) {
	for element in set {
		if !other.contains(element) {
			set.remove(element)
		}
	}
}

/// Returns the intersection of `set` and `other`.
public func & <Element> (set: Set<Element>, other: Set<Element>) -> Set<Element> {
	return set.intersection(other)
}

/// ArrayLiteralConvertible conformance.
extension Set: ArrayLiteralConvertible {
	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}


/// Defines equality for sets of equatable elements.
public func == <Element: Hashable> (a: Set<Element>, b: Set<Element>) -> Bool {
	return a.values == b.values
}


/// Printable conformance.
extension Set: Printable {
	public var description: String {
		if self.count == 0 { return "{}" }

		let joined = join(", ", map(toString))
		return "{ \(joined) }"
	}
}


/// Hashable conformance.
///
/// This hash function has not been proven in this usage, but is based on Bob Jenkins’ one-at-a-time hash.
extension Set: Hashable {
	public var hashValue: Int {
		var h = reduce(0) { into, each in
			var h = into + each.hashValue
			h += (h << 10)
			h ^= (h >> 6)
			return h
		}
		h += (h << 3)
		h ^= (h >> 11)
		h += (h << 15)
		return h
	}
}
