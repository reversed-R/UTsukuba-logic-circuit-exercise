#import "../template.typ": *
#import "../bxbibwrite.typ": *
#import "@preview/tenv:0.1.2": parse_dotenv
#import "@preview/codelst:2.0.2": sourcecode
#show: use-bib-item-ref

#let env = parse_dotenv(read("../.env"))

// #show: project.with(
//   week: "最終課題",
//   subtitle: "Arduino",
//   authors: (
//     (name: env.STUDENT_NAME, email: "学籍番号：" + env.STUDENT_ID, affiliation: "所属：" + env.STUDENT_AFFILIATION),
//   ),
//   date: "2025 年 12 月 22 日",
// )

== 全体について

+ 以下は、Arudino nano(AVR ATmega328Old)と7セグメントディスプレイや圧電サウンダやタクトスイッチなどを搭載した本授業貸し出しのボードで行った。

+ 後半の課題に関連するソースコードはGitHubリポジトリ#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise")にすべて置いてある。このレポートについても同様である。

+ arudino-cliを使った。バージョンは以下のとおりである。
  #sourcecode[```bash
  $ arduino-cli version
  arduino-cli  Version: 1.4.0 Commit: b7000970fe663f0106e359bedf5a5f89bc61c038 Date:
  ```]
  上のリポジトリにもあるが、以下のようなコマンドを用いることで本授業のボード用のコンパイル及び書き込みが可能である。
  (なお、記録として残しておくが、書き込み装置を`--programmer avrispmkii`として設定すると逆に失敗してしまった。)
  #sourcecode[```Makefile
  TARGET=Dynamic_Drive
  
  compile:
  	cd .. && sudo arduino-cli compile --fqbn arduino:avr:nano:cpu=atmega328old $(TARGET)
  
  upload:
  	cd .. && sudo arduino-cli upload -b arduino:avr:nano:cpu=atmega328old -p /dev/ttyUSB0 $(TARGET) --verbose
  
  install:
  	sudo arduino-cli core install arduino:avr
  ```]

== 6章 [4] ダイナミック点灯と圧電サウンダの駆動

=== ダイナミック点灯

以下のコードで#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/Dynamic_Drive/Dynamic_Drive.ino")]、指導書で推奨されているように、7セグメントのデコーダーのパターンを完成させるとともに、2bitの信号で表示桁を指定できるようにしてダイナミック点灯を実現した。

#sourcecode[```c
/** 省略 **/
void setup() {
  pinMode(13, OUTPUT);

  pinMode(SEG_G, OUTPUT);
  pinMode(SEG_F, OUTPUT);
  pinMode(SEG_E, OUTPUT);
  pinMode(SEG_D, OUTPUT);
  pinMode(SEG_C, OUTPUT);
  pinMode(SEG_B, OUTPUT);
  pinMode(SEG_A, OUTPUT);
  pinMode(SEG7_BIN0, OUTPUT);
  pinMode(SEG7_BIN1, OUTPUT);
}

void loop() {
  static byte digit[] = {3, 2, 1, 0};
  
  for(byte i = 0; i <= 3; i++) {
    write_a_digit(i, digit[i]);
    delay(1);
    clear_7seg();
  }
}

