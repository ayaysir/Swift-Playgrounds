# ForEach 동작원리

```swift
@Reducer
struct ProductListDomain {
  @ObservableState
  struct State: Equatable {
    var productList: IdentifiedArrayOf<ProductDomain.State> = []
  }
  
  enum Action: Equatable {
    case fetchProductsResponse(TaskResult<[Product]>)
    case product(IdentifiedActionOf<ProductDomain>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchProductsResponse(.success(let products)):
        state.dataLoadingStatus = .success
        state.productList = IdentifiedArrayOf(
          uniqueElements: products.map {
            ProductDomain.State(id: self.uuid(), product: $0)
          }
        )
        return .none
      case .product:
        return .none
    }
    .forEach(\.productList, action: \.product) {
      ProductDomain()
    }
  }
}
```

`forEach(\.productList, action: \.product) { ProductDomain() }` 부분이 **바로 배열형 자식 도메인을 상위 도메인에 연결해 주는 구간**입니다.

---

### 동작 원리

* `ProductListDomain.State.productList`는 `IdentifiedArrayOf<ProductDomain.State>` 형태로 단순히 데이터 배열입니다
* 그냥 배열만 있으면 **`ProductDomain.Action`이 올라와도 어디로 보내야 할지** TCA는 알 수 없습니다.
* 그래서 `.forEach`를 써서

  * `State`의 배열 경로(`\.productList`)와 (=> var productList)
  * `Action`의 라우팅 케이스(`\.product`)를 (=> case product)
  * 실제 하위 리듀서(`ProductDomain()`)와 연결해 줍니다.

---

### 만약 `.forEach`를 안 썼다면?

* `productList`는 단순 데이터 배열로만 남습니다.
* 뷰에서 `store.send(.product(id: xxx, action: .didTapPlusButton))` 같은 액션을 보내더라도,
  → 상위 리듀서(`ProductListDomain`)에서는 `.product` 케이스가 들어오긴 하지만 **하위 리듀서(ProductDomain)** 로 전달되지 않습니다.
* 결과적으로 `ProductDomain` 안의 로직(`AddToCartDomain.count += 1` 같은 것)은 절대 실행되지 않습니다.

---

## 결론
네, `forEach` 구문이 있어야만 `productList` 배열의 각 요소와 `ProductDomain` 리듀서가 실제로 연결됩니다.
없으면 단순히 배열만 있는 상태라 액션 라우팅이 끊겨버립니다.

---


