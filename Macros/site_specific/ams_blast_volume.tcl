######################################################################
#
# Macro Name    : ams_blast_volume.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Mon Jun 29 2026
#
# Author        : Alby Palmer
#
# Site          : Buzzard
#
# Description   : Generate blast solid and calculate volume from survey pickup
#                 Assumes boundary string and blast holes in same layer
#
######################################################################

# Notes / improvements
# hide other layers (if STR file is already loaded, we want that hidden)
# check if boundary string exists
# update form for allshots to allow selecting the allshot string files
# delete bot_temp.dtm layer after use

puts "Macro running"

# Define hole strings and boundary string numbers - update as required for site
array set holeStrings {
    presplit 103
    lostGet 105
    bviPre 106
    bviPost 107
    production 108
}

set boundaryString 109

set allshotDescString 20

set strings {}
foreach {key val} [array get holeStrings] {
	lappend strings $val
}

set strings [join $strings ";"]

set file ""
set pit ""
set rl ""
set shot ""

# auto find string file if only 1 exists
set strFiles [glob -nocomplain {*.str}]
if {[llength $strFiles] == 1} {
  set cleanName [file rootname [lindex $strFiles 0]]
  set details [split $cleanName _]
  set file $cleanName
  if {[llength $details] == 3} {
    lassign $details pit rl shot
  } elseif {[llength $details] == 4} {
    lassign $details _ pit rl shot
  }
}

set systemTime [clock seconds]

set form [subst {
  GuidoForm form {
    -label "Process blast solid and volume"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 45

    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS

      GuidoPanel panel_1 {
        -label "Survey pickup"
        -layout CentreLineLayout
        -border etched true

        GuidoComboBox pitPrefix {
          -label "Pit"
          -format none
          -value_in "bz"
          -null false
        }

        GuidoFileBrowserField pickupFile {
          -label "Select blast pickup file"
          -format none
          -translate none
          -default "$file"
          -file_mask "*.str"
          -display_length 20
          -extension false
        }

        GuidoField benchElevation {
          -label "Floor elevation"
          -format none
          -null false
          -default "$rl"
        }
      }

      GuidoPanel panel_2 {
        -label "Allshot update"
        -layout CentreLineLayout
        -border etched true

        GuidoCheckBox updateAllshot {
          -label "Update allshot layers"
          -caption "Yes"
          -selected_value "y"
          -unselected_value "n"
          -default "n"
        }

        GuidoField surveyor {
          -dependency {\[\$updateAllshot getCurrentValue] == "y"}
          -label "Surveyor"
          -width 8
          -format none
        }

        GuidoField date {
          -dependency {\[\$updateAllshot getCurrentValue] == "y"}
          -label "Date"
          -format none
          -width 8
          -default [clock format $systemTime -format "%Y-%m-%d"]
        }
      }

      GuidoPanel panel_3 {
        -label "Design input"
        -layout CentreLineLayout
        -border etched true

        GuidoFileBrowserField designFile {
          -label "Select design file"
          -file_mask "*.dtm"
          -display_length 20
        }

        GuidoLabel label1 {
          -label "<html><font color='red'>Input design file <b>ONLY</b> for wall/ramp clipping<br></html>"
        }
      }

      GuidoPanel panel_4 {
        -label "Settings"
        -layout CentreLineLayout
        -border etched true

        GuidoField boundaryString {
          -label "Boundary string number"
          -default "$boundaryString"
          -null false
        }

        GuidoField holeStringRange {
          -label "Hole string numbers (range or ;)"
          -default "$strings"
          -width 20
        }

        GuidoCheckBox delTemp {
          -label "Delete temporary files"
          -caption "Yes"
          -selected_value "y"
          -unselected_value "n"
          -default "y"
        }
      }
      
      GuidoLabel label3 {
        -label "<html><font color='red'>Note: Hole strings must be in same layer as boundary string</font color><br><br>
        If wall/ramp shot, input design file, otherwise leave blank.<br>
        Update Survey Allshot - updates the *pit_###_allshots* files</html>"
      }
    }
  }
}]

SclCreateGuidoForm mainForm $form {}

$mainForm SclRun {}
if {$_status == "cancel"} {
    puts "Macro cancelled by user"
    return
}

# Pole of inaccessibility helpers for digitising shot description point
# inside the blast boundary without manual digitise
proc PointInPolygon {px py xs ys} {
    set n [llength $xs]
    set inside 0
    set j [expr {$n - 1}]
    for {set i 0} {$i < $n} {incr i} {
        set xi [lindex $xs $i]
        set yi [lindex $ys $i]
        set xj [lindex $xs $j]
        set yj [lindex $ys $j]
        if { (($yi > $py) != ($yj > $py)) &&
             ($px < ($xj - $xi) * ($py - $yi) / ($yj - $yi) + $xi) } {
            set inside [expr {!$inside}]
        }
        set j $i
    }
    return $inside
}

