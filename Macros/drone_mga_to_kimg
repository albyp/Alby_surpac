######################################################################
#
# Macro Name    : drone_mga_to_kimg.tcl
#
# Version       : Surpac 7.6.2 (x64)
#
# Creation Date : Mon May 20 
#
# Author        : Alby Palmer (Land Surveys)
#
# Description   : Convert point cloud to MGA and KIMG2 coordinate system
#                 Imports point cloud, saves MGA (str/dtm), converts to KIMG2, 
#                 appends surveyor details,saves KIMG2 (str/dtm)
#
######################################################################

puts "Macro running"

# spotheight string number
set str_no 197

# form
set myForm {
  GuidoForm myForm {
    -label "XYZ point cloud to MGA / KIMG2"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 50
    -height 16

    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS

      GuidoLabel bold_label {
        -label "<html><h1>Convert XYZ point cloud to MGA and local KIMG2 coords</h1><br>
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
          -file_mask "*.dspc *.xyz *.laz *.asc *.las"
          -display_length 30
        }

        GuidoField outputFile {
          -label "Output filename"
          -display_length 30
          -format none
          -null false
        }

        GuidoField surveyInfo {
          -label "D1 Info (dronedata_A.Surveyor_YYMMDD)"
          -display_length 30
          -format none
          -null false
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

# variables
set mgaExt "_mga"
set kimgExt "_kimg"
set mgaName "$outputFile$mgaExt"
set kimgName "$outputFile$kimgExt"

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

# procedure to convert mga94z51 to kimg2
proc convert_mga_kimg2 {input output} {
  puts "Converting MGA to KIMG2"

  set status [ SclFunction "2D TRANSFORM" {
    frm00284={
      {
        locn="$input"
        lrange=""
        ftype="S"
        oloc="$output"
        rl="Y"
        trnax="Y"
        rltyp="A"
        rl_correct="1004.808"

        yd1="8214716.606"
        xd1="582286.434"
        yd2="8217245.902"
        xd2="577567.392"
        ym1="1573.852"
        xm1="15771.339"
        ym2="1387.102"
        xm2="10418.628"
      }
    }
    frm00285={
      {
        accept="Y"
      }
    }
    frm00121={
      {
        _action=""
      }
    }
  }]

}

# main functions
set status [ SclFunction "CLOUD FILE MESH" {
  frmPointCloudFileMesher={
    {
      inputFile="$inputFile"
      mesherMode="3DDeviation"
      deviation=".05"
      outputFile="$mgaName"
      densityReductionMethod="subsampling"
    }
  }
}]

change_string_in_file $mgaName.str $str_no

convert_mga_kimg2 $mgaName $kimgName

set status [ SclFunction "RECALL ANY FILE" {
  file="$kimgName.str"
  mode="openInNewLayer"
}]

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
      output_file="$kimgName.str"
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


puts "Loaded $kimgName.dtm"
puts "Macro finished"
