#!/usr/bin/wish

set seconds_mode 0;		# really sub-minute units

# set up next update
proc next_update {} {

    global seconds_mode


    if {$seconds_mode} {
	set t [clock milliseconds]
	set next [expr 1000 - ($t % 1000)]
    } else {
	set t [clock seconds]
	set increment 60
	set next [expr 1000 * ($increment - ($t % $increment))]
    }

    after $next update_colors
}

# toggle seconds mode
proc toggle_seconds_mode {} {
    global seconds_mode
    
    set seconds_mode [expr ! $seconds_mode]
    after cancel update_colors
    
    update_colors
}

proc update_colors {} {

    global seconds_mode

    # Update colors
    set hourcolor   0xfff000000
    set mincolor    0x000fff000
    set seccolor    0x000000fff
    set nocolor     0x000000000

    # get time
    set t [clock seconds]

    set h [string trimleft [clock format $t -format "%H"] "0"]

    # Deal with 08 and 09 not being octal
    set m [string trimleft [clock format $t -format "%M"] "0"]

    # Seconds
    if {$seconds_mode} {
	set s [string trimleft [clock format $t -format "%S"] "0"]
    }

    for {set i 5} {$i >= 0} {incr i -1} {

	set result 0
	set n [expr 2**$i]

	if {$h >= $n} {
	    set h [expr $h - $n]
	    set result [expr $result ^ $hourcolor]
	}

	if {$m >= $n} {
	    set m [expr $m - $n]
	    set result [expr $result ^ $mincolor]
	}

	if {$seconds_mode && ($s >= $n)} {
	    set s [expr $s - $n]
	    set result [expr $result ^ $seccolor]
	}

	.c${n} configure -background [format "#%09x" $result]
    }

    next_update
}


for {set i 5} {$i >= 0} {incr i -1} {
    set n [expr 2**$i]
    canvas .c${n} -height 0 -width 0 -background white -relief solid -bd 1
}

grid .c32 x    x   x   x   x   -sticky nsew
grid ^    .c16 .c8 x   x   x   -sticky nsew
grid ^    ^    ^   .c4 .c2 x   -sticky nsew
grid ^    ^    ^   ^   ^   .c1 -sticky nsew

grid rowconfigure . 0 -weight 4
grid rowconfigure . 1 -weight 2
grid rowconfigure . 2 -weight 1
grid rowconfigure . 3 -weight 1

grid columnconfigure . 0 -weight 4
grid columnconfigure . 1 -weight 4
grid columnconfigure . 2 -weight 2
grid columnconfigure . 3 -weight 2
grid columnconfigure . 4 -weight 1
grid columnconfigure . 5 -weight 1

# Key bindings
bind . q exit
bind . s toggle_seconds_mode
bind . m toggle_seconds_mode

# Update colors
update_colors
