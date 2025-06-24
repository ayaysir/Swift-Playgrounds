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
    case cart(PresentationAction<CartListDomain.Action>)
    case product(IdentifiedActionOf<ProductDomain>)
    case resetProduct(product: Product)
    case closeCart
  }
  
  @Dependency(\.apiClient.fetchProducts) var fetchProducts
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
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
        // return cartCaseAction(cartAction: action)
        return .none
        
      case .cart(.dismiss):
        return .none
        
      case .closeCart:
        return closeCart(state: &state)
        
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
  private func closeCart(
    state: inout State
  ) -> Effect<Action> {
    state.cartState = nil
    
    return .none
  }
  
  private func setCartViewAction(
    state: inout ProductListDomain.State,
    isPresented: Bool
  ) -> Effect<Action> {
    state.cartState = if isPresented {
      CartListDomain.State(
        cartItems: makeCartItems(from: state.productList)
      )
    } else {
      nil
    }
    
    return .none
  }
  
  private func makeCartItems(from products: IdentifiedArrayOf<ProductDomain.State>) -> IdentifiedArrayOf<CartItemDomain.State> {
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
  
  private func cartCaseAction(cartAction action: CartListDomain.Action) -> Effect<Action> {
    // switch action {
    // case .didPressCloseButton:
    //   return closeCart(state: &state)
    //
    // case .alert(.presented(.dismissSuccessAlert)):
    //   resetProductsToZero(state: &state)
    //
    //   return .run { send in
    //     await send(.closeCart)
    //   }
    //
    // case .cartItem(.element(id: _, action: let action)):
    //   switch action {
    //   case .deleteCartItem(let product):
    //     return .send(.resetProduct(product: product))
    //   }
    //
    // default:
    //   return .none
    // }
    
    // return .none
  }
}
