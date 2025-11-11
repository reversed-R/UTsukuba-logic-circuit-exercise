#include "pitches.h" // 周波数を NOTE_云々 で示すための定義を読み込む。

// 一つの音は、周波数(Hz)と長さ(ms)で定義される
struct note {
  unsigned int frequency;
  unsigned long duration;
};

// NOTE_云々は pitches.h で定義、各音の長さは ms
// 4 分音符 = 500 ms ならだいたい ♩=120
struct note melody[] = {
  {NOTE_D5, 500},
  {NOTE_A4, 250}, // 音の間に切れ目を入れてない場合、
  {NOTE_A4, 125}, // 同じ音程ならタイで繋がっているように演奏
  {NOTE_F5, (250 + 125)} // 単純に長さを加算して設定しても良い
};

void setup() {
  pinMode(2, OUTPUT); // 圧電サウンダは 2 番ピンに接続
  // melody の長さを得る
  int melody_length = sizeof(melody) / sizeof(note);
  // melody[] の長さだけ音を出力
  for (int thisNote = 0; thisNote < melody_length ; thisNote++) {
    // tone(2, melody[thisNote]./**周波数**/); // 音を出力
    tone(2, melody[thisNote].frequency); // 音を出力
    // tone()は待つこと無く、
    // そのまま次の行へ
    // 行ってしまうので、
    // 次の様に待つ。
    delay(melody[thisNote].duration); // 音の長さ分だけ待つ。
    // noTone(2); // 一音毎に区切るときはここに入れる。
  }
  noTone(2); // 鳴らしたままにならないよう音を消す。
}

void loop() {}
