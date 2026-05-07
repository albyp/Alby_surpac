######################################################################
#
# Macro Name    : drone_to_dtm_bz.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Fri May 8 2026 
#
# Author        : Alby Palmer
#
# Site          : Buzzard
#
# Description   : Renames CSV file to XYZ, imports point cloud, creates DTM, 
#                 renumbers to input string, cleans layer (minimum seperation), 
#                 applies geoid seperation shift, appends surveyor details, saves (str/dtm)
#
######################################################################

puts "Macro running"

# spotheight/scan string number
set str_no 33

# form
set myForm {
  GuidoForm myForm {
    -label "XYZ point cloud to DTM"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 50
    -height 16

    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS

      GuidoLabel bold_label {
        -label "<html><h1>Convert XYZ point cloud to DTM</h1><br>
        <font color=red>Ensure work directory set before proceeding</html>"
      }

      GuidoLabel label {
        -label "Output filename should be in format \"YYMMDD_NAME\""
      }

      GuidoFiller spacer {
        -height 1
      }

      GuidoPanel panel_1 {
        -label "Input"
        -layout CentreLineLayout
        -border etched true
        -width 40

        GuidoFileBrowserField inputFile {
          -label "Select point cloud"
          -format none
          -translate none
          -file_mask "*.csv"
          -display_length 30
        }

        GuidoCheckBox applyBlockShift {
          -label "Apply block shift<br>+100m to Z values"
          -caption "Yes"
          -selected_value "yes"
          -unselected_value "no"
          -default "yes"
        }

        # Output assumed to be same as input but with .str/dtm extension, so no need to specify in form
        # GuidoField outputFile {
        #   -label "Output filename"
        #   -display_length 30
        #   -format none
        #   -null false
        # }

        GuidoField surveyInfo {
          -label "D1 Info (Surveyor, date, etc.)"
          -display_length 30
          -format none
        }
      }
    }
  }
}

# run form
SclCreateGuidoForm formHandle $myForm {}

$formHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

# assume output file is same as input but with .str/dtm extension
set outputFile [file rootname $inputFile]


# procedure for changing string numbers in string file
proc change_string_in_file {inputStringFile str_no} {
  puts "Renumbering string in file $inputStringFile"

  set output "delete_me.str"

  set in [open $inputStringFile r]
  set out [open $output w]

  set lines [split [read $in] "\n"]
  close $in

  # remove trailing blank lines
  while {[llength $lines] > 0 && [string trim [lindex $lines end]] eq ""} {
      set lines [lrange $lines 0 end-1]
  }

  for {set i 0} {$i < [llength $lines]} {incr i} {
      set line [lindex $lines $i]

      # skip the first two and last two lines
      if {$i >= 2 && $i < [expr {[llength $lines] - 2}]} {
          # Split the line into fields
          set fields [split $line ","]

          # check if the first field is "1" and replace it with "197"
          if {[lindex $fields 0] == "1"} {
              lset fields 0 $str_no
          }
          

          # join the fields back into a line
          set line [join $fields ","]
      }

      # write the line to the output file
      puts $out $line
  }

  close $out

  # delete original input
  if {[file exists $inputStringFile]} {
    file delete $inputStringFile
  } 
 
  # rename output file 
  if {[file exists $output]} { 
    file rename $output $inputStringFile 
  } 
 
  puts "String renumber file complete" 
} 


# main functions
if {[file exists $inputFile]} {
    file copy $inputFile.csv $inputFile.xyz
}

puts "Copied CSV to XYZ"

set status [ SclFunction "CLOUD FILE MESH" {
  frmPointCloudFileMesher={
    {
      inputFile="$inputFile"
      mesherMode="3DDeviation"
      deviation=".1"
      outputFile="$outputFile"
      densityReductionMethod="subsampling"
    }
  }
}]

change_string_in_file $outputFile.str $str_no

set status [ SclFunction "RECALL ANY FILE" {
  file="$outputFile.str"
  mode="openInNewLayer"
}]

set status [ SclFunction "CLEAN LAYER" {
  frm00605={
    {
      operation="Duplicate Point"
      dup_pnts_action="remove"
      dup_pnts_target="layer"
      dup_pnts_dist_min="0"
      dup_pnts_dist="0.06"
      dimension="2D"
      plane="plan"
    }
  }
}]

if {$surveyInfo ne ""} {
  set status [ SclFunction "GRAPHICS LAYER MATHS" {
    frm00702={
      {
        strrange="Y"
        main=table { str_range constraint field expr } {
          { "" "" "d1" "\"$surveyInfo\"" }
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
}

if {$applyBlockShift eq "yes"} {
  set status [ SclFunction "GRAPHICS LAYER MATHS" {
    frm00702={
      {
        strrange="Y"
        main=table { str_range constraint field expr } {
          { "" "" "z" "z+100" }
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
}

set status [ SclFunction "GRAPHICS CREATE DTM" {
  frm01311={
    {
      hiddenFieldTrim=""
      object_num="1"
      obj_name=""
      plane="plan"
      breaktest="N"
      interpolate_new_points="N"
    }
  }
}]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      saveMode="S"
      output_file="$outputFile.str"
      output_type="Surpac DTM Files"
      outputExt=".dtm"
      Surpac={
        Purpose=""
        range=""
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


puts "Loaded $outputFile.dtm"
puts "Macro finished"