TARGET = lab3
CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
QEMU = qemu-system-arm

CFLAGS = -mcpu=cortex-m4 -mthumb -g
LDFLAGS = -T linker.ld -nostdlib

OBJS = start.o bootloader.o kernel.o print.o

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.elf *.bin

run: $(TARGET).bin
	$(QEMU) -M lm3s6965evb -nographic -semihosting -kernel $(TARGET).bin

debug: $(TARGET).elf
	$(QEMU) -M lm3s6965evb -nographic -semihosting -kernel $(TARGET).bin -s -S &
	arm-none-eabi-gdb $(TARGET).elf -ex "target remote :1234" -ex "layout asm" -ex "layout regs"
