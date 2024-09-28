public struct LazySparseSubCollection<
    Source: Collection,
    Indices: Sequence<Source.Index>
>: LazySequenceProtocol {
    public typealias Element = Source.Element
    
    public struct Iterator: IteratorProtocol {
        init(
            source: Source,
            indices: Indices
        ) {
            self.source = source
            self.indices = indices.makeIterator()
            self.index = self.indices.next()
        }
        
        public mutating func next() -> Element? {
            defer { index = indices.next() }
            
            return index.flatMap { index in source[index] }
        }
        
        private let source: Source
        private var indices: Indices.Iterator
        private var index: Source.Index?
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source,
            indices: indices
        )
    }
    
    init(
        source: Source,
        indices: Indices
    ) {
        self.source = source
        self.indices = indices
    }
    
    public private(set) var source: Source
    public let indices: Indices
}

extension LazySparseSubCollection: Collection where Indices: Collection {
    public subscript(position: Indices.Index) -> Source.Element {
        _read { yield source[indices[position]] }
    }
    
    public var startIndex: Indices.Index { indices.startIndex }
    public var endIndex: Indices.Index { indices.endIndex }
    
    public func index(after i: Indices.Index) -> Indices.Index {
        indices.index(after: i)
    }
}

extension LazySparseSubCollection: BidirectionalCollection where Indices: BidirectionalCollection {
    public func index(before i: Indices.Index) -> Indices.Index {
        indices.index(before: i)
    }
}

extension LazySparseSubCollection: RandomAccessCollection where Indices: RandomAccessCollection {
    public func index(_ i: Indices.Index, offsetBy distance: Int) -> Indices.Index {
        indices.index(i, offsetBy: distance)
    }
    
    public func index(_ i: Indices.Index, offsetBy distance: Int, limitedBy limit: Indices.Index) -> Indices.Index? {
        indices.index(i, offsetBy: distance, limitedBy: limit)
    }
}

extension LazySparseSubCollection: MutableCollection where Source: MutableCollection, Indices: Collection {
    public subscript(position: Indices.Index) -> Source.Element {
        _read { yield source[indices[position]] }
        _modify { yield &source[indices[position]]  }
    }
}
