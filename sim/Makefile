CC      = g++
INC_DIR = /usr/share/verilator/include ./ ./obj_dir
CFLAGS  = -DVM_TRACE -I$(INC_DIR)
VFLAGS  = -Wall -Wno-WIDTH --trace
TARGET  = pid.sv
SOURCES = $(TARGET) verilated.cpp verilated_vcd_c.cpp
EXEC=pid

all: $(EXEC)

wave: out.vcd
ifneq (,$(wildcard ./signal.sav))
	gtkwave out.vcd -a signal.sav &
else
	gtkwave out.vcd &
endif

clean:
	rm -rf ./obj_dir
	rm out.vcd pid

$(EXEC): V$(EXEC)__ALL.a
	$(CC) $(CFLAGS) $(SOURCES) V$(EXEC)__ALL.a -o pid

V$(EXEC)__ALL.a: V$(EXEC).mk
	cd obj_dir; make -f ./V$(EXEC).mk; cd ..

V$(EXEC).mk:
	verilator $(VFLAGS) -cc ../rtl/pid.sv

out.vcd: $(EXEC)
	./$(EXEC) +trace

.PHONY: wave clean all