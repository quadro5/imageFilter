import Foundation

public struct queue<Element> {
    // ----------------------------------------------------
    // @interface
    public var count: Int {
        return self.getSize()
    }
    public var isEmpty: Bool {
        return self.testEmpty()
    }
    public func front() -> Element? {
        return self.getFront()
    }
    public mutating func push(_ item: Element?) {
        guard let tmp = item else {
            return
        }
        self.append(tmp)
    }
    public mutating func pop() -> Element? {
        return self.removeFirst()
    }
    
    // ----------------------------------------------------
    // @Test
    public func printAll() {
        if self.isEmpty {
            print("q: isEmpty")
            return
        }
        for index in 0..<self.count {
            print("q[\(index)] = \(items[index])")
        }
    }
    
    // ----------------------------------------------------
    // @Internal
    private var items = [Element]()
    
    private func testEmpty() -> Bool {
        return items.isEmpty
    }
    
    private func getSize() -> Int {
        return items.count
    }
    
    private mutating func append(_ item: Element) {
        items.append(item)
    }
    private mutating func removeFirst() -> Element? {
        return items.removeFirst()
    }
    private func getFront() -> Element? {
        return items.isEmpty ? nil : items[0]
    }
    // ------------------------------------------------------
}
