######################################################################
#
# Macro Name    : robust_dtmcafv.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Wed Jun 10 2026
#
# Author        : Alby Palmer
#
# Description   : Make cut/fill volume report better, use segment d1 as field
#
######################################################################

# Create array from str (_string_segment_no, d1) - filter by boundaryString

puts "Macro running"

set rep "260601_bz_eastrom_vol.csv"
set str "bz_east_rom_may_bdy.str"

set boundaryString 903

proc getBoundaryFile {line lineNumber} {
    if {[regexp -- {Boundary file: \s*([^,]+)} $line full_match extract]} {
        set fileName [string trim $extract]
        return $fileName  ;# Added $ to return the value
    }
    return ""
}


# get boundary file from the volume report
set volumeReport [open "$rep" r]
set lineCounter 1

while {[gets $volumeReport line] >= 0} {
    set boundaryFile [getBoundaryFile $line $lineCounter]

    if {$boundaryFile ne ""} {
        break;
    }

    incr lineCounter
}
close $volumeReport

puts $boundaryFile