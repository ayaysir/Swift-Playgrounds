# Scope 사용 이유

```swift
 ProfileView(
   // 이 도메인(RootView)의 store: StoreOf<RootDomain>
   // 대상 store: StoreOf<ProfileDomain>
   store: store.scope(
       state: \.profileState, // RootDomain.State에 정의됨
       action: \.profile // RootDomain.Action에 정의됨
  )
)
```

Swift Composable Architecture(TCA)에서 `store.scope(state:action:)`는 **상위 도메인의 store를 하위 도메인에 맞게 "좁혀주는" 도구**입니다.
이걸 통해 **하위 View는 자신에게 필요한 상태와 액션만 알면 되게** 만들어줍니다.

---

## 🔍 전체 예시

```swift
ProfileView(
  store: store.scope(
    state: \.profileState,
    action: \.profile
  )
)
```

이건 다음을 의미합니다:

* **현재 도메인**: `RootDomain`
* **하위 도메인**: `ProfileDomain`
* `store`: `Store<RootDomain.State, RootDomain.Action>`
* `ProfileView`는 `Store<ProfileDomain.State, ProfileDomain.Action>`을 기대함
* 그러므로 \*\*스코핑(scope)\*\*을 사용해서 맞춰줍니다

---

## ✅ 왜 scope를 써야 하나요?

TCA에서는 **모든 상태와 액션을 하나의 트리**로 관리합니다.
그렇기 때문에 View 단에서도 `Store<하위 도메인>`을 직접 생성하는 것이 아니라
상위 `Store`에서 **부분 상태와 관련 액션만 떼서 주는** 방식이 필요합니다.

> 즉, scope는 "이 View가 쓸 상태와 액션만 추려서 주는 필터링 도구"입니다.

---

## ✅ `state: \.profileState` 설명

```swift
state: \.profileState
```

* `RootDomain.State` 안에 있는 `profileState`를 뽑아냅니다
* 타입: `ProfileDomain.State`

즉, **Root의 전체 상태 중 `ProfileView`에 필요한 일부만 주겠다**는 의미입니다.

---

## ✅ `action: \.profile` 설명

```swift
action: \.profile
```

* `RootDomain.Action` 중 `case profile(ProfileDomain.Action)` 액션을 지정합니다
* ProfileView 내부에서 발생한 액션을 RootDomain 액션으로 "승격"시켜주는 역할

즉, **ProfileView에서 발생한 액션을 루트로 전달할 방법을 정의**하는 것입니다.

---

## ✅ 이 구조의 효과

| 목적                 | 설명                                                                          |
| ------------------ | --------------------------------------------------------------------------- |
| View는 자기 도메인만 알면 됨 | `ProfileView`는 `ProfileDomain`만 알고 있으면 됨                                    |
| 상태 격리              | `ProfileView`는 `RootDomain.State` 전체를 몰라도 됨                                 |
| 액션 라우팅             | `ProfileDomain.Action`이 `RootDomain.Action.profile(...)`로 변환되어 루트 리듀서까지 도달함 |

---

## 🔁 흐름 요약 (액션 기준)

1. `ProfileView`에서 `.editNameTapped` 같은 액션 발생
2. 이건 `ProfileDomain.Action.editNameTapped` 형태임
3. `store.scope(action: \.profile)` 덕분에
   → `RootDomain.Action.profile(.editNameTapped)`로 변환됨
4. 루트 리듀서에서 해당 액션이 `.profile(let action)`으로 도착
5. `.ifLet(state: \.profileState, action: \.profile)` 덕분에
   `ProfileDomain` 리듀서로 다시 위임됨

---

## 🎯 비유로 이해하기

* `RootView`는 "회사 전체"
* `ProfileView`는 "인사부"
* `store.scope(state: \.profileState, action: \.profile)`는
  "인사부에서 일하는 데 필요한 서류와 메신저만 따로 주는 것"

---

## ✅ 정리

| 구성 요소            | 의미                            |
| ---------------- | ----------------------------- |
| `scope(state:)`  | 상위 상태 중 필요한 일부만 주입            |
| `scope(action:)` | 하위 액션을 상위 액션으로 변환해 루트로 전달     |
| 결과               | 하위 View는 자기 일만, 루트는 전체 흐름만 조율 |

---

# Scope의 연동 방법

지금 상황은 TCA에서 \*\*루트 도메인(`RootDomain`)\*\*과 **하위 도메인(`ProfileDomain`)**, 그리고 그것을 사용하는 \*\*뷰(`ProfileView`)\*\*가 **어떻게 연결되어 작동하는지**를 묻는 질문입니다.

---

## 🧭 전체 흐름 미리 보기

```
사용자 → ProfileView → store.send(.fetchUserProfile)
   → 액션: RootDomain.Action.profile(.fetchUserProfile)
      → 상태: RootDomain.State.profileState
         → 리듀서 연결: ProfileDomain.reduce
            → 비동기 API 호출 (fetchUserProfile)
               → 결과 도착: .fetchUserProfileResponse(...)
                  → 상태 갱신 (profile, dataState)
                     → ProfileView의 UI 반영 (Text / ProgressView)
```

---

## 🔗 연결 구조

### 1. `RootDomain`에서 `ProfileDomain`을 **state & action 으로 보유**하고 있음

```swift
struct RootDomain {
  struct State {
    var profileState = ProfileDomain.State()
  }

  enum Action {
    case profile(ProfileDomain.Action) // 하위 액션 수신용
  }
}
```

→ 이건 `RootDomain`이 **하위 도메인(Profile)의 상태와 액션을 "라우팅"할 준비가 되어 있다**는 뜻입니다.

---

### 2. `RootView` 또는 TabView 에서 `store.scope(...)` 사용

```swift
ProfileView(
  store: store.scope(
    state: \.profileState,
    action: \.profile
  )
)
```

* 상위: `Store<RootDomain.State, RootDomain.Action>`
* 하위로: `Store<ProfileDomain.State, ProfileDomain.Action>`로 **스코핑**
* 이 덕분에 `ProfileView`에서는 `store.send(.fetchUserProfile)`만 해도
  자동으로 `RootDomain.Action.profile(.fetchUserProfile)`로 변환되어 루트로 전달됨

---

## 🎬 이제 실제 동작 흐름 설명

### ✅ 1. 사용자 진입 → `ProfileView` 진입 시점

```swift
.task {
  store.send(.fetchUserProfile)
}
```

* `store`는 scoped 되어 있으므로 이 코드는 내부적으로:

  ```swift
  RootDomain.Action.profile(.fetchUserProfile)
  ```

* 루트 리듀서에서 `.profile(let action)` 케이스로 전달됨

---

### ✅ 2. 루트 리듀서에서 연결된 `ProfileDomain` 리듀서로 위임됨

```swift
Scope(state: \.profileState, action: \.profile) {
  ProfileDomain()
}
```

* `.profile(...)` 액션은 `ProfileDomain`의 리듀서로 전달됨
* 상태도 `.profileState`만 넘겨줌

---

### ✅ 3. `ProfileDomain` 리듀서 처리

```swift
case .fetchUserProfile:
  state.dataState = .loading
  return Effect.run { send in
    await send(.fetchUserProfileResponse(
      TaskResult {
        try await self.fetchUserProfile()
      }
    ))
  }
```

* `.fetchUserProfile` 액션을 받아 비동기 호출 실행
* 성공 시 `.fetchUserProfileResponse(.success(profile))` 액션을 send 함

---

### ✅ 4. 성공 액션이 다시 리듀서에 들어와서 처리됨

```swift
case .fetchUserProfileResponse(.success(let profile)):
  state.dataState = .complete
  state.profile = profile
```

* 상태가 갱신됨 → `profile`, `dataState`

---

### ✅ 5. UI 반영

`ProfileView`에서 다음과 같은 표현들이 이 상태를 참조하고 있음:

```swift
Text(store.profile.fullName.capitalized)
Text(store.profile.email)
if store.isLoading {
  ProgressView()
}
```

* `@ObservableState` 덕분에 상태가 바뀌면 SwiftUI가 자동으로 뷰를 업데이트함
* `store.isLoading`은 `dataState == .loading`를 감싼 computed property

---

## ✅ 정리: 무엇이 무엇과 연결되고, 어떻게 작동하는가?

| 역할     | 대상                                                         | 설명                             |
| ------ | ---------------------------------------------------------- | ------------------------------ |
| 상태 연동  | `RootDomain.State.profileState` ↔︎ `ProfileDomain.State`   | 루트에서 하위 상태를 소유                 |
| 액션 연동  | `RootDomain.Action.profile(...)` ↔︎ `ProfileDomain.Action` | 하위 액션을 상위로 보내고 처리              |
| 리듀서 연결 | `.scope(...) { ProfileDomain() }`                          | 액션과 상태가 연결되게 함                 |
| UI 연동  | `store.profile`, `store.isLoading`                         | 상태 변화를 기반으로 UI 업데이트            |
| 작업 시작  | `.task { store.send(...) }`                                | 진입 시점에 fetch 작업 시작             |
| API 호출 | `@Dependency(\.apiClient.fetchUserProfile)`                | 의존성 주입을 통해 fetchUserProfile 실행 |

---

# RootDomain이 모든 것을 관리하는 이유?

왜 `ProfileView`에서 사용하는 `StoreOf<ProfileDomain>`을 `ProfileDomain`에서 직접 만들지 않고,
굳이 **RootDomain이 `profileState`와 `profile 액션`을 갖고**,
`scope`를 통해 `ProfileDomain`으로 "넘겨주는" 구조로 만드는 이유를 설명드리겠습니다.

---

## 🧭 핵심 요약

> TCA에서는 모든 **state와 action을 한 트리로 구성**하기 때문에
> 루트 도메인(RootDomain)이 **모든 하위 도메인의 상태와 액션을 소유해야** 합니다.

---

## 🎯 왜 하위 도메인이 루트 바깥에 독립적으로 있으면 안 되는가?

만약 `ProfileDomain`이 직접 자기 Store를 만들고 쓰기 시작하면 이렇게 됩니다:

```swift
ProfileView(store: Store(initialState: ..., reducer: ProfileDomain()))
```

### 🚫 이 방식의 문제점:

| 문제           | 설명                                        |
| ------------ | ----------------------------------------- |
| 앱 상태 트리와 단절됨 | Profile 도메인이 전체 앱의 상태 트리에 속하지 않음          |
| 액션 흐름 통제 불가  | 루트 → Profile 액션 흐름 추적이 안 됨                |
| 공유 상태 불가     | 루트의 다른 도메인과 상태 공유가 어려움                    |
| 테스트 단절       | 루트에서 전체적인 테스트가 불가능함                       |
| 의존성 누락       | 루트에서 내려주는 의존성(APIClient 등)을 Profile에서 못 씀 |

---

## ✅ 그래서 어떻게 해야 하나?

### ▶ 루트 도메인이 \*\*전체 앱의 "마스터 상태 트리"\*\*가 되어야 합니다.

```swift
RootDomain.State {
  var profileState: ProfileDomain.State
  var productListState: ProductListDomain.State
  ...
}
```

### ▶ 액션도 마찬가지로 하위 액션을 래핑해야 합니다.

```swift
enum RootDomain.Action {
  case profile(ProfileDomain.Action)
  case productList(ProductListDomain.Action)
}
```

### ▶ 이후에 `.scope(...)`로 각각 하위 View로 연결해주는 구조를 만듭니다.

---

## 🧩 비유

| 구조              | 비유                      |
| --------------- | ----------------------- |
| RootDomain      | "앱의 종합 컨트롤 타워"          |
| ProfileDomain   | "프로필 부서"                |
| `.scope(...)`   | 부서와 타워를 연결하는 유선망        |
| store.send(...) | 타워에 보고하거나, 타워에서 명령받는 흐름 |

---

## 📌 요약

| 이유                         | 설명                                |
| -------------------------- | --------------------------------- |
| TCA는 단일 상태/액션 트리 구조를 지향함   | 전체 상태와 액션 흐름을 추적하고 관리하기 쉽게 만들기 위함 |
| 루트가 모든 상태와 액션의 소유권을 가져야 함  | 상태 공유, 액션 추적, 테스트, 의존성 관리가 쉬움     |
| 하위 도메인은 루트에 종속된 "모듈"로만 존재함 | 자체 Store를 만들지 않음, 루트의 일부로만 사용됨    |

---

## ✅ 결론

> ProfileDomain은 **독립적으로 작동하지 않으며**,
> 반드시 RootDomain의 **상태 일부(`profileState`)와 액션 일부(`.profile(...)`)로 포함되어야**
> 전체 앱 상태 트리와 연동되고, 액션 흐름과 의존성 주입도 제대로 작동하게 됩니다.


