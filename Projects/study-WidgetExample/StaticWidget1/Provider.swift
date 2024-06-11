//
//  Provider.swift
//  StaticWidget1Extension
//
//  Created by 윤범태 on 6/11/24.
//

import WidgetKit

struct Provider: IntentTimelineProvider {
    /// 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        let configuration = ConfigurationIntent()
        configuration.texts = ["로딩 중입니다..."]
        
        return SimpleEntry(date: Date(), configuration: configuration)
    }
    
    /// 위젯 갤러리에서 보여지는 샘플 데이터를 보여줄 때 이 메서드 호출
    /// - context.isPreview가 true인 경우 위젯 갤러리에 샘플 스크린샷 표시됨
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            configuration.texts = try await getTexts()
            let entry = SimpleEntry(date: Date(), configuration: configuration)
            completion(entry)
        }
    }
    
    /// 위젯을 언제 업데이트 할건지?
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            await completion(timeline(for: configuration, in: context))
        }
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        
        // // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        // // 한 시간 간격(by adding hour)으로 entry값 업데이트
        // for hourOffset in 0 ..< 5 {
        //     let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        //     let entry = SimpleEntry(date: entryDate, configuration: configuration)
        //     entries.append(entry)
        // }
        
        // 3분 간격으로 업데이트
        for minOffset in 0..<20 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 3 * minOffset, to: currentDate)!
            configuration.texts = try? await getTexts()
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    /// 예제: 네트워크에서 텍스트 비동기로 fetch
    private func getTexts() async throws -> [String] {
        guard let url = URL(string: "https://meowfacts.herokuapp.com/?count=1") else {
            return ["URL이 없습니다."]
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let textModel = try JSONDecoder().decode(TextModel.self, from: data)
        
        return textModel.datas
    }
}
