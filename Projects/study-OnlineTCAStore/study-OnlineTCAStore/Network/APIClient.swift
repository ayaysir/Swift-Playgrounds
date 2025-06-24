//
//  APIClient.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import Foundation
import ComposableArchitecture
import DependenciesMacros

extension DependencyValues {
  /*
   @Dependency(\.apiClient) var apiClient

   func reduce(...) -> Effect<Action> {
     return .task {
       let result = try await apiClient.fetchProducts()
       ...
     }
   }
   */
  var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}

// APIClient라는 의존성을 정의하고, @Dependency(\.apiClient)처럼 도메인 내부에서 선언 없이 주입 받아 사용할 수 있게 합니다.
// DependencyClient: DependencyKey 자동 생성, DependencyValues[APIClient.self 자동 등록, 테스트 시 .withDependencies { }에서 모킹 가능

@DependencyClient
struct APIClient {
  var fetchProducts:  @Sendable () async throws -> [Product]
  var sendOrder:  @Sendable ([CartItem]) async throws -> String
  var fetchUserProfile:  @Sendable () async throws -> UserProfile
  
  struct Failure: Error, Equatable {}
}

extension APIClient: TestDependencyKey {
  static let testValue = Self()
}

// This is the "live" fact dependency that reaches into the outside world to fetch the data from network.
// 이는 네트워크에서 데이터를 가져오기 위해 외부 세계에 접근하는 "실시간" 팩트 종속성입니다.
// Typically this live implementation of the dependency would live in its own module so that the
// 일반적으로 종속성의 이 실시간 구현은 자체 모듈에 존재하므로
// main feature doesn't need to compile it.
// 주요 기능에서 컴파일할 필요가 없습니다.

extension APIClient: DependencyKey {
  static let liveValue = Self(
    fetchProducts: {
      let (data, _) = try await URLSession.shared
        .data(from: URL(string: "https://fakestoreapi.com/products")!)
      return try JSONDecoder().decode([Product].self, from: data)
    },
    sendOrder: { cartItems in
      let payload = try JSONEncoder().encode(cartItems)
      var urlRequest = URLRequest(url: URL(string: "https://fakestoreapi.com/carts")!)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpMethod = "POST"
      
      let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw Failure() // APIClient.Failure(Error,Equatable)
      }
      
      return "Status: \(httpResponse.statusCode)"
    },
    fetchUserProfile: {
      let (data, _) = try await URLSession.shared
        .data(from: URL(string: "https://fakestoreapi.com/users/1")!)
      return try JSONDecoder().decode(UserProfile.self, from: data)
    }
  )
}
