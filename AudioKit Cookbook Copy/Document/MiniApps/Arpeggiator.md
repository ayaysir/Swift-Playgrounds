## Arpeggiator

이 코드는 **ArpeggiatorConductor**라는 클래스를 정의하고 있으며, `AudioEngine`과 `AppleSampler`를 사용해 아르페지오 (Arpeggio) 기능을 구현하는 구조입니다. 또한 MIDI 신호를 받아서 음악을 재생하는 역할을 합니다.

### 클래스의 동작 원리:

#### 주요 속성
1. **engine**: `AudioEngine` 인스턴스로, 음악과 오디오 처리를 담당하는 오디오 엔진.
2. **instrument**: `AppleSampler` 인스턴스로, 샘플러 악기를 사용하여 MIDI 신호를 받아 음악을 연주합니다.
3. **sequencer**: `SequencerTrack` 객체로, 음표의 순서를 제어하는 시퀀서입니다.
4. **midiCallback**: MIDI 신호를 처리하는 `CallbackInstrument` 객체입니다.
5. **heldNotes**: 현재 눌린 음표들을 저장하는 배열입니다.
6. **arpUp**: 아르페지오가 위로 (UP) 가는지 아래로 (DOWN) 가는지를 판단하는 변수입니다.
7. **currentNote**: 현재 연주 중인 음표 번호를 저장합니다.
8. **sequencerNoteLength**: 시퀀서에서 각 음표의 길이를 나타내는 변수입니다.
9. **tempo**: 템포 (BPM)를 나타내며, 템포가 변경될 때 시퀀서의 템포도 업데이트됩니다.
10. **noteLength**: 음표 길이를 나타내며, 음표의 길이가 변경되면 시퀀서에 음표를 추가하거나 업데이트합니다.

#### 주요 메서드
1. **noteOn(pitch:point:)**:
   - `pitch` (음높이)를 받아서 `heldNotes` 배열에 추가합니다.
   - 음표가 눌리면 해당 음표가 `heldNotes`에 추가되고, 이는 아르페지오 로직에서 사용됩니다.
  
2. **noteOff(pitch:)**:
   - `pitch` (음높이)를 받아서 `heldNotes` 배열에서 해당 음표를 제거합니다.
   - 음표가 떼어지면 `heldNotes` 배열에서 삭제되고, 아르페지오 로직에서 해당 음표를 고려하지 않습니다.

3. **fireTimer()**:
   - `heldNotes` 배열에 따라 아르페지오 기능을 실행합니다.
   - `arpUp`이 `false`일 때 (아르페지오가 아래로 내려가고 있을 때) `heldNotes` 중 `currentNote`보다 큰 음표 중 가장 작은 음표를 `currentNote`로 설정합니다.
   - `arpUp`이 `true`일 때 (아르페지오가 위로 올라가고 있을 때) `heldNotes` 중 `currentNote`보다 작은 음표 중 가장 큰 음표를 `currentNote`로 설정합니다.
   - `instrument.play()`를 사용하여 현재 음표를 재생합니다.
   - `arpUp`이 `true`에서 `false`로 바뀔 때나 그 반대일 때, 아르페지오는 반대 방향으로 전환됩니다.

4. **초기화 (init)**:
   - `midiCallback`을 설정하여 MIDI 신호를 받을 때마다 `fireTimer()`를 호출합니다.
   - `engine.output`은 `PeakLimiter`로 설정되어 믹싱 후 신호가 왜곡되지 않도록 합니다.
   - `instrument.loadInstrument()`를 통해 샘플러 악기(`sawPiano1.exs`)를 로드하여 `instrument`에 설정합니다.
   - `sequencer`를 설정하여 기본적인 시퀀서를 만들어 주고, 초기 위치에서 음표를 재생하도록 설정합니다.

### 요약:
1. **MIDI 입력 처리**: MIDI 신호가 들어오면 `fireTimer()`를 호출하여 현재 눌려진 음표에 맞는 아르페지오를 연주합니다.
2. **아르페지오**: `heldNotes` 배열에 저장된 음표를 바탕으로 `arpUp` 값에 따라 음표를 순차적으로 재생합니다. 아르페지오는 위로 또는 아래로 진행될 수 있습니다.
3. **악기와 시퀀서**: `AppleSampler`와 `SequencerTrack`을 이용하여 음악을 연주하고, 시퀀서가 반복적으로 음표를 재생합니다.
4. **템포 및 음표 길이 설정**: 템포와 음표 길이가 변경되면, `sequencer`에 해당 정보를 반영하여 연주 스타일을 조정합니다.

이 클래스는 `ArpeggiatorConductor`를 통해 아르페지오 효과를 다루며, MIDI 신호에 반응하여 실시간으로 음을 처리하고 재생하는 구조입니다.
