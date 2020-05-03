######################################################################
#
# Macro Name    : g:/10 - survey/working/alby/macro_working/get processing/get_trace_process.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Mon Mar 23 2020
#
# Description   : Process drill trace string into lost_get string files
#
# Author        : Alby Palmer
#
######################################################################

puts "Macro running"

##############
# Prompt Form
##############
set myForm {
  GuidoForm myForm {
    -label "GET Process (Trace)"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 40
    
    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS
      
      # Title
      GuidoLabel bold_label {
      -label "<html><h1>Process GET Strings from Drill Trace</h1><br>
      <font color=\"red\">Set the work directory to the correct folder before proceeding</html>"
      -font_highlight 1 1 1
      }
      
      # Input File
      GuidoPanel panel_1 {
        -label "Input file"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoFileBrowserField inputfile {
          -label "Select file"
          -format none
          -translate none
          -display_length 30
          -extension false
        }
      }
      
      # Requirements
      # - Min & Max lost_gets
      # - lost_get directory (set for pit??)
      # - get description (or tag)
      # - GET string number (default to 1529)
      # - profile (5 or 10m - default to 5m)
      
      
      # GET Name
      GuidoPanel panel_2 {
        -label "GET Info"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoField getname {
          -label "GET label"
          -display_length 25
          -format none
          -null false
        }
      }
      
      
    }
  }
}

SclCreateGuidoForm myFormHandle $myForm {}

$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}


##############
# Constants
##############
set pathprof GET_Profile:


##############
# Main Functions
##############
set status [ SclFunction "RECALL ANY FILE" {
  file="GET.str"
  mode="none"
}]

set status [ SclFunction "TRIANGULATE CENTRE LINE AND PROFILE" {
  frm00497=table { plloc plid use_explicit_object_id scale yoff xoff zoff rotation gfactor vcon triangulate_first_face triangulate_last_face } {
    { "get_profile:/profile_5m_circle.str" "" "N" "1" "0" "0" "0" "0" "1" "N" "N" "N" }
  }
  select_point={
    {
      objectx="0"
      objecty="0"
      objectz="0"
      snap_projection="off"
    }
  }
}]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="delete_me"
      output_type="Surpac DTM Files"
      outputExt=".dtm"
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
  frmSaveMultipleFiles={
    {
      _action="apply"
    }
  }
}]

set status [ SclFunction "EXTRACT CONTOUR" {
  frm04949={
    {
      dtmloc="delete_me"
      dtmfld="Z"
      object_id="1"
      trisolation_id="1"
      cloc="contours"
      contval="N"
      deftype="R"
      conrng="0,1000,2.5"
      index="N"
    }
  }
  frm00121={
    {
      _action=""
    }
  }
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="contours.str"
  mode="none"
}]

set status [ SclFunction "STRING RENUMBER RANGE" {
  frm00068={
    {
      old_str_range="1,99999"
      new_str_range="1529"
    }
  }
}]

set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d1" "\"$getname\"" }
      }
    }
  }
}]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="contours"
      output_type="Surpac String Files"
      outputExt=".str"
      Surpac={
        FileFormat="text"
        range=""
        Purpose="Contours from delete_me.dtm"
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

##############
# GET Amending Loop
##############
set loop 1
while {$loop == 1} {

  set status [ SclFunction "EXIT GRAPHICS" {} ]
  
  set status [ SclFunction "RECALL ANY FILE" {
    file="contours.str"
    mode="none"
  }]

  # Level select
  set clipform {
    GuidoForm clipform {
      -label "GET Process"
      -default_buttons
      -defaults_key sectionsfile
      -layout BoxLayout Y_AXIS
      -width 40
    
      GuidoPanel panel_1 {
        -label "Clip box"
        -layout CentreLineLayout
        -border etched true
        -width 30
      
        GuidoFileBrowserField getamendfile {
          -label "Select file"
          -format none
          -translate none
          -display_length 30
          -extension false
        }
        
        GuidoField clipz {
          -label "GET RL"
          -width 10
          -null true
        }
      }
    }
  }

  SclCreateGuidoForm fmclip $clipform {}
  $fmclip SclRun {}

  if {$_status == "cancel"} then {
        puts "Macro Cancelled"
        return
  }
  
  set clipzmin [expr {$clipz - 0.1}]
  set clipzmax [expr {$clipz + 0.1}]

  ##############
  # Clip Contours
  ##############
  set status [ SclFunction "CLIP BY BOX" {
    frm01322={
      {
        where="outside"
      }
    }
    window_drag={
      {
        objectx1="0"
        objecty1="0"
        objectz1="$clipzmin"
        objectx2="100000000"
        objecty2="100000000"
        objectz2="$clipzmax"
      }
    }
  }]

  set status [ SclFunction "IDENTIFY POINT" {
    select_point={
      {
        objectx="0"
        objecty="0"
        objectz="0"
        snap_projection="off"
      }
    }
  }]

  set idz $objectz

  set rlloc [expr {round($idz)}]



  

  set status [ SclFunction "RECALL ANY FILE" {
    file="$getamendfile"
    mode="appendToCurrentLayer"
  }]

  set status [ SclFunction "FILE SAVE" {
    frmsaveFileAs={
      {
        output_file="$getamendfile"
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


  set endclipform {
    GuidoForm endclipform {
      -label "End GET"
      -default_buttons
    
      GuidoLabel Happy? {
        -label "Apply to Finish   Cancel to Continue"
      }
    }
  }
  
  SclCreateGuidoForm fmendclip $endclipform {}
  
  $fmendclip SclRun {}
  
  if {$_status == "apply"} {
    set loop 2
  }

# End of loop
}


