VIVADO   = vivado
SIM_OPTS ?= batch

.PHONY: run clean

run:
	@mkdir -p out
	@cd out && \
	$(VIVADO) -mode $(if $(filter gui,$(SIM_OPTS)),gui,batch) \
		-source ../run_sim.tcl \
		-notrace \
		-tclargs $(SIM_OPTS)

clean:
	rm -rf out

