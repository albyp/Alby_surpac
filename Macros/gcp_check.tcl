######################################################################
#
# Macro Name    : gcp-check.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Fri 11 Jun 2021
#
# Modified Date : Fri 06 Aug 2021
#
# Author        : Alby Palmer 
#
# Description   : Version 2 - Modified report to be more informative
#
######################################################################

puts "Macro running"

##
# Notes
#
# Need to change the output in txt file
##

# Tags and defaults

# Form
set myForm {
  GuidoForm myForm {
    -label "Check surface against check points"
    -layout BoxLayout Y_AXIS
    -default_buttons
    -defaults_key sectionsfile
      
    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS
      
      GuidoLabel bold_label {
        -label "<html><h1>Check surface against check shots</h1></html>"
      }
      
      GuidoPanel panel_1 {
        -label "Input GCP"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoFileBrowserField inputSTR {
          -label "Check String"
          -format none
          -translate none
          -display_length 17
          -file_mask "*.str"
          -extension false
        }
        
        GuidoFileBrowserField inputDTM {
          -label "Surface"
          -format none
          -translate none
          -display_length 17
          -file_mask "*.dtm"
          -extension false
        }
      }
    }
  }
}

# Initite Form
SclCreateGuidoForm myFormHandle $myForm {}

$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

# Main Functions

# Create if function - if DTM is loaded
# if dtm is not loaded, load DTM in background

# # Start if statement to check if DTM exists
# if {$inputDTM == ""} then {
  
  
# } else {
  
# }
# # End if

set status [ SclFunction "OPEN FILE" {
  layer="$inputDTM.dtm"
  location="$inputDTM"
  plugin="Surpac DTM Files"
  Surpac={
    descriptions="true"
    range=""
    IDRange=""
  }
  styles=""
  replace="false"
  rescale="false"
  }]

# Sets DTM to un-selectable
set status [ SclFunction "LAYER OPTIONS" {
  layername="$inputDTM.dtm"
  selectable="false"
}]

# Recall string as "$inputSTR.str"
set status [ SclFunction "OPEN FILE" {
  layer="$inputSTR.str"
  location="$inputSTR"
  plugin="Surpac String Files"
  Surpac={
    descriptions="true"
    range=""
    IDRange=""
  }
  styles=""
  replace="false"
  rescale="true"
}]

set status [ SclFunction "SELECT LAYER" {
  activelayer="$inputSTR.str"
}]

# Save actual RL of check points to D2
set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d2" "z" }
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

# Drape check points over DTM
set status [SclSelectPoint pnt "Select string" layer str_no seg_no pnt_no x y z desc]
set status [ SclFunction "STRING OVER DTM" {
  select_point={
    {
      winx="-0.500"
      winy="0.500"
      objectx="$x"
      objecty="$y"
      objectz="$z"
      snap_projection="off"
    }
  }
  frm01313={
    {
      dtm_layer="$inputDTM.dtm"
      object_id_lay="1"
      trisolation_id_lay="1"
      interp="N"
    }
  }
}]

# Save draped RL of check points to D3
set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d3" "format(z,3)" }
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

# Calculates difference of actual vs draped & sets RL back to actual
set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d4" "format(d3-d2,3)" }
        { "" "" "z" "d2" }
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

set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d5" "format(_string_ave_d4,2)" }
        { "" "" "d6" "\"Surface = $inputDTM\"" }
        { "" "" "d7" "iif(_string_sum_d4 < 0,\"Raise\",\"Lower\")" }
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

# Plot difference in graphics
set status [ SclFunction "DRAW DESC" {
  frm00089={
    {
      range1=""
      range2=""
      range3=""
      ifld_num="d4"
      textalignment="<"
      position="All points"
      layer_name="$inputSTR"
      display_object_number=""
      display_trisolation_number=""
    }
  }
}]

# Save string of checks
set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="$inputSTR"
      output_type="Surpac String Files"
      outputExt=".str"
      Surpac={
        FileFormat="text"
        range=""
        Purpose="Survey pickup file - with surface check"
        ForceCompatibility="true"
        ForceValidation="true"
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

# Create report
set count 0
set height_diff 0
set ave_height_diff 0
set result 0
set resultNum 0
#set gcpSummary [Point Actual Draped Error]

set a [open "$inputSTR.str" "r"]

while {![eof $a]} {
  gets $a line
  
  set data [split $line ","]
  set str [lindex $data 0]
  
  
  if {$str == $str_no } {
    set ave_height_diff [lindex $data 8]
    set result [lindex $data 10]
    #lappend gcpSummary [lindex $data 4]
    #set pID [lindex $data 4]
    #set pErr [lindex $data 7]
    incr count
  }
    

}

set resultNum [expr $ave_height_diff * (-1)]
if {$ave_height_diff < 0.1} {
  set remark "It is what it is, $result DTM $resultNum"
} else {
  set remark "Not so great... $result DTM $resultNum"
}

set writeFile [open "GCP_Report.txt" "w"]
  puts $writeFile "Drone Data Height Check Report - $inputSTR.str"
  puts $writeFile "Surface - $inputDTM.dtm"
  puts $writeFile "----------------------------------------"
  puts $writeFile "Average height difference  = $ave_height_diff"
  puts $writeFile "----------------------------------------"
  puts $writeFile "$remark"
  puts $writeFile "----------------------------------------"
  puts $writeFile "Always complete a manual calc before raising or lowering the DTM file."
  puts $writeFile "----------------------------------------"
  puts $writeFile "Point ID, RL Actual, RL Draped, Point Error"
  close $writeFile
# Adds error report

set a [open "$inputSTR.str" "r"]
set writeFile [open "GCP_Report.txt" "a"]
while {![eof $a]} {
  gets $a line
  
  set data [split $line ","]
  set str [lindex $data 0]
  set pID [lindex $data 4]
  set pZAct [lindex $data 5]
  set pZDrp [lindex $data 6]
  set pErr [lindex $data 7]  

  if {$str == $str_no} {
    puts $writeFile "$pID, $pZAct, $pZDrp, $pErr"
  }
}
puts $writeFile "----------------------------------------"

puts "Macro finished, report created"

set status [ SclFunction "RECALL ANY FILE" {
  file="GCP_Report.txt"
  mode="none"
}]