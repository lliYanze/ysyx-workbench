all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."
	verilator --cc --trace --exe --build -Wall ./csrc/example.cpp ./vsrc/our.v


include ../Makefile
