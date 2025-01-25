# 방법 1: ObservableObject 인스턴스 하나로 통신
## 구조
```plain
┌──────────────────────────────────┐                   
│  SwiftUI Content View            │  ┌───────────────┐
│                                  │  │               │
│        ┌───────────────┐         │  │ WebView RP    │
│        │               │         │  │               │
│        │  WebViewStore ┼─────────┼──► - store       │
│        │               │         │  │               │
│        │  - WKWebView  │         │  │     ...       │
│        │  - other @Published vars│  │ (Delegate)    │
│        │               │         │  │ - Coordinator │
│        │               │         │  │  - Alert      │
│        └───────────────┘         │  │  - Confirm    │
│                                  │  │  - Prompt     │
│                                  │  │               │
│  - WebView RP instance ◄─────────┼──┼               │
│                                  │  │               │
```

## 요약
- View의 함수(메서드)는 store.webView.xxx 를 통해 실행하면 됨
  - 주소 이동, 뒤/앞으로 가기 등
- 값이 바뀌는 변수: WKWebView에서 제공하는 Publisher를 Combine을 통해 할당
  - 페이지 로딩율, 브라우저 제목 등
- Delegate에서 정의되는 함수(메서드)는 
  - 단순 메시지를 받아오는 경우 @Published를 통해 받아옴 (Alert)
  - 응답을 보내야 할 경우 async/await의 withContinuation을 통해 값을 기다리고 작업을 처리 (Confirm, Prompt)
