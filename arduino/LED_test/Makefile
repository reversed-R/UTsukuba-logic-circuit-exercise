TARGET=LED_test

compile:
	cd .. && sudo arduino-cli compile --fqbn arduino:avr:nano:cpu=atmega328old $(TARGET)
	# sudo arduino-cli compile --fqbn arduino:avr:nano $(TARGET)

upload:
	cd .. && sudo arduino-cli upload -b arduino:avr:nano:cpu=atmega328old -p /dev/ttyUSB0 $(TARGET) --verbose
	# sudo arduino-cli upload -b arduino:avr:nano:cpu=atmega328old -p /dev/ttyUSB0 $(TARGET) --programmer avrispmkii --verbose

install:
	sudo arduino-cli core install arduino:avr
