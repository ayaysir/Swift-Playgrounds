//
//  ProductListDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProductListDomain {
  @ObservableState
  struct State: Equatable {
    var dataLoadingStatus = DataLoadingStatus.notStarted
    /// `@Presents`는 SwiftUI의 @State나 @Binding처럼 상태를 선언하는 용도인데, 특별히 옵셔널 상태와 시트/풀스크린 커버/네비게이션 같은 “프레젠테이션(presentation)”을 위한 연결을 간편하게 하기 위해 만들어졌습니다.
    /// - cartState는 옵셔널 상태입니다.
    ///   - nil이면 장바구니 화면이 닫혀 있는 상태
    ///   - CartListDomain.State 값이 들어있으면 장바구니 화면이 열려 있는 상태
    /// - Reducer에서 .ifLet(\.$cartState, action: \.cart) { CartListDomain() }처럼 선언해두면, cartState에 값이 할당되는 순간 자동으로 하위 리듀서(CartListDomain)와 연결됩니다.
    @Presents var cartState: CartListDomain.State?
    var productList: IdentifiedArrayOf<ProductDomain.State> = []
    
    var shouldShowError: Bool {
      dataLoadingStatus == .error
    }
    
    var isLoading: Bool {
      dataLoadingStatus == .loading
    }
  }
  
  enum Action: Equatable {
    case fetchProducts
    case fetchProductsResponse(TaskResult<[Product]>)
    case setCartView(isPresented: Bool)
    // 프레젠테이션 액션(PresentationAction) 은 시트, 네비게이션, 팝오버 같은 “뷰의 열림/닫힘” 상태를 옵셔널 상태와 액션으로 안전하게 연결하기 위한 특별한 액션 타입
    case cart(PresentationAction<CartListDomain.Action>)
    case product(IdentifiedActionOf<ProductDomain>)
    case resetProduct(product: Product)
    case closeCart
  }
  
  @Dependency(\.apiClient.fetchProducts) var fetchProducts
  @Dependency(\.uuid) var uuid
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .fetchProducts:
        if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
          return .none
        }
        
        state.dataLoadingStatus = .loading
        return .run { send in
          await send(
            .fetchProductsResponse(TaskResult {
              try await self.fetchProducts()
            })
          )
        }
        
      case .fetchProductsResponse(.success(let products)):
        state.dataLoadingStatus = .success
        state.productList = IdentifiedArrayOf(
          uniqueElements: products.map {
            ProductDomain.State(id: self.uuid(), product: $0)
          }
        )
        
        return .none
        
      case .fetchProductsResponse(.failure(let error)):
        state.dataLoadingStatus = .error
        
        print("fetchProductsResponse Error: \(error)")
        print("Error getting products, try again later.")
        
        return .none
        
      case .cart(.presented(let action)):
        return switchCartPresentedAction(state: &state, cartAction: action)
        
      case .cart(.dismiss):
        return .none
        
      case .closeCart:
        state.cartState = nil
        return .none
        
      case .resetProduct(product: let product):
        guard let index = state.productList.firstIndex(where: { $0.product.id == product.id })
        else { return .none }
        
        let productStateId = state.productList[index].id
        state.productList[id: productStateId]?.addToCartState.count = 0
        
        return .none
        
      case .setCartView(let isPresented):
        return setCartViewAction(state: &state, isPresented: isPresented)
        
      case .product:
        return .none
      }
    }
    .forEach(\.productList, action: \.product) {
      /*
       배열형 자식 도메인 연결

       \.productList
         - 루트 상태 안에 있는 배열형 상태 (예: IdentifiedArrayOf<ProductDomain.State>)
       \.product
         - 루트 액션 안에서 각 product에 대한 case (예: case product(id: UUID, action: ProductDomain.Action))
       { ProductDomain() }
         - 해당 배열 요소 각각에 대해 연결할 자식
       
       👉 이것을 통해 루트 도메인은 productList 배열에 포함된 각각의 product 상태를 관리하고,
       각각의 ProductDomain.Action을 하위 도메인으로 라우팅할 수 있게 됩니다.
       */
      ProductDomain()
    }
    .ifLet(\.$cartState, action: \.cart) {
      /*
       옵셔널 자식 도메인 연결

       \.$cartState
         - 루트 상태에 존재하는 옵셔널 상태 (CartListDomain.State?)
       \.cart
         - 루트 액션에서 CartListDomain.Action을 보내는 case
       { CartListDomain() }
         - 이 상태가 nil이 아닐 때만 이 리듀서가 활성화

       */
      CartListDomain()
    }
  }
}

extension ProductListDomain {

  /// 장바구니 뷰에 대한 액션:
  /// - Parameter isPresented: 장바구니를 열면 `true`, 아니면 `false`
  private func setCartViewAction(
    state: inout ProductListDomain.State,
    isPresented: Bool
  ) -> Effect<Action> {
    state.cartState = if isPresented {
      // makeCartItems 함수가 product.addToCartState.count > 0인 애들만 뽑아서 CartItem으로 변환 → 여기서 장바구니 화면에 보이게 됨
      CartListDomain.State(cartItems: makeCartItems(from: state.productList))
    } else {
      nil
    }
    
    return .none
  }
  
  /// products(ProductDomain.State)에서 장바구니 수량이 0 초과인 상품들을 표시
  private func makeCartItems(
    from products: IdentifiedArrayOf<ProductDomain.State>
  ) -> IdentifiedArrayOf<CartItemDomain.State> {
    IdentifiedArrayOf(
      uniqueElements: products.compactMap {
        guard $0.count > 0 else { return nil }
        return CartItemDomain.State(
          id: uuid(),
          cartItem: CartItem(product: $0.product, quantity: $0.count)
        )
      }
    )
  }
  
  private func switchCartPresentedAction(
    state: inout Self.State,
    cartAction action: CartListDomain.Action
  ) -> Effect<Action> {
    switch action {
    case .didPressCloseButton:
      state.cartState = nil
      return .none
    
    case .alert(.presented(.dismissSuccessAlert)):
      // .dismissSuccessAlert ('구입에 성공했습니다' 경고창이 닫혔을 때)
      // resetProductsToZero
      for id in state.productList.map(\.id) {
        state.productList[id: id]?.count = 0
      }
    
      return .run { send in
        await send(.closeCart)
      }
    
    case .cartItem(.element(id: _, action: let action)):
      switch action { // CartItemDomain.Action
      case .deleteCartItem(let product):
        return .send(.resetProduct(product: product))
      }
    
    default:
      return .none
    }
  }
}
