######################################################################
#
# Macro Name    : mesh-to-dtm.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Sat Nov 02 2019
#                 Wed Dec 14 2022
#
# Author        : Alby Palmer 
#
# Description   : Create Surpac surface from point cloud
#
######################################################################

puts "Macro running"

set tmp _temp

set myForm {
  GuidoForm myForm {
    -label "Point cloud to Surpac DTM"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    
    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS
    
      GuidoLabel bold_label {
        -label "<html><h1>Convert point cloud to Surpac DTM</h1><br>
      <font color=\"red\">Set the work directory to the correct folder before proceeding</html>"
      -font_highlight 1 1 1
      }
      
      GuidoPanel panel_1 {
        -label "Input"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoFileBrowserField inputfile {
          -label "Select point cloud"
          -format none
          -translate none
          -file_mask "*.dspc *.xyz *.laz *.asc *.las"
          -display_length 25
        }
      }
      
      GuidoPanel panel_2 {
        -label "Output"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoField outputfile {
          -label "Output file"
          -display_length 25
          -format none
          -null false
        }
      }
      
      GuidoPanel panel_3 {
        -label "Settings"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoField meshDeviation {
          -label "<html>Mesher deviation<br>
          <font color=\"red\">Use 0.1 for general use</html>"
          -width 3
          -format float
          -null false
          -default 0.1
        }
        
        GuidoField spotstring {
          -label "Spotheight string"
          -format integer
          -null false
          -default 300
        }
        
        GuidoCheckBox delTemp {
          -label "Delete temporary files"
          -caption "Yes"
          -default "y"
          -selected_value "y"
          -unselected_value "n"
        }
      }
    }
  }
}

# Main functions
SclCreateGuidoForm myFormHandle $myForm {}

$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

set status [ SclFunction "CLOUD FILE MESH" {
  frmPointCloudFileMesher={
    {
      inputFile="$inputfile"
      mesherMode="3DDeviation"
      deviation="$meshDeviation"
      outputFile="$outputfile$tmp"
    }
  }
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="$outputfile$tmp.str"
  mode="openInNewLayer"
}]

set status [ SclFunction "STRING RENUMBER RANGE" {
  frm00068={
    {
      old_str_range="1"
      new_str_range="$spotstring"
    }
  }
}]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="$outputfile"
      output_type="Surpac String Files"
      outputExt=".str"
      Surpac={
        FileFormat="text"
        range=""
        Purpose=""
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

set status [ SclFunction "EXIT GRAPHICS" {} ]

set status [ SclFunction "CREATE DTM" {
  frm00126={
    {
      location="$outputfile"
      object_num="1"
      obj_name=""
      plane="plan"
      check_distance="0.0050"
      break="Y"
      anyspots="Y"
      spotrng="$spotstring"
      brktest="Y"
      interpolate_new_points="N"
      apply_boundary="N"
      inout="I"
    }
  }
}]

# Clean up files
if {$delTemp == "y"} {

  set status [ SclFunction "EXECUTE OS COMMAND" {
    frm00462={
      {
        os_cmd="del *$tmp*"
      }
    }
  }]
  
  set status [ SclFunction "EXECUTE OS COMMAND" {
    frm00462={
      {
        os_cmd="del *.log"
      }
    }
  }]
  
  set status [ SclFunction "EXECUTE OS COMMAND" {
    frm00462={
      {
        os_cmd="del *.dspc"
      }
    }
  }]
  
  # Delete "_dscache" folder
  set list [split "$inputfile" .]
  lappend delfolder [lindex $list 0]
  set dsc _dscache
  file delete -force "$delfolder$dsc"
}
