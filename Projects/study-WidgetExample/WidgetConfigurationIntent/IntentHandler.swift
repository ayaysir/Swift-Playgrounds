//
//  IntentHandler.swift
//  WidgetConfigurationIntent
//
//  Created by 윤범태 on 6/12/24.
//

import Intents

/*
 위젯 Configuration 추가하기
 */

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func provideFavoriteEmojiOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<NSString> {
        INObjectCollection(items: ["🤡", "🤖", "🐠"])
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
