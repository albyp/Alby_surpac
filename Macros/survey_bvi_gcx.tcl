######################################################################
#
# Macro Name    : survey_bvi_gcx.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Aug 30 2026
#
# Description   : Extracts BVI pairs from pickup file and creates a new str file with segments from pre to post BVI
#                 Used for survey of blast BVIs from pu to GCX
#
######################################################################

set bviPre 106
set bviPost 107
set sfx "b"
set outputStr 102

set form {
  GuidoForm form {
    -label "Survey BVIs from bpu to GCX"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 30

    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS

      GuidoLabel title {
        -label "<html><b>Survey BVIs from pu to GCX</b></html>"
      }

      GuidoFiller filler_1 {
        -height 1
      }

      GuidoPanel panel_1 {
        -label "Input"
        -width 22
        -layout CentreLineLayout
        -border etched true

        GuidoFileBrowserField bpuFile {
          -label "bpu file"
          -format none
          -width 20
          -translate none
          -file_mask "*.str"
          -extension false
        }

        GuidoField sfx {
          -label "Post BVI Suffix"
          -width 20
          -default $sfx
        }

        GuidoField bviPre {
          -label "Pre BVI String"
          -width 20
          -default $bviPre
        }

        GuidoField bviPost {
          -label "Post BVI String"
          -width 20
          -default $bviPost
        }
      }

      GuidoLabel info {
        -label "<html>Creates <b>str</b> file of pre & post BVIs<br>
        Uses point & point<b>SFX</b> and draws segment from pre to post<br><br>
        <b>Add to procedure:</b><br>
        Stakeout pre blast BVI and store with suffix</html>"
      }
    }
  }
}

SclCreateGuidoForm mainForm $form {}

$mainForm SclRun {}
if {$_status == "cancel"} {
  "Macro cancelled by user"
  return
}

# open file
set f [open "$bpuFile.str" r]
set content [read $f]
close $f
foreach line [split $content "\n"] {
  lassign [split $line ","] str y x z desc
  if {$str == $bviPre || $str == $bviPost} {
    lappend bvis [list $str $x $y $z $desc]
  }
}

# Build a dictionary keyed by the base description, so pre/post BVIs can be matched.
# pre format: 47, post format: 47b
set pairedBvis [dict create]
foreach rec $bvis {
  set str  [lindex $rec 0]
  set x    [lindex $rec 1]
  set y    [lindex $rec 2]
  set z    [lindex $rec 3]
  set desc [lindex $rec 4]

  set key $desc
  if {[string match "*$sfx" $desc]} {
    set key [string range $desc 0 end-1]
  }

  if {$str == $bviPre} {
    dict set pairedBvis $key pre [list $str $x $y $z $desc]
  } elseif {$str == $bviPost} {
    dict set pairedBvis $key post [list $str $x $y $z $desc]
  }
}

# write to output file
set out [open "${bpuFile}_bvi_combined.str" w]
# write header
puts $out "${bpuFile}_bvi_combined, 0, Combined BVIs,"
puts $out "0, 0, 0, 0,"

# write segments for each matched pre/post pair in the format:
# 102, y, x, z, desc
# 102, y, x, z, desc
# 0, 0, 0, 0
foreach key [lsort -dictionary [dict keys $pairedBvis]] {
  if {![dict exists $pairedBvis $key pre] || ![dict exists $pairedBvis $key post]} {
    continue
  }

  set preRec [dict get $pairedBvis $key pre]
  set postRec [dict get $pairedBvis $key post]

  set preX   [lindex $preRec 1]
  set preY   [lindex $preRec 2]
  set preZ   [lindex $preRec 3]
  set preDesc [lindex $preRec 4]

  set postX   [lindex $postRec 1]
  set postY   [lindex $postRec 2]
  set postZ   [lindex $postRec 3]
  set postDesc [lindex $postRec 4]

  puts $out "$outputStr, $preY, $preX, $preZ, $preDesc"
  puts $out "$outputStr, $postY, $postX, $postZ, $postDesc"
  puts $out "0, 0, 0, 0"
}

# write null end
puts $out "0, 0, 0, 0,"
puts $out "0, 0, 0, 0, END"
close $out

puts "Combined BVIs written to ${bpuFile}_bvi_combined.str"