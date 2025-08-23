SV_FILES = ${wildcard ./src/*.sv}
TB_FILES = ${wildcard ./tb/*.sv}
ALL_FILES = ${SV_FILES} ${TB_FILES}

TOP ?= tb_top

lint:
	@echo "Running lint checks..."
	verilator --lint-only -Wall --timing -Wno-UNUSED -Wno-CASEINCOMPLETE -Wno-MULTITOP -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC ${ALL_FILES}

build:
	verilator --binary ${SV_FILES} ./tb/$(TOP).sv --top $(TOP) -j 0 --trace -Wno-CASEINCOMPLETE -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC

run: build
	obj_dir/V$(TOP)

wave: run
	gtkwave --dark dump.vcd

clean:
	@echo "Cleaning temp files..."
	rm -rf dump.vcd obj_dir

help:
	@echo "Usage:"
	@echo "make -f ../makefile wave TOP=tb_file"

.PHONY: compile run wave lint clean help