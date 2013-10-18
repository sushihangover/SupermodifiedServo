avrdude -p m328p -P COM4 -c avrispv2 -u -U lock:w:0x3f:m -U efuse:w:0x05:m -U hfuse:w:0xDA:m -U lfuse:w:0xFF:m -U flash:w:Arduino.Boot.20MHz.57600.hex -U lock:w:0x0f:m
pause