ZIP=zip

all: zip6 zip7 zip8 zip9

zip6: Dynamic_Drive PlayMelody
	cp -r Dynamic_Drive tmp/section6 && \
	cp -r PlayMelody tmp/section6 && \
	$(ZIP) -r tmp/section6.zip tmp/section6 

zip7: ReadSwitch ReadVR
	cp -r ReadSwitch tmp/section7 && \
	cp -r ReadVR tmp/section7 && \
	$(ZIP) -r tmp/section7.zip tmp/section7 

zip8: RepeatAndTimer
	$(ZIP) -r tmp/section8.zip RepeatAndTimer

zip9: KitchenTimer
	$(ZIP) -r tmp/section9.zip KitchenTimer

.PHONY: zip6 zip7 zip8 zip9
