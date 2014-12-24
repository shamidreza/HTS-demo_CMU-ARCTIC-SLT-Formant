#!/bin/sh
#    Copyright (c) 2014 Seyed Hamidreza Mohammadi
#    This file is part of HTS-demo_CMU-ARCTIC-SLT-Formant.
#    HTS-demo_CMU-ARCTIC-SLT-Formant is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    HTS-demo_CMU-ARCTIC-SLT-Formant is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with HTS-demo_CMU-ARCTIC-SLT-Formant.  If not, see <http://www.gnu.org/licenses/>.

# the next line restarts using wish \
#exec tclsh8.4 "$0" "$@"

#package require -exact snack 2.2;
#snack::sound s;
#s read tmp.wav;
#set fd [open tmp.frm w];
#puts $fd [join [s formant -framelength 0.01 -numformants [lindex $argv 0] -lpcorder [lindex $argv 1] -ds_freq 16000 -nom_f1_freq 500] \n];
#close $fd

package require snack

set method ESPS 
set framelength 0.005 
set frameperiod 80    
set samplerate 16000  
set encoding Lin16    
set endian bigEndian 
set outputmode 0     
set targetfile ""
set outputfile ""
set numformants 4
set lpcorder 10

set arg_index $argc
set i 0
set j 0

set help [ format "formant extract tool using snack library (= ESPS get_f0)\nUsage %s \[-F numformants\] \[-L lpcorder\] \[-s frame_length (in second)\] \[-p frame_length (in point)\] \[-r samplerate\] \[-l (little endian)\] \[-b (big endian)\] \[-o output_file\] \[-formant (output in formants)] inputfile" $argv0 ]

while { $i < $arg_index } {
    switch -exact -- [ lindex $argv $i ] {
    -F {
        incr i
        set numformants [ lindex $argv $i ]
    }
    -L {
        incr i
        set lpcorder [ lindex $argv $i ]
    }
    -s {
        incr i
        set framelength [ lindex $argv $i ]       
    }
    -p {
        incr i
        set frameperiod [ lindex $argv $i ]
        set j 1
    }
    -o {
        incr i
        set outputfile [ lindex $argv $i ]       
    }
    -r {
        incr i
        set samplerate [ lindex $argv $i ]       
    }
    -l {
        set endian littleEndian
    }
    -b {
        set endian bigEndian
    }
    -formant {
        set outputmode 1
    }    
    -h {
        puts stderr $help
        exit 1
    }
    default { set targetfile [ lindex $argv $i ] }
    }
    incr i
}

# framelength
if { $j == 1 } {
   set framelength [expr {double($frameperiod) / $samplerate}]
}

# if input file does not exist, exit program
if { $targetfile == "" } {
    puts stderr $help
    exit 0
}

snack::sound s 

# if input file is WAVE (RIFF) format, read it
if { [file isfile $targetfile ] && "[file extension $targetfile]" == ".wav"} {
    s read $targetfile
} else {
    s read $targetfile -fileformat RAW -rate $samplerate -encoding $encoding -byteorder $endian
}

# if output filename (-o option) is not specified, output result to stdout
set fd stdout

# if output filename is specified, save result to that file
if { $outputfile != "" } then {
    set fd [ open $outputfile w ]
}

# extract f0 and output results
switch $outputmode {
    0 {
        # output in ESPS format
        # puts $fd [join [s pitch -method $method -maxpitch $maxpitch -minpitch $minpitch -framelength $framelength] \n]
        puts $fd [join [s formant -framelength $framelength -numformants $numformants -lpcorder $lpcorder -ds_freq 10000 -nom_f1_freq 500] \n]
    }
    1 {
        # output f0
        # set tmp [s pitch -method $method -maxpitch $maxpitch -minpitch $minpitch -framelength $framelength]
        set tmp [s formant -framelength $framelength -numformants $numformants -lpcorder $lpcorder -ds_freq 10000 -nom_f1_freq 500]
	
	#puts $fd [join [s formant -framelength 0.01 -numformants [lindex $argv 0] -lpcorder [lindex $argv 1] -ds_freq 16000 -nom_f1_freq 500] \n];

        foreach line $tmp {
            #puts [lindex $line 0]
	    puts $line
        }
    }   
}
