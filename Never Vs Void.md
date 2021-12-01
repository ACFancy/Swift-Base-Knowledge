#### Never VS Void
- 区别
  - We use Void to tell compiler there is no return value. Application keeps running.
  - We use Never to tell compiler there is no return to caller site. Application runloop is terminated.
- 例子
  ```swift
    /// Never
    func noReturn() -> Never {
      fatalError() // fatalError also returns Never, so no need to `return`
    }

    func pickPositiveNumber(below limit: Int) -> Int {
        guard limit >= 1 else {
            noReturn()
            // No need to exit guarded scope after noReturn
        }
        return rand(limit)
    }
    
    public func abort() -> Never
    func bar() -> Int {
      if true {
          abort() // No warning and no compiler error, because abort() terminates it.
      } else {
          return 1
      }
    }
    
    /// Void
    public func abortVoid() -> Void {
       fatalError()
    }

    func bar() -> Int {
        if true {
            abortVoid() // ERROR: Missing return in a function expected to return 'Int'
        } else {
            return 1
        }
    }
  ```