proc PointSegDist {px py x1 y1 x2 y2} {
    set dx [expr {$x2 - $x1}]
    set dy [expr {$y2 - $y1}]
    if {$dx == 0 && $dy == 0} {
        return [expr {hypot($px - $x1, $py - $y1)}]
    }
    set t [expr {(($px - $x1) * $dx + ($py - $y1) * $dy) / ($dx*$dx + $dy*$dy)}]
    if {$t < 0} {set t 0}
    if {$t > 1} {set t 1}
    set cx [expr {$x1 + $t * $dx}]
    set cy [expr {$y1 + $t * $dy}]
    return [expr {hypot($px - $cx, $py - $cy)}]
}

proc DistToPolygonBoundary {px py xs ys} {
    set n [llength $xs]
    set minD 1e18
    set j [expr {$n - 1}]
    for {set i 0} {$i < $n} {incr i} {
        set d [PointSegDist $px $py \
                 [lindex $xs $j] [lindex $ys $j] \
                 [lindex $xs $i] [lindex $ys $i]]
        if {$d < $minD} {set minD $d}
        set j $i
    }
    return $minD
}

proc PoleOfInaccessibility {xs ys {gridDivisions 20} {refinePasses 4}} {
    set xmin [lindex $xs 0]; set xmax $xmin
    set ymin [lindex $ys 0]; set ymax $ymin
    foreach x $xs {
        if {$x < $xmin} {set xmin $x}
        if {$x > $xmax} {set xmax $x}
    }
    foreach y $ys {
        if {$y < $ymin} {set ymin $y}
        if {$y > $ymax} {set ymax $y}
    }

    set cx [expr {($xmin + $xmax) / 2.0}]
    set cy [expr {($ymin + $ymax) / 2.0}]
    set halfW [expr {($xmax - $xmin) / 2.0}]
    set halfH [expr {($ymax - $ymin) / 2.0}]

    if {$halfW <= 0} {set halfW 1.0}
    if {$halfH <= 0} {set halfH 1.0}

    set bestX $cx
    set bestY $cy
    set bestD -1

    for {set pass 0} {$pass < $refinePasses} {incr pass} {
        set stepX [expr {(2.0 * $halfW) / $gridDivisions}]
        set stepY [expr {(2.0 * $halfH) / $gridDivisions}]
        set foundAny 0

        for {set i 0} {$i <= $gridDivisions} {incr i} {
            set px [expr {$cx - $halfW + $i * $stepX}]
            for {set j 0} {$j <= $gridDivisions} {incr j} {
                set py [expr {$cy - $halfH + $j * $stepY}]
                if {[PointInPolygon $px $py $xs $ys]} {
                    set d [DistToPolygonBoundary $px $py $xs $ys]
                    if {$d > $bestD} {
                        set bestD $d
                        set bestX $px
                        set bestY $py
                        set foundAny 1
                    }
                }
            }
        }

        if {!$foundAny && $bestD < 0} {
            return [list [lindex $xs 0] [lindex $ys 0]]
        }

        set cx $bestX
        set cy $bestY
        set halfW [expr {$halfW / 3.0}]
        set halfH [expr {$halfH / 3.0}]
    }

    return [list $bestX $bestY]
}

set pitPrefix [string toupper $pitPrefix]

set cleanPickup [file rootname $pickupFile]
puts $cleanPickup
set details [split $cleanPickup _]
if {[llength $details] == 3} {
  lassign $details pit rl shot
} elseif {[llength $details] == 4} {
  lassign $details _ pit rl shot
}

# TODO make else for error and later create form for user to input pit, rl, shot if not in filename

set sfx    _vol
set output ${pitPrefix}_${benchElevation}_${shot}${sfx}

# Create DTM from pickup STR
set status [ SclFunction "CREATE DTM" {
  frm00126={
    {
      location="$pickupFile"
      object_num="1"
      obj_name=""
      inputExt="str"
      output_fname="top_temp"
      plane="plan"
      check_distance="0.0050"
      break="Y"
      anyspots="Y"
      spotrng="$holeStringRange"
      brktest="N"
      interpolate_new_points="N"
      apply_boundary="Y"
      bdyloc="$pickupFile"
      bdystr="$boundaryString"
      inout="I"
    }
  }
}]

