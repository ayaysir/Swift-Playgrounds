//
//  AudioUnitSpeech.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/6/25.
//

/*
 - AudioToolbox의 Speech기능은 삭제되어 예제 실행 불가
 ------------
 
 * 반향 효과를 가진 음성 합성기의 오디오 유닛 그래프
 
 [AU 음성 합성] -> [AUMatrixReverb] -> [기본 출력 유닛] -> 하드웨어...
 
 * 그래프에 AudioComponentDescription 및 AUNode 추가
 AUGraphAddNode(graph, &reverbCD, &reverbNode)
 
 * 음성 합성기의 AU의 출력을 반향 유닛 노드의 입력에 연결
 AUGraphConnectNodeInput(graph, speechNode, 0, reverbNode, 0)
 
 * 반향 AU의 출력을 출력 노드의 입력에 연결
 AUGraphConnectNodeInput(graph, reverbNode, 0, outputNode, 0)
 
 - 모든 유닛은 오직 하나의 스트림만 생성/수신하므로 모두 버스 0을 사용한다.
 
 * 리버브 노드에 노드 정보(AudioUnit) 추가
 AUGraphNodeInfo(graph, reverbNode, nil, &reverbUnit)
 
 * 리버브의 룸 타입 설정
 AudioUnitSetProperty(reverbUnit, reverbRoomType, 0, &roomType, size)
 
 * CAShow: 그래프의 모든 노드 목록과 연결, 스트림 타입을 로그로 남긴다.
 CAShow(graph)
 
 
 */
