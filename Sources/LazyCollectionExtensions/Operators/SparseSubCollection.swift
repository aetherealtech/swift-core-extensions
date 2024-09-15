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
    
    private let source: Source
    private let indices: Indices
}

extension LazySparseSubCollection: Sendable where Source: Sendable, Indices: Sendable {}

extension LazySparseSubCollection: Collection where Indices: Collection {
    public subscript(position: Indices.Index) -> Source.Element {
        source[indices[position]]
    }
    
    public var startIndex: Indices.Index { indices.startIndex }
    public var endIndex: Indices.Index { indices.endIndex }
    
    public func index(after i: Indices.Index) -> Indices.Index {
        indices.index(after: i)
    }
}
