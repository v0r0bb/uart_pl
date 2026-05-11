set mode [lindex $argv 0]
set project_name "uart_pl"

create_project -force $project_name .

add_files -fileset sources_1 [glob ../rtl/gen/*.sv]
add_files -fileset sources_1 [glob ../rtl/inc/*.sv]
add_files -fileset sources_1 [glob ../rtl/src/*.sv]

add_files -fileset sim_1 [glob ../tb/*.sv]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property top tb [get_filesets sim_1]
launch_simulation -mode behavioral

if {$mode != "gui"} {
    run all
    exit
} else {
    run all
}


