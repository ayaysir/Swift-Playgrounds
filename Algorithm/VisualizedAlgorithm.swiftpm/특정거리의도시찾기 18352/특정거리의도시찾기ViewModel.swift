//
//  특정거리의도시찾기ViewModel.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/08.
//

import Foundation

final class 특정거리의도시찾기ViewModel: ObservableObject {
    @Published var mapInfos: [MapInfo?] = [
        nil,
        .init(rawText:
        """
        4 4 2 1
        1 2
        1 3
        2 3
        2 4
        """),
        .init(rawText:
        """
        4 3 2 1
        1 2
        1 3
        1 4
        """),
        .init(rawText:
        """
        4 4 1 1
        1 2
        1 3
        2 3
        2 4
        """)
    ]
}
