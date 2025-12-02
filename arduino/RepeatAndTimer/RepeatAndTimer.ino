#define HALF_CYCLE 1000
#define SEG_G 3
#define SEG_F 4
#define SEG_E 5
#define SEG_D 6
#define SEG_C 7
#define SEG_B 8
#define SEG_A 9
#define SEG7_BIN0 10
#define SEG7_BIN1 11

#define COUNT_UP_INTERVAL_MILLISEC 100
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL1 500
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL2 80
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL3 20

#include <TimerOne.h>

void write_a_digit(byte digit, byte data);
void clear_7seg();
void write_10bits_to_4_digits(unsigned int bits);
void count_up();

void setup() {
  pinMode(A1, INPUT);

  pinMode(SEG_G, OUTPUT);
  pinMode(SEG_F, OUTPUT);
  pinMode(SEG_E, OUTPUT);
  pinMode(SEG_D, OUTPUT);
  pinMode(SEG_C, OUTPUT);
  pinMode(SEG_B, OUTPUT);
  pinMode(SEG_A, OUTPUT);
  pinMode(SEG7_BIN0, OUTPUT);
  pinMode(SEG7_BIN1, OUTPUT);

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
  unsigned int tmp; // 10 進数に変換するための一時変数
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
        count_up_interval = count_sequential > 30 ? COUNT_UP_INTERVAL_MILLISEC_LEVEL3 : (count_sequential > 2 ? COUNT_UP_INTERVAL_MILLISEC_LEVEL2: COUNT_UP_INTERVAL_MILLISEC_LEVEL1);
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
  static const byte SEG7_DIG0[] = {1, 0, 1, 0};
  static const byte SEG7_DIG1[] = {1, 1, 0, 0};
                                              
  // 2bit で表示桁を指定
  digitalWrite(SEG7_BIN0, SEG7_DIG0[digit]);
  digitalWrite(SEG7_BIN1, SEG7_DIG1[digit]);
  
  // 7SEG デコーダー
  // 対応する数字               0  1  2  3  4  5  6  7  8  9
  static const byte SEG_GP[] = {0, 0, 1, 1, 1, 1, 1, 0, 1, 1};
  static const byte SEG_FP[] = {1, 0, 0, 0, 1, 1, 1, 1, 1, 1};
  static const byte SEG_EP[] = {1, 0, 1, 0, 0, 0, 1, 0, 1, 0};
  static const byte SEG_DP[] = {1, 0, 1, 1, 0, 1, 1, 0, 1, 1};
  static const byte SEG_CP[] = {1, 1, 0, 1, 1, 1, 1, 1, 1, 1};
  static const byte SEG_BP[] = {1, 1, 1, 1, 1, 0, 0, 1, 1, 1};
  static const byte SEG_AP[] = {1, 0, 1, 1, 0, 1, 1, 1, 1, 1};
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

void count_up() {
  count++;
  write_10bits_to_4_digits(count);
  Serial.println(count);
}