set status [ SclFunction "STR MATHS" {
  frm00700={
    {
      file_loc="$pickupFile"
      file_id=""
      result_loc="bot_temp"
      main=table { str_range constraint field expr } {
        { "" "" "z" "$benchElevation" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
      }
    }
  }
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="bot_temp.str"
  mode="none"
}]

set status [ SclFunction "CREATE DTM" {
  frm00126={
    {
      location="bot_temp"
      object_num="1"
      obj_name=""
      inputExt="str"
      output_fname=""
      plane="plan"
      check_distance="0.0050"
      break="Y"
      anyspots="Y"
      spotrng="$holeStringRange"
      brktest="N"
      interpolate_new_points="N"
      apply_boundary="Y"
      bdyloc="bot_temp"
      bdystr="$boundaryString"
      inout="I"
    }
  }
}]

set status [ SclFunction "TRISOLATION FILE DTM/DTM INTERSECT" {
  frm00713={
    {
      location1="top_temp.dtm"
      id1=""
      object1="1"
      trisol1="1"
      retain_other_trisolations="N"
      location2="bot_temp.dtm"
      id2=""
      object2="1"
      trisol2="1"
      result_location="$output.dtm"
      result_id=""
      result_object="1"
      contact_string="0"
    }
  }
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="$output.dtm"
  mode="none"
}]


if {$designFile ne ""} {
  set status [ SclFunction "TRISOLATION FILE 3DM/DTM ABOVE" {
    frm00714={
      {
        location1="$output.dtm"
        id1=""
        object1=""
        trisol1=""
        retain_other_trisolations="N"
        location2="$designFile"
        id2="31032026"
        object2="1"
        trisol2="1"
        result_location="$output.dtm"
        result_id=""
        use_first_object_id="N"
        result_object="1"
        contact_string="0"
      }
    }
    frm00121={
      {
        _action=""
      }
    }
  }]

  set status [ SclFunction "RECALL ANY FILE" {
    file="$output.dtm"
    mode="none"
  }]
}

set status [ SclFunction "OBJECT REPORT" {
  frm00466={
    {
      reploc="$output..not"
      repid=""
      report_format=".not"
      checkoverlaps="N"
      report_type="T"
      decimals="0"
    }
  }
}]

set status [ SclFunction "DELETE LAYER" {
  layer="bot_temp.str"
}]

if {$updateAllshot == "y"} {
  # get folder path, split to relativePath used in bench directory (###rl) to load allshot layers
  set path [pwd]
  # regexp 3 digits followed by "rl" or "RL"
  if {[regexp -indices {\d+[rRlL]{2}} $path match_range]} {
    set start [lindex $match_range 0]
    set end [lindex $match_range 1]
    set matchFolder [string range $path $start $end]

    # Relative path
    set remaining [string range $path [expr {$end + 1}] end]
    set folderCount [llength [file split $remaining]]

    if {$folderCount > 0} {
        set dots [string repeat "../" $folderCount]
        set relativePath "${dots}${matchFolder}/"
        } else {
        set relativePath "./${matchFolder}/"
        }

    puts "Relative path: $relativePath"
  } else {
    puts "No match found for 3 digits followed by 'rl' in the path."
    set relativePath ""
  }

  # check if allshot files exist and run update, else warn user to update manually
  if {
      ![file exists "${relativePath}${pitPrefix}_${benchElevation}_allshots.str"] ||
      ![file exists "${relativePath}${pitPrefix}_${benchElevation}_allshots_survey.str"]
    } {
      set form2 [subst {
        GuidoForm form {
            -label "Update allshot layers"
            -default_buttons
            -defaults_key sectionsfile
            -layout BoxLayout Y_AXIS

            GuidoPanel panel_1 {
                -label "Update allshot layers"
                -layout CentreLineLayout
                -border etched true

                GuidoFileBrowserField allshotFile {
                    -label "Select allshot file"
                    -default "$relativePath"
                    -format none
                    -file_mask "*.str"
                    -width 12
                    -extension false
                }

                GuidoFileBrowserField allshotSurveyFile {
                    -label "Select allshot survey file"
                    -default "$relativePath"
                    -format none
                    -file_mask "*.str"
                    -width 12
                    -extension false
                }
            }
        }
      }]

      SclCreateGuidoForm allshotDetails $form2 {}

      $allshotDetails SclRun {}
      if {$_status == "cancel"} {
          puts "Macro cancelled by user"
          return
      }
  } else {
    set allshotFile "${relativePath}${pitPrefix}_${benchElevation}_allshots"
    set allshotSurveyFile "${relativePath}${pitPrefix}_${benchElevation}_allshots_survey"
  }

  set status [ SclFunction "RECALL ANY FILE" {
        file="$pickupFile.str"
        mode="openInNewLayer"
      }]

      # create the shot annotation point automatically using
      # pole-of-inaccessibility inside the polygon
      set xvar ""
      set yvar ""
      set zvar ""
      set boundaryXs [list]
      set boundaryYs [list]
      set boundaryZs [list]
      set boundaryFound 0

      SclGetActiveViewport ViewportHandle
      $ViewportHandle SclGetActiveLayer SwaHandle
      $SwaHandle SclGetStrings StringsHandle
      $StringsHandle SclIterateFirst StringsIterator
      while {[$StringsIterator SclIterateNext StringHandle] == $SCL_TRUE} {
        set strNum [$StringHandle SclGetId]
        if {$strNum != $boundaryString} {
          continue
        }
        set boundaryFound 1
        $StringHandle SclIterateFirst SegmentIterator
        while {[$SegmentIterator SclIterateNext SegmentHandle] == $SCL_TRUE} {
          $SegmentHandle SclIterateFirst PointIterator
          while {[$PointIterator SclIterateNext PointHandle] == $SCL_TRUE} {
            set x [$PointHandle SclGetValueByName x]
            set y [$PointHandle SclGetValueByName y]
            set z [$PointHandle SclGetValueByName z]
            lappend boundaryXs $x
            lappend boundaryYs $y
            lappend boundaryZs $z
          }
        }
      }

      if {$boundaryFound && [llength $boundaryXs] >= 3} {
        set pole [PoleOfInaccessibility $boundaryXs $boundaryYs]
        set xvar [lindex $pole 0]
        set yvar [lindex $pole 1]
        if {[llength $boundaryZs] > 0} {
          set zvar [lindex $boundaryZs end]
        } else {
          set zvar $benchElevation
        }
      } else {
        SclDigitise "Digitise point for Shot ID" xvar yvar zvar
      }

      $SwaHandle SclCreateString stringhandle $allshotDescString
      $stringhandle SclCreateSegment segmenthandle 0
      $segmenthandle SclCreatePoint pointhandle 0
      $pointhandle SclSetValueByName x $xvar
      $pointhandle SclSetValueByName y $yvar
      $pointhandle SclSetValueByName z $zvar
      $pointhandle SclSetValueByName d1 "${pitPrefix}_${benchElevation}_${shot}"
      $pointhandle SclSetValueByName d2 "$surveyor"
      $pointhandle SclSetValueByName d3 "$date"

      set status [ SclFunction "RECALL ANY FILE" {
        file="$allshotSurveyFile.str"
        mode="appendToCurrentLayer"
      }]

      set status [ SclFunction "FILE SAVE" {
        frmsaveFileAs={
          {
            output_file="$allshotSurveyFile"
            output_type="Surpac String Files"
            outputExt=".str"
            Surpac={
              range=""
              Purpose=""
              FileFormat="text"
              ForceValidation="true"
              ForceCompatibility="true"
            }
            saveStyle="N"
          }
        }
        frm00121={
          {
            _action=""
          }
        }
      }]

      # undo command to remove the recalled layer (revert back to pickup file)
      set status [ SclFunction "UNDO" {} ]

      set status [ SclFunction "RECALL ANY FILE" {
        file="$allshotFile.str"
        mode="appendToCurrentLayer"
      }]

      set status [ SclFunction "STRING DELETE RANGE" {
        frm00066={
          {
            strange="$holeStringRange"
          }
        }
      }]

      set status [ SclFunction "FILE SAVE" {
        frmsaveFileAs={
          {
            output_file="$allshotFile"
            output_type="Surpac String Files"
            outputExt=".str"
            Surpac={
              range=""
              Purpose=""
              FileFormat="text"
              ForceValidation="true"
              ForceCompatibility="true"
            }
            saveStyle="N"
          }
        }
        frm00121={
          {
            _action=""
          }
        }
      }]

      set status [ SclFunction "FILE SAVE" {
        frmsaveFileAs={
          {
            output_file="$allshotFile.dxf"
            output_type="Autocad DXF / DWG Files"
            outputExt=".dxf"
            AutoCAD={
              version="Autocad 24 (2010)"
            }
          }
        }
        frm00121={
          {
            _action=""
          }
        }
      }]

      puts "Updated allshot layers"
}

# Log the volume
set f [open "$output.not" r]
set content [read $f]
close $f
set trimmed [string trim $content]
set contentList [split $trimmed " "]
set lastElement [lindex $contentList end]
puts "${pickupFile} - Volume: ${lastElement}"

if {$delTemp == "y"} {  
  set status [ SclFunction "EXECUTE OS COMMAND" {
    frm00462={
      {
        os_cmd="del *.log; del top_temp.*; del bot_temp.*"
      }
    }
  }]
}

puts "Macro finished"