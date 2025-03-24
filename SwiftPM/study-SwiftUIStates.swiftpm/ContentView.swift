import SwiftUI
import AlertKit

final class VM: ObservableObject {
  @Published var number = 0
}

struct ContentView: View {
  @State private var number = 0
  @State private var showAlert = true
  @State private var showTexts = true
  @ObservedObject private var obsVM = VM()
  @StateObject private var staVM = VM()
  
  var bindingValues: [Binding<Int>] {
    [
      $number,
      $obsVM.number,
      $staVM.number,
    ]
  }
  
  /*
   문제: @State 또는 VM.published가 변경될 때 화면에서 그리는 게 있다면 Alert이 계속 다시 뜬다.
   - 내부 @State를 직접 변경하는 경우 화면에 그리는게 없다면 OK
   - 뷰모델 값은 화면에 그리는게 없더라도 문제 발생
   - 내부 @State라도 일단 화면에 그려지고 있었다면 해당 뷰를 if문으로 숨겨도 문제 발생
   
   해결책 1: 버튼 액션에 if showAlert { showAlert = false } 삽입
   */
  var body: some View {
    VStack {
      if showTexts {
        ForEach(bindingValues.indices, id: \.self) { index in
          Text("\(bindingValues[index].wrappedValue)")
        }
      }
      
      Divider()
      
      Button {
        number = .random(in: 0...10000)
        hideAlertForcely()
      } label: {
        Label("Direct Access to Local State", systemImage: "globe")
      }
      
      ForEach(bindingValues.indices, id: \.self) { index in
        Button {
          bindingValues[index].wrappedValue = .random(in: 0...10000)
          hideAlertForcely()
        } label: {
          Label("State Index [\(index)]", systemImage: "globe")
        }
      }
      
      Divider()
      
      Button("Show State Variables") {
        showTexts.toggle()
      }
      
      Button("Turn on the Alert") {
        showAlert.toggle()
      }
    }
    .alert(
      isPresent: $showAlert,
      view: AlertAppleMusic17View(
        title: "Title",
        subtitle: "Content",
        icon: .error
      )
    )
  }
  
  private func hideAlertForcely() {
    if showAlert {
      showAlert = false
    }
  }
}
