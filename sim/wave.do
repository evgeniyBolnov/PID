onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pid_tb/clk
add wave -noupdate /pid_tb/reset
add wave -noupdate -format Analog-Step -height 74 -max 30.0 -min -43.0 /pid_tb/temperature
add wave -noupdate -format Analog-Step -height 74 -max 3.0 /pid_tb/control
add wave -noupdate -format Analog-Step -height 74 -max 3.0 /pid_tb/get_temp/signal
add wave -noupdate -divider {Avalon-MM temperature}
add wave -noupdate /pid_tb/pid_control_inst/temp_state
add wave -noupdate -radix hexadecimal /pid_tb/temp_address
add wave -noupdate /pid_tb/temp_read
add wave -noupdate -radix decimal /pid_tb/temp_readdata
add wave -noupdate /pid_tb/temp_readdatavalid
add wave -noupdate /pid_tb/temp_waitrequest
add wave -noupdate /pid_tb/temp_waitrequest_cnt
add wave -noupdate /pid_tb/temp_valid_delay
add wave -noupdate /pid_tb/pid_control_inst/readed_temp
add wave -noupdate -divider {Avalon-MM PWM}
add wave -noupdate /pid_tb/pid_control_inst/pwm_address
add wave -noupdate /pid_tb/pid_control_inst/pwm_write
add wave -noupdate -format Analog-Step -height 74 -max 16421.0 -min -16369.0 -radix decimal /pid_tb/pid_control_inst/pwm_writedata
add wave -noupdate /pid_tb/pid_control_inst/pwm_waitrequest
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4895 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {840005 ps}
