public extension LazyCollectionProtocol {
    subscript<Indices: Sequence>(indices: Indices) -> LazySparseSubCollection<Elements, Indices> where Indices.Element == Index {
        .init(
            source: elements,
            indices: indices
        )
    }
}