void write_a_digit(byte digit, byte data) {
  static const byte SEG7_DIG0[] = {1, 0, 1, 0};
  static const byte SEG7_DIG1[] = {1, 1, 0, 0};
                                              
  // 2bit で表示桁を指定
  digitalWrite(SEG7_BIN0, SEG7_DIG0[digit]);
  digitalWrite(SEG7_BIN1, SEG7_DIG1[digit]);
  
  // 7SEG デコーダー
  // 対応する数字               0  1  2  3  4  5  6  7  8  9
  static const byte SEG_GP[] = {0, 0, 1, 1, 1, 1, 1, 0, 1, 1};
  static const byte SEG_FP[] = {1, 0, 0, 0, 1, 1, 1, 1, 1, 1}; //ここの
  static const byte SEG_EP[] = {1, 0, 1, 0, 0, 0, 1, 0, 1, 0}; //パターンを
  static const byte SEG_DP[] = {1, 0, 1, 1, 0, 1, 1, 0, 1, 1}; //完成
  static const byte SEG_CP[] = {1, 1, 0, 1, 1, 1, 1, 1, 1, 1}; //させる。
  static const byte SEG_BP[] = {1, 1, 1, 1, 1, 0, 0, 1, 1, 1}; //
  static const byte SEG_AP[] = {1, 0, 1, 1, 0, 1, 1, 1, 1, 1}; //
  
  if (data < 10) { // 0～9 の時はその数字を表示
    digitalWrite(SEG_G, SEG_GP[data]);
    digitalWrite(SEG_F, SEG_FP[data]);
    digitalWrite(SEG_E, SEG_EP[data]);
    digitalWrite(SEG_D, SEG_DP[data]);
    digitalWrite(SEG_C, SEG_CP[data]);
    digitalWrite(SEG_B, SEG_BP[data]);
    digitalWrite(SEG_A, SEG_AP[data]);
  } else { // デバッグ時に判りやすいように、
    //10 以上の時は数字でも文字でも無いパターンを表示
    digitalWrite(SEG_G, 1);
    digitalWrite(SEG_F, 0);
    digitalWrite(SEG_E, 0);
    digitalWrite(SEG_D, 1);
    digitalWrite(SEG_C, 0);
    digitalWrite(SEG_B, 0);
    digitalWrite(SEG_A, 1);
  }
}

void clear_7seg() {
  static const byte SEG7_DIG0[] = {1, 0, 1, 0};
  static const byte SEG7_DIG1[] = {1, 1, 0, 0};
  
  for(byte i = 0; i <= 3; i++) {
    digitalWrite(SEG7_BIN0, SEG7_DIG0[i]);
    digitalWrite(SEG7_BIN1, SEG7_DIG1[i]);
  
    digitalWrite(SEG_G, 0);
    digitalWrite(SEG_F, 0);
    digitalWrite(SEG_E, 0);
    digitalWrite(SEG_D, 0);
    digitalWrite(SEG_C, 0);
    digitalWrite(SEG_B, 0);
    digitalWrite(SEG_A, 0);
  }
}
```]

=== 圧電サウンダ

音符に対応する周波数を得るヘッダとして `pitches.h` が提供されており、
#link("https://docs.arduino.cc/built-in-examples/digital/toneMelody/#code")からダウンロードできるため使用した。

以下のコード#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/PlayMelody/PlayMelody.ino")]で起動時に1度だけ(つまり、`setup()`内で。`loop()`は使わない)メロディーを流すことが出来る。

`for`文の終了条件は重要であると思われるので説明すると、
`for (int thisNote = 0; thisNote < sizeof(melody) / sizeof(note); thisNote++)`
として、`sizeof`演算子で`note`の配列である`melody`のバイト数を取得し、次の`sizeof`演算子で`note`構造体のバイト数を取得することで1要素のバイト数を得て、割ることで配列の要素数分だけループが回るようにしている。
もちろん`sizeof(melody[0])`として1要素のバイト数を取得してもよい。
なお、`sizeof`演算子は式のサイズを取得する時はカッコがなくてよいが、今回の`sizeof(note)`のように型のサイズを取得するときは必ずカッコが要ることに注意が必要である。

独自のフレーズとしてはコンビニエンス性を感じられるようなメロディを設定した。

また、休符を表すために`#define NOTE_NONE 0`とすることで、周波数0、つまり音がならない期間を実現した。



#sourcecode[```c
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
```]

== 7章 [3] タクトスイッチと可変抵抗の値の読み込み

=== タクトスイッチの読み込み

以下のコード#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/ReadSwitch/ReadSwitch.ino")]でタクトスイッチを読み込み、
4スイッチを4桁の各桁として押すたびに0\~9の範囲で加算されていくようにし、その結果を7セグメントディスプレイに表示した。

`static byte last_sw[4]`に各スイッチが前のループで押されていたのかを記録して、立ち上がりを検知することで、チャタリングを除去している。

アナログ読み込みの閾値`ANALOG_READ_SEPARATOR`は、読み込まれる値が0\~1023であるためその中間である512として定義してある。

#sourcecode[```c
/** 省略 **/

#define ANALOG_READ_SEPARATOR 512

void setup() {
  pinMode(13, OUTPUT);

  /** 省略(7セグ表示のためのピン) **/
}

