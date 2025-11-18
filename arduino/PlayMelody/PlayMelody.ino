#include "pitches.h" // 周波数を NOTE_云々 で示すための定義を読み込む。

#define NOTE_NONE 0

// 一つの音は、周波数(Hz)と長さ(ms)で定義される
struct note {
  unsigned int frequency;
  unsigned long duration;
};

// NOTE_云々は pitches.h で定義、各音の長さは ms
// 4 分音符 = 500 ms ならだいたい ♩=120
struct note melody[] = {
    {NOTE_FS4, 250},  {NOTE_D4, 250}, {NOTE_A4, 250},   {NOTE_D4, 250},
    {NOTE_E4, 250},  {NOTE_A5, 250}, {NOTE_NONE, 250}, {NOTE_E3, 250},
    {NOTE_E4, 250},  {NOTE_FS4, 250}, {NOTE_E4, 250},   {NOTE_A4, 250},
    {NOTE_D4, 1000},
};

void setup() {
  pinMode(2, OUTPUT); // 圧電サウンダは 2 番ピンに接続
  
  for (int thisNote = 0; thisNote < sizeof(melody) / sizeof(note); thisNote++) {
    tone(2, melody[thisNote].frequency); // 音を出力
    delay(melody[thisNote].duration); // 音の長さ分だけ待つ。
  }
  noTone(2); // 鳴らしたままにならないよう音を消す。
}

void loop() {}
