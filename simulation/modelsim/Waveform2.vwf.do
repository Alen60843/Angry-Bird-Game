vlog -work work Waveform2.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.TOP_VGA_DEMO_KBD_vlg_vec_tst -voptargs="+acc"
add wave /*
run -all
