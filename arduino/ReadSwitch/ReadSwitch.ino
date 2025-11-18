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

#define ANALOG_READ_SEPARATOR 512

void write_a_digit(byte digit, byte data);
void clear_7seg();

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
  } else { // デバッグ時に判りやすいように、10 以上の時は数字でも文字でも無いパターンを表示
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