void loop() {
  int tmp_sw[4]; // 一時的に読み取った値を保持
  byte current_sw[4] ; // 現在のスイッチの状態を保持
  static byte last_sw[4]; // 一つ前のスイッチの状態を保持
  static byte digit[] = {0, 0, 0, 0}; // 各スイッチに対応する値を保持
  // 統一して扱うために全てアナログで読む。
  // index と表示位置の関係は一対一。 0 右端の桁、3 左端の桁
  tmp_sw[0] = analogRead(A2);
  tmp_sw[1] = analogRead(A3);
  tmp_sw[2] = analogRead(A6);
  tmp_sw[3] = analogRead(A7);
  for (byte i = 0; i <= 3; i++) { // 全てのタクトスイッチ(桁)について
    // 読み取った値が閾値以上なら current_sw[i] の値を 1 にする。
    // 前のサイクルで押されておらず、このサイクルで押されているなら
    // 該当する桁の値を +1、もし 10 になったら 0 に戻す。
    if(tmp_sw[i] >= ANALOG_READ_SEPARATOR) {
      if(last_sw[i] == 0){
        digit[i] = (digit[i] + 1) % 10;
      }
      
      current_sw[i] = 1;
    } else {
      current_sw[i] = 0;
    }
    
    last_sw[i] = current_sw[i];
    write_a_digit(i, digit[i]);
    delay(1);
    clear_7seg();
  }
}

void write_a_digit(byte digit, byte data) {
  /** 省略 **/
}

void clear_7seg() {
  /** 省略 **/
}
```]

=== 可変抵抗の値の読み込み

以下のコード#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/ReadVR/ReadVR.ino")]で、
可変抵抗の値を読み込み、0\~1023の範囲で7セグメントディスプレイに4桁で表示した。

重要なのは`write_10bits_to_4_digits()`の実装で、
10bitの値(`unsigned int`で渡しているがその下位10bit分)を7セグメントディスプレイに4桁で表示するために、
以下のように各桁を計算した。


#sourcecode[```c
/** 省略 **/

void setup() {
  pinMode(A1, INPUT);

  /** 省略(7セグ表示のためのピン) **/
}

void loop() {
  unsigned int vr;
  byte digits[4];
  vr = analogRead(A1);
  
  write_10bits_to_4_digits(vr);
}

void write_a_digit(byte digit, byte data) {
  /** 省略 **/
}

void clear_7seg() {
  /** 省略 **/
}

void write_10bits_to_4_digits(unsigned int bits) {
  byte digits[4];
  digits[0] = bits % 10;
  digits[1] = (bits / 10) % 10;
  digits[2] = (bits / 100) % 10;
  digits[3] = (bits / 1000) % 10;
  
  for (byte i = 0; i < 4; i++) {
    write_a_digit(i , digits[i]);
    delay(1);
    clear_7seg();
  }
}
```]

== 8章 [3] キーリピートと割り込み

以下のコード#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/RepeatAndTimer/RepeatAndTimer.ino")]で、
キーリピートと割り込みを実装した。

=== キーリピートについて

`last_sw`でチャタリングを除去している。

キーリピートを実現するためにスイッチ押しはじめの時刻`clicked`と`last_beat`を保持しているが、
今よく見ると`clicked`を最後にカウントアップ判定があったときに更新しており`last_beat`を使っていないため、名前に即していない。
しかしながら、最後にカウントアップされたときからカウントアップ間隔`count_up_interval`分が過ぎているならばカウントアップするという動作を取っているため、結果的に得られるのは同じである。

つまり要件(e) `タクトスイッチを1秒程度(repeat delay)押し続けるとキーリピートとして扱い、0.1 秒程度の間隔(interval)で”count”を1加算する`を満たしている。

また、コメントにもあるようにキーリピートのカウントアップ間隔が押し続けた時間に応じて短くなっていくと使いやすいと考え、追加でその実装を加えた(この実装は指導書で求められている実装をサブセット的に包含しているため特に問題はない)。
カウントアップの間隔(`count_up_interval`)のレベルを`COUNT_UP_INTERVAL_MILLISEC_LEVEL1` \~ `*3` までの3段階設けて、何回連続でカウントアップされているかを保持する`count_sequential`の値でレベルが大きくなるように分岐している(三項演算子を使用している部分)。

=== 割り込みについて

割り込みは`TimerOne.h`を利用した。

  (
  なお、記録として残しておくが、`arduino-cli`はここでも便利であり、`arduino-cli lib install <library-name>`でライブラリのインストールが可能である。
  ただし、`~/.arduino15/arduino-cli.yaml`に以下の設定を追加することで、`~/Arduino/libraries/`以下にダウンロードされるライブラリへのパスが通ることに注意が必要である。
  #sourcecode[```yaml
  board_manager:
      additional_urls: []
  directories:
      user: /home/<user-name>/Arduino
  ```]
  )

`setup()`内で、`Timer1`を1秒間隔で割り込むようにする初期化と、割り込みのハンドラ関数を`count_up`とする設定を行っている。

割り込みのハンドラ関数`count_up()`では、グローバル変数`count`(指導書にも要件(a)で定義するように指定されていた)を加算している。

よって、要件(c) `count は割り込みによって一定間隔で加算される。`を満たしている。

#sourcecode[```c
/** 省略 **/

#define COUNT_UP_INTERVAL_MILLISEC_LEVEL1 1000
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL2 100
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL3 20

#include <TimerOne.h>

/** 省略 **/

void setup() {
  pinMode(A1, INPUT);

  /** 省略(7セグ表示のためのピン) **/

  Timer1.initialize(1000000); // micro second でリセット間隔を指定
  Timer1.attachInterrupt(count_up); 

  Serial.begin(9600);
}

unsigned int count = 0;

void loop() {
  byte current_sw; // 現在のスイッチの状態
  static byte last_sw = 0; // 一つ前のスイッチの状態
  static unsigned long clicked = 0; // スイッチ押し始めの時刻
  static unsigned long last_beat = 0; // キーリピートした時刻
  unsigned int now; // 現在時刻
  byte i; // ループ制御変数
  current_sw = digitalRead(16); // 現在のスイッチの状態を読む // 16 = A2 共用ピン
  now = millis(); // 現在時刻を記憶
  
  // どうせだし、押し続けた時間に応じてカウントアップ間隔が短くなっていくと使いやすかろうということで実装した。
  // count_up_interval はLEVEL1 ~ 3まであり間隔が短くなっていく
  // count_sequential は連続で何回カウントアップされているか(countでは求まらない)を保持
  static unsigned long count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL1;
  static unsigned int count_sequential = 0;

  if(current_sw == HIGH) {
    if(last_sw == LOW){
      clicked = now;
    } else {
      last_beat = now;
      if(last_beat - clicked > count_up_interval) {
        count++;
        count_sequential++;
        clicked += count_up_interval;
        count_up_interval = count_sequential > 50 ? COUNT_UP_INTERVAL_MILLISEC_LEVEL3 : (count_sequential > 1 ? COUNT_UP_INTERVAL_MILLISEC_LEVEL2: COUNT_UP_INTERVAL_MILLISEC_LEVEL1);
      }
    }
  } else {
    if(last_sw == HIGH) {
      count++;
      count_sequential = 0;
    }
  }

  last_sw = current_sw; // 一つ前のキーの値を今の値で更新
  
  write_10bits_to_4_digits(count);
}

void write_a_digit(byte digit, byte data) {
  /** 省略 **/
}

void clear_7seg() {
  /** 省略 **/
}

void write_10bits_to_4_digits(unsigned int bits) {
  /** 省略 **/
}

void count_up() {
  count++;
  write_10bits_to_4_digits(count);
  Serial.println(count);
}
```]

== 9章 [2] キッチンタイマー

以下のコード#footnote[#link("https://github.com/reversed-R/UTsukuba-logic-circuit-exercise/blob/main/arduino/KitchenTimer/KitchenTimer.ino")]でキッチンタイマーを実装した。

なお、スイッチの割当は
+ `17/A3`: モード切替
+ `16/A2`: 加算
+ `A6`: 減算
である。

今回のキッチンタイマーは、以下の状態を持ち、これらの間で状態遷移が起こる。
+ `TimerStateSetting`: 設定モード。
  要件(e)に準拠し、カウントダウンモードへの切り替えスイッチが押された時、`timecount`が0でないならばカウントダウンモード`TimerStateCountDown`へ移行する。
  加減算スイッチに応じて直ちにそれぞれのモード(`TimerStateSettingIncrement`, `TimerStateSettingDecrement`)へ移行する。
+ `TimerStateSettingIncrement`: キーリピートによる加算モード。
  キーリピートはこちらでは正しく`last_beat`と現在時刻との差がキーリピート間隔`count_up_interval`より大きいかを検知して加算し、`last_beat`を更新する手法を取っている。
  キーリピートの初回は`count_up_interval`が`COUNT_UP_INTERVAL_MILLISEC_LEVEL1 1000`になっているため1秒待ち、それ以降は`COUNT_UP_INTERVAL_MILLISEC_LEVEL2 100`となり0.1秒毎に更新されるようになっている。
+ `TimerStateSettingDecrement`: キーリピートによる減算モード。
  要件にはないが、減算スイッチが押されても0を下回ることはないようにチェックを入れている。そのことを除けば加算と同様。
+ `TimerStateCountDown`: カウントダウンモード。
  この間、要件(f)のように設定モードに復帰可能であり、要件(j)のように加減算スイッチは無効である。
  また、0までカウントダウンするとビープモード`TimerStateBeep`に移行する(ここのみ`count_down`関数内で実装)。
+ `TimerStateBeep`: カウントダウン終了後のビープ音声がなっている際のモード。
  6章同様`delay()`を用いた古典的方法なのでビープ音声がなっている間何も操作ができなくなってしまう。これを回避するためには`millis()`などを利用して自前で時刻経過に基づく音声出力の開始終了を行うなどの方法が考えられる。
  TAの方に質問したところ、今回の課題ではそれは含めなくて良いとのことであったので、今回はビープ音声が鳴って短時間立つと終了し、その間操作はできないという実装になっている。

これらはすべて`switch`文内の条件分岐によって実装されている。

要件にはないが、減算スイッチが押されても0を下回ることはないようにチェックを入れている。

タクトスイッチの読み込みはすべてディジタルに行いたいが、今回のボードはアナログディジタル共用の16, 17番ピンの2ピンしかなく、キッチンタイマーに必要な3つに足りないため、1つはアナログ読み込みをして閾値のチェックをすることで実質的にディジタルに変換する必要がある。
これを、`digitalReadLike()`関数に隠蔽し、ディジタル読み込みライクに使えるようにした。

チャタリングを除去するため、
+ `change_mode`に対応して`last_change_mode_sw`
+ `incre_sw`に対応して`last_incre_sw`
+ `decre_sw`に対応して`last_decre_sw`
をそれぞれ設けて、立ち上がりを検知するようにした。

割り込みの開始`Timer1.attachInterrupt()`を`setup()`内で行ってしまうと、常に割り込みが1秒間隔で起こり、タイマーカウントダウンの最初の1回は1秒未満で行われてしまう。
これを回避するために、設定モード`TimerStateSetting`においてカウントダウンモード`TimerStateCountDown`への変更が検知されたときに始めて`Timer1.attachInterrupt()`を実行するようにした。
また、そうするとカウントダウンモードへ変更する際に`Timer1.attachInterrupt()`した瞬間に最初の割り込みが実行されてしまい、カウントダウンの最初の1秒が0秒で行われてしまうので、
`count_down()`関数内の実装で`static bool is_first_count_down_sec = true;`を置き、最初の1回の割り込みではカウントダウンは実行しないように分岐している。

指導書の要件(a)にある通り`timecount`変数は秒単位の時刻を保持するため、これを7セグメントディスプレイに表示するに当たって`mm:ss`形式に変換する必要があるが、`seconds_to_mmss_format()`関数内にこれを実装し、容易に使えるようにした。


#sourcecode[```c
/** 省略 **/

#define COUNT_UP_INTERVAL_MILLISEC_LEVEL1 1000
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL2 100

#include "pitches.h"
#include <TimerOne.h>

struct note {
  unsigned int frequency;
  unsigned long duration;
};

struct note melody[] = {
  {NOTE_D7, 300},
  {NOTE_D7, 300},
  {NOTE_D7, 300},
};

/** 省略 **/

void setup() {
  pinMode(A1, INPUT);

  /** 省略(7セグ表示のためのピンなど) **/

  pinMode(2, OUTPUT);

  Timer1.initialize(1000000); // micro second でリセット間隔を指定

  Serial.begin(9600);
}

unsigned int timecount = 0; // second

typedef enum {
  TimerStateSetting,
  TimerStateSettingIncrement,
  TimerStateSettingDecrement,
  TimerStateCountDown,
  TimerStateBeep,
} TimerState;

TimerState state = TimerStateSetting;

void loop() {
  // 一つ前のスイッチの状態
  static byte last_sw = LOW;
  static byte last_incre_sw = LOW;
  static byte last_decre_sw = LOW;
  static byte last_change_mode_sw = LOW;
  static unsigned long last_beat = 0; // キーリピートした時刻
  
  byte incre_sw = digitalRead(16);
  byte decre_sw = digitalReadLike(A6);
  byte change_mode = digitalRead(17);
  
  unsigned int now = millis(); // 現在時刻を記憶

  static unsigned long count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL1;

  switch(state) {
    case TimerStateSetting:
      if(change_mode == HIGH) {
        if(last_change_mode_sw == LOW && timecount > 0) {
          state = TimerStateCountDown;
          Timer1.detachInterrupt(); 
          Timer1.attachInterrupt(count_down); 
        }
      }
      
      if(incre_sw == HIGH) {
        if(last_incre_sw == LOW){
          timecount++;
          last_beat = now;
          state = TimerStateSettingIncrement;
          count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL1;
        }
      }
      
      if(decre_sw == HIGH) {
        if(last_decre_sw == LOW){
          if(timecount > 0) {
            timecount--;
          }
          last_beat = now;
          state = TimerStateSettingDecrement;
          count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL1;
        }
      }

      break;
    case TimerStateSettingIncrement:
      if(incre_sw == HIGH) {
        if(now - last_beat > count_up_interval) {
          timecount++;
          last_beat = now;
          count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL2;
        }
      } else {
        state = TimerStateSetting;
      }
      
      break;
    case TimerStateSettingDecrement:
      if(decre_sw == HIGH) {
        if(now - last_beat > count_up_interval) {
          if(timecount > 0) {
            timecount--;
          }
          last_beat = now;
          count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL2;
        }
      } else {
        state = TimerStateSetting;
      }
      
      break;
    case TimerStateCountDown:
      if(change_mode == HIGH) {
        if(last_change_mode_sw == LOW) {
          state = TimerStateSetting;
        }
      }
      break;
    case TimerStateBeep:
      for(int i = 0; i < sizeof(melody) / sizeof(note); i++) {
        tone(2, melody[i].frequency);
        delay(melody[i].duration);
        noTone(2);
      }
      state = TimerStateSetting;
      
      break;
  }

  last_change_mode_sw = change_mode;
  incre_sw = last_incre_sw;
  decre_sw = last_decre_sw;

  write_10bits_to_4_digits(seconds_to_mmss_format(timecount));
}

void write_a_digit(byte digit, byte data) {
  /** 省略 **/
}

void clear_7seg() {
  /** 省略 **/
}

void write_10bits_to_4_digits(unsigned int bits) {
  /** 省略 **/
}

unsigned int seconds_to_mmss_format(unsigned int sec) {
  return (sec / 60) * 100 + (sec % 60);
}

void count_down() {
  static bool is_first_count_down_sec = true;
  
  if(state == TimerStateCountDown) {
    if(timecount > 0) {
      if(!is_first_count_down_sec) {
        timecount--;
      } else {
        is_first_count_down_sec = false;
      }
    } else {
      state = TimerStateBeep;
      is_first_count_down_sec = true;
    }
  }
  
  write_10bits_to_4_digits(seconds_to_mmss_format(timecount));
}

byte digitalReadLike(byte sw) {
  if(analogRead(sw) > 512) {
    return HIGH;
  } else {
    return LOW;
  }
}
```]



// #bibliography-list(
//   title: "参考文献", // 節見出しの文言
// )[
// #bib-item(<reference>)[hoge, https://example.com, 2025 年 12 月 dd 日閲覧]
// ]
