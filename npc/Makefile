export PATH := $(PATH):$(abspath ./utils)

#这里是文件夹名
TOP = top
#这里是顶层模块名
TOPNAME = TOP

BUILD_DIR = ./build
OUTVERILOG_DIR = $(BUILD_DIR)/verilog

LOG_PATH = $(BUILD_DIR)/logs
LOG_FILE = $(LOG_PATH)/$(TOP).vcd

INC_PATH ?= $(BUILD_DIR)/csrc

VSRC_DIR = ./vsrc
CSRC_DIR = ./csrc


VERILATOR = verilator
# VERILATOR_CFLAGS += --cc --trace --exe --build -Wall 
VERILATOR_CFLAGS += --cc --trace --exe --build

OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

MAKE = make

$(shell mkdir -p $(BUILD_DIR))
$(shell mkdir -p $(CSRC_DIR))
$(shell mkdir -p $(VSRC_DIR))


VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

# CFLAGS += $(shell llvm-config --cxxflags) 
# CFLAGS += -fPIE
# LDFLAGS += $(shell llvm-config --libs)
# CFLAGS += -Wall -Werror

$(BIN) : $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS)  \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))


IMG ?=

verilator: $(BIN)

NPC_EXE:= $(BIN) $(ARGS) $(IMG)

verilog: 
	$(call git_commit, "generate verilog")
	@mkdir -p $(OUTVERILOG_DIR)
	mill -i $(TOP).runMain Elaborate -td $(OUTVERILOG_DIR)
	@mkdir -p $(VSRC_DIR)
	cp -r $(OUTVERILOG_DIR)/*.v $(VSRC_DIR)/
	

sim: clean
	@$(MAKE) verilog
	@$(MAKE) verilator
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!


run: verilator
	$(NPC_EXE)

wave: run
	gtkwave  $(LOG_FILE)

count: 
	@echo "Total lines of code:"
	@find . -name Makefile  -o -wholename "./csrc/*.[ch]" -o -wholename "./top/*.scala" | xargs egrep -v '^$$' | wc -l

include ../Makefile

help:
	mill -i __.test.runMain Elaborate --help

compile:
	mill -i __.compile

bsp:
	mill -i mill.bsp.BSP/install

reformat:
	mill -i __.reformat

checkformat:
	mill -i __.checkFormat

test:
	mill -i __.test

clean:
	-rm -rf $(BUILD_DIR) $(VSRC_DIR) 

.PHONY: test help compile bsp reformat checkformat clean sim wave nbwave verilog
