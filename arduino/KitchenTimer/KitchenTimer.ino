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

#define COUNT_UP_INTERVAL_MILLISEC_LEVEL1 1000
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL2 100
#define COUNT_UP_INTERVAL_MILLISEC_LEVEL3 20

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

void write_a_digit(byte digit, byte data);
void clear_7seg();
void write_10bits_to_4_digits(unsigned int bits);
void count_down();
unsigned int seconds_to_mmss_format(unsigned int sec);
byte digitalReadLike(byte sw);

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

  pinMode(2, OUTPUT);

  Timer1.initialize(1000000); // micro second でリセット間隔を指定
  Timer1.attachInterrupt(count_down); 

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

  static unsigned long count_up_interval = COUNT_UP_INTERVAL_MILLISEC_LEVEL2;

  switch(state) {
    case TimerStateSetting:
      if(change_mode == HIGH) {
        if(last_change_mode_sw == LOW && timecount > 0) {
          state = TimerStateCountDown;
        }
      }
      
      if(incre_sw == HIGH) {
        if(last_incre_sw == LOW){
          last_beat = now;
          state = TimerStateSettingIncrement;
        }
      }
      
      if(decre_sw == HIGH) {
        if(last_decre_sw == LOW){
          last_beat = now;
          state = TimerStateSettingDecrement;
        }
      }

      break;
    case TimerStateSettingIncrement:
      if(incre_sw == HIGH) {
        if(now - last_beat > count_up_interval) {
          timecount++;
          last_beat = now;
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
      
      // if(change_mode == HIGH) {
      //   state = TimerStateSetting;
      //   // TODO: stop beep
      // }
      break;
  }

  last_change_mode_sw = change_mode;
  incre_sw = last_incre_sw;
  decre_sw = last_decre_sw;

  write_10bits_to_4_digits(seconds_to_mmss_format(timecount));
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

unsigned int seconds_to_mmss_format(unsigned int sec) {
  return (sec / 60) * 100 + (sec % 60);
}

void count_down() {
  if(state == TimerStateCountDown) {
    if(timecount > 0) {
      timecount--;
    } else {
      state = TimerStateBeep;
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
