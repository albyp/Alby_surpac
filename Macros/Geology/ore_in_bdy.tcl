######################################################################
#
# Macro Name    : ore_in_bdy.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Aug 30 2026
#
# Author        : Alby Palmer
#
# Description   : Intersects adjusted ore with shot boundary and saves 
#                 the result to a new string file. Preserves ore string 
#                 numbers and point description fields.
#
# Usage Notes   : Requires ore.str and bdy.str in current directory.
#                 Output saved as ore_adjusted_cropped.str
#
######################################################################

puts "Ore intersection macro running"

# guido for input files
set form {
    GuidoForm form {
        -label "Crop adjusted ore with shot boundary"
        -default_buttons
        -defaults_key sectionsfile
        -layout BoxLayout Y_AXIS
        -width 40

        GuidoPanel panel_left {
            -layout BoxLayout Y_AXIS

            GuidoPanel panel_1 {
                -label "Input Files"
                -layout CentreLineLayout
                -border etched true

                GuidoFileBrowserField oreFile {
                    -label "Select adjusted ore string file"
                    -file_mask "*.str"
                    -width 25
                    -extension false
                }

                GuidoFileBrowserField bdyFile {
                    -label "Select shot boundary string file"
                    -file_mask "*.str"
                    -width 25
                    -extension false
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

set outputFile "${oreFile}_cropped.str"

# create SWA and load files
puts "Loading source files"
SclCreateSwa OreStrings "Ore Strings"
SclCreateSwa BdyStrings "Boundary Strings"
SclCreateSwa ResultStrings "Intersection Results"

$OreStrings SclSwaOpenFile $oreFile.str
$BdyStrings SclSwaOpenFile $bdyFile.str
puts "Files loaded successfully"

puts "Extracting boundary segment"
$BdyStrings SclGetStrings BdyStringsIterator
$BdyStringsIterator SclIterateFirst BdyStringsIter
$BdyStringsIter SclIterateNext BdyStringHandle
$BdyStringHandle SclIterateFirst BdySegmentIter
$BdySegmentIter SclIterateNext BdySegmentHandle

puts "Processing ore segments"
$OreStrings SclGetStrings OreStringsIterator
$OreStringsIterator SclIterateFirst OreStringsIter

set ProcessedCount 0

# iterate through all strings in OreStrings
while {[$OreStringsIter SclIterateNext OreStringHandle] == $SCL_TRUE} {
    # Get the original string number
    set OriginalStringId [$OreStringHandle SclGetId]
    puts "Processing string $OriginalStringId"
    
    # iterate through all segments in each string
    $OreStringHandle SclIterateFirst OreSegmentIter
    
    while {[$OreSegmentIter SclIterateNext OreSegmentHandle] == $SCL_TRUE} {
        # extract all d field values from the first point of the ore segment
        set dFields {}
        
        set PointCount [$OreSegmentHandle SclCountItems]
        if {$PointCount > 0} {
            $OreSegmentHandle SclGetItem FirstPointHandle 0
            
            # extract d fields from the first point (d1, d2, d3, etc)
            for {set i 1} {$i <= 100} {incr i} {
                set fieldName "d$i"
                if {![catch {set dValue [$FirstPointHandle SclGetValueByName $fieldName]} err]} {
                    if {$dValue ne ""} {
                        lappend dFields $fieldName $dValue
                        puts "  Found $fieldName = $dValue"
                    }
                }
            }
        }
        
        puts "  Collected [llength $dFields] description fields"
        
        # intersect ore with boundary string
        puts "Intersecting segment with boundary"
        SclIntersectSegments $OreSegmentHandle intersect $BdySegmentHandle $ResultStrings $OriginalStringId
        
        # check if any d fields exist and apply them to intersected segments
        if {[llength $dFields] > 0} {
            $ResultStrings SclCreateString ResultStringHandle $OriginalStringId
            $ResultStringHandle SclIterateFirst ResultSegmentIter
            
            while {[$ResultSegmentIter SclIterateNext ResultSegmentHandle] == $SCL_TRUE} {
                # apply d fields to all points in the result segment
                set ResultPointCount [$ResultSegmentHandle SclCountItems]
                for {set p 0} {$p < $ResultPointCount} {incr p} {
                    $ResultSegmentHandle SclGetItem ResultPointHandle $p
                    # set each d field on this point
                    foreach {fieldName dValue} $dFields {
                        $ResultPointHandle SclSetValueByName $fieldName $dValue
                    }
                }
            }
        }
        
        incr ProcessedCount
    }
}

# save the result to the output file
puts "Saving results to $outputFile..."
$ResultStrings SclSwaSaveStringFile $outputFile
puts "File saved successfully"

# cleanup
SclDestroy OreStringHandle
SclDestroy BdyStringHandle
SclDestroy OreSegmentHandle
SclDestroy BdySegmentHandle
SclDestroy OreStrings
SclDestroy BdyStrings
SclDestroy ResultStrings

puts "Macro completed - Processed $ProcessedCount segments"