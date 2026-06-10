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
#                 Run on folder with existing boundary string file and volume csv
#
######################################################################

puts "Macro running"

set form {
    GuidoForm form {
        -label "Update volume report (.csv) with d1 fields from boundary file"
        -default_buttons
        -defaults_key sectionsfile
        -layout BoxLayout Y_AXIS
        -width 30
        -height 6

        GuidoPanel panel_left {
            -layout BoxLayout Y_AXIS

            GuidoPanel panel1 {
                -label "Input"
                -layout CentreLineLayout
                -border etched true

                GuidoFileBrowserField rep {
                    -label "Select vol report"
                    -file_mask "*.csv"
                    -display_length 15
                    -extension true
                    -null false
                }

                GuidoFileBrowserField str {
                    -label "Select boundary string file"
                    -file_mask "*.str"
                    -display_length 15
                    -extension true
                    -null false
                }

                GuidoField boundaryString {
                    -label "Boundary string no."
                    -null false
                    -default 903
                }
            }
        }
    }
}

SclCreateGuidoForm mainForm $form {}

$mainForm SclRun {}
if {$_status == "cancel"} {
    puts "Macro cancelled by user"
    return
}

# find fileName from string file contents
proc getBoundaryFile {line lineNumber} {
    if {[regexp -- {Boundary file: \s*([^,]+)} $line full_match extract]} {
        set fileName [string trim $extract]
        return $fileName  ;
    }
    return ""
}

# create array of segmentNo and d1's from string file with given boundary string
proc extractSurpacSegments {filePath boundaryString} {
    set segmentNo 0
    set insideSegment 0
    array set results {}

    if {[catch {open $filePath r} fp]} {
        error "Could not open file: $filePath"
    }

    while {[gets $fp line] >= 0} {
        set line [string trim $line]
        if {$line eq ""} { continue }

        set fields [split $line ","]
        set cleanFields {}
        foreach f $fields {
            lappend cleanFields [string trim $f]
        }

        set stringId [lindex $cleanFields 0]

        # reset flag when a segment breaker line (0,0,0,0...) is found
        if {$stringId eq "0"} {
            set insideSegment 0
            continue
        }

        # process valid data lines matching the target string
        if {$stringId eq $boundaryString} {
            # when a new segment is found, execute var sets
            if {!$insideSegment} {
                incr segmentNo
                set insideSegment 1
                
                # Grab the d1 field value from this first line only
                set d1 [lindex $cleanFields 4]
                set key "${stringId}_${segmentNo}"
                
                set results($key) $d1
            }
        }
    }
    close $fp

    return [array get results]
}


proc appendD1ToReport {reportPath stringFilePath boundaryString outReportPath} {
    # 1. Extract d1 lookups from your string file
    array set d1Data [extractSurpacSegments $stringFilePath $boundaryString]

    # 2. Open volume report for reading and a new file for writing
    if {[catch {open $reportPath r} fIn]} {
        error "Could not open report file: $reportPath"
    }
    if {[catch {open $outReportPath w} fOut]} {
        close $fIn
        error "Could not create output file: $outReportPath"
    }

    set readingSegments 0

    while {[gets $fIn line] >= 0} {
        # Check for the segment table header row
        if {[string match "Segment *,Cut Vol *" $line]} {
            set readingSegments 1
            # Append a header label to the column row
            puts $fOut "${line},Boundary Name"
            continue
        }

        # Check for the summary total row to stop appending
        if {[string match "Total,*" $line]} {
            set readingSegments 0
        }

        # Process active segment lines
        if {$readingSegments} {
            set fields [split $line ","]
            set segNo [string trim [lindex $fields 0]]

            # Match array key format: "903_1", "903_2", etc.
            set arrayKey "${boundaryString}_${segNo}"

            if {[info exists d1Data($arrayKey)]} {
                set matchedD1 $d1Data($arrayKey)
                # Strip trailing empty Surpac csv commas if they exist on the line
                set cleanedLine [string trimright $line ","]
                puts $fOut "${cleanedLine},${matchedD1}"
                continue
            }
        }

        # Write all other unmapped rows/headers exactly as they are
        puts $fOut $line
    }

    close $fIn
    close $fOut
}

set fileData [extractSurpacSegments "$str" "$boundaryString"]
array set myResults $fileData
parray myResults

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

appendD1ToReport $rep $str $boundaryString "u_${rep}"