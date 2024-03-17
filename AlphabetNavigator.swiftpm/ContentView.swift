import SwiftUI

let alphabet: [String] = (65...90).map { String(UnicodeScalar($0)!) }

struct ContentView: View {
  @State private var searchText = ""
  var contacts = [
    "Chris", "Ryan", "Allyson", "Ryan", "Jonathan", "Ryan", "Brendan", "Ryaan", "Jaxon", "Riner", "Leif", "Adams", "Frank", "Conors", "Allyssa", "Bishop", "Justin", "Bishop", "Johnny", "Appleseed", "George", "Washingotn", "Abraham", "Lincoln", "Steve", "Jobs", "Steve", "Woz", "Bill", "Gates", "Donald", "Trump", "Darth", "Vader", "Clark", "Kent", "Bruce", "Wayne", "John", "Doe", "Jane", "Doe", "Rei", "Kim", "James", "Elephant", "Julius", "Fucik", "Kane", "Hammersmith",
  ].sorted()
  
  func contactsFilter(by letter: String) -> [String] {
    contacts.filter { $0.prefix(1) == letter }
  }
  
  var body: some View {
    ScrollViewReader { scrollProxy in
      List {
        ForEach(alphabet, id: \.self) { letter in
          Section(header: Text(letter).id(letter)) {
            ForEach(contactsFilter(by: letter), id: \.self) { contact in
              HStack {
                Image(systemName: "person.circle.fill")
                  .font(.largeTitle)
                  .padding(.trailing, 5)
                Text(contact)
              }
            }
          }
        }
      }
      .navigationTitle("Contacts")
      .listStyle(PlainListStyle())
      .overlay(alignment: .top) {
        AlphabetNavigator(scrollViewProxy: scrollProxy)
      }
    }
  }
}

struct AlphabetNavigator: View {
  let scrollViewProxy: ScrollViewProxy
  
  @GestureState private var dragLocation: CGPoint = .zero
  @State private var currentLetter = ""
  
  func dragObserver(title: String) -> some View {
    GeometryReader { geometry in
      dragObserver(geometry: geometry, title: title)
    }
  }

  func dragObserver(geometry: GeometryProxy, title: String) -> some View {
    if geometry.frame(in: .global).contains(dragLocation) {
      DispatchQueue.main.async {
        currentLetter = title
        
        withAnimation {
          scrollViewProxy.scrollTo(title, anchor: .top)
        }
      }
    }
    
    return Rectangle().fill(.clear)
  }
  
  var body: some View {
    VStack {
      ForEach(alphabet, id: \.self) { letter in
        HStack {
          Spacer()
          Text(letter)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.cyan)
            .padding(.trailing, 7)
            .opacity(letter == currentLetter ? 0.3 : 1)
          .background(dragObserver(title: letter))
        }
      }
    }
    .gesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .global)
        .updating($dragLocation) { value, state, _ in
          state = value.location
        }
    )
    .onChange(of: currentLetter) { _ in
      if currentLetter != "" {
        Vibration.light.vibrate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
          withAnimation {
            currentLetter = ""
          }
        }
      }
    }
  }
}
