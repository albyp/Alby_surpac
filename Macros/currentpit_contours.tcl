######################################################################
#
# Macro Name    : currentpit_contours.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Sat Apr  11 2020
#
# Description   : Export currentpit as contour and generate DTM for usability of Geology and Engineering.
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
    -label "Create contours for currentpit"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    
    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS
      -label "<html><p><h1>Generate contours for map and usability purposes</h1></p></html>"
      
      GuidoPanel panel_1 {
        -layout CentreLineLayout vertical
        -border etched true
        -width 37
        -label "<html><p><h3>Select pit</h3></p></html>"
        
        GuidoButtonGroupPanel pit {
          -label "Select pit"
          -layout BoxLayout X_AXIS
          
          GuidoRadioButton pit {
            -caption "GW"
            -selected_value "gw"
          }
          
          GuidoRadioButton pit {
            -caption "TW"
            -selected_value "tw"
          }
          
          GuidoRadioButton pit {
            -caption "ERL"
            -selected_value "erl"
          }
        }
      }
      
      GuidoPanel panel_2 {
        -layout CentreLineLayout vertical
        -border etched true
        -width 37
        -label "<html><p><h3>Contours to generate</h3></p></html>"
        
        GuidoCheckBox cont2 {
          -caption "2m"
          -selected_value "yes"
          -unselected_value "no"
        }
        
        GuidoCheckBox cont05 {
          -caption "0.5m"
          -selected_value "yes"
          -unselected_value "no"
        }
      }
      
      GuidoPanel panel_3 {
        -layout CentreLineLayout
        -border etched true
        -width 37
        -label "<html><p><h3>Generate DTM from Contours</h3></p></html>"
        
        GuidoCheckBox cont2dtm {
          -caption "2m"
          -selected_value "yes"
          -unselected_value "no"
        }
        
        GuidoCheckBox cont05dtm {
          -caption "0.5m"
          -selected_value "yes"
          -unselected_value "no"
        }
        
      }
    }
  
    #GuidoPanel logoPanel1 {
    #  -layout BoxLayout Y_AXIS
    #
    #  GuidoPanel logoPanel2 {
    #    -layout BoxLayout X_AXIS
    #
    #    GuidoFiller fill4 {
    #      -width 0.1
    #    }
    #
    #    GuidoLabel advertLabel {
    #      -label "Alby Palmer"
    #      -font_highlight 255 0 0
    #      -icon "icons/logo.gif"
    #    }
    #
    #    GuidoFiller fill5 {
    #      -width 0.1
    #    }
    #  }
    #
    #  GuidoFiller fill6 {
    #    -height 0.1
    #  }
    #}
  }
}

SclCreateGuidoForm myFormHandle $myForm {}

$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

##############
# Contants
##############

set und "_"
set contit2 "contour2"
set contit05 "contour05"

# Change contour string if required
set contstring "1008"

##############
# Contouring and Site Parameters
##############

if {$pit == "gw"} {
  puts "Garden Well selected"
  # Pit constants
  set pit_logical "CURRENT_PIT_GW"
  set gwmin "200"
  set gwmax "510"
  
  # Change directory
  set status [ SclFunction "CHANGE DIRECTORY" {
    frm00035={
      {
        directory="CURRENT_PIT_GW:"
      }
    }
  }]

  # Extract contours 2m
  if {$cont2 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_gw"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_gw_contour2"
          contval="N"
          deftype="I"
          conmin="$gwmin"
          conmax="$gwmax"
          ci="2"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_gw_contour2.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_gw_contour2"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_gw.dtm"
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
    
    # Create DTM from contour
    if {$cont2dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_gw_contour2"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
  
  # Extract contours 0.5m
  if {$cont05 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_gw"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_gw_contour05"
          contval="N"
          deftype="I"
          conmin="$gwmin"
          conmax="$gwmax"
          ci="0.5"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_gw_contour05.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_gw_contour05"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_gw.dtm"
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
    
    # Create DTM from contour
    if {$cont05dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_gw_contour05"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
}





if {$pit == "tw"} {
  puts "Toohey's Well selected"
  # Pit constants
  set pit_logical "CURRENT_PIT_TW"
  set twmin "200"
  set twmax "510"
  
  # Change directory
  set status [ SclFunction "CHANGE DIRECTORY" {
    frm00035={
      {
        directory="CURRENT_PIT_TW:"
      }
    }
  }]

  # Extract contours 2m
  if {$cont2 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_tw"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_tw_contour2"
          contval="N"
          deftype="I"
          conmin="$twmin"
          conmax="$twmax"
          ci="2"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_tw_contour2.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_tw_contour2"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_tw.dtm"
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
    
    # Create DTM from contour
    if {$cont2dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_tw_contour2"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
  
  # Extract contours 0.5m
  if {$cont05 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_tw"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_tw_contour05"
          contval="N"
          deftype="I"
          conmin="$twmin"
          conmax="$twmax"
          ci="0.5"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_tw_contour05.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_tw_contour05"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_tw.dtm"
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
    
    # Create DTM from contour
    if {$cont05dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_tw_contour05"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
}






if {$pit == "erl"} {
  puts "Erlistoun selected"
  # Pit constants
  set pit_logical "CURRENT_PIT_ERL"
  set erlmin "200"
  set erlmax "510"
  
  
  # Change directory
  set status [ SclFunction "CHANGE DIRECTORY" {
    frm00035={
      {
        directory="CURRENT_PIT_ERL:"
      }
    }
  }]

  # Extract contours 2m
  if {$cont2 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_erl"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_erl_contour2"
          contval="N"
          deftype="I"
          conmin="$erlmin"
          conmax="$erlmax"
          ci="2"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_erl_contour2.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_erl_contour2"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_erl.dtm"
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
    
    # Create DTM from contour
    if {$cont2dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_erl_contour2"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
  
  # Extract contours 0.5m
  if {$cont05 == "yes"} {
    set status [ SclFunction "EXTRACT CONTOUR" {
      frm04949={
        {
          dtmloc="currentpit_erl"
          dtmfld="Z"
          object_id="1"
          trisolation_id="1"
          cloc="currentpit_erl_contour05"
          contval="N"
          deftype="I"
          conmin="$erlmin"
          conmax="$erlmax"
          ci="0.5"
          index="N"
        }
      }
    }]
    
    set status [ SclFunction "RECALL ANY FILE" {
      file="currentpit_erl_contour05.str"
      mode="openInNewLayer"
    }]
    
    set status [ SclFunction "STRING RENUMBER RANGE" {
      frm00068={
        {
          old_str_range="1,99999"
          new_str_range="$contstring"
        }
      }
    }]

    set status [ SclFunction "FILE SAVE" {
      frmsaveFileAs={
        {
          output_file="currentpit_erl_contour05"
          output_type="Surpac String Files"
          outputExt=".str"
          Surpac={
            FileFormat="text"
            range=""
            Purpose="Contours from currentpit_erl.dtm"
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
    
    # Create DTM from contour
    if {$cont05dtm =="yes"} {
      set status [ SclFunction "CREATE DTM" {
        frm00126={
          {
            location="currentpit_erl_contour05"
            object_num="1"
            obj_name=""
            plane="plan"
            check_distance="0.0050"
            break="Y"
            anyspots="Y"
            spotrng="1006,1007"
            brktest="N"
            interpolate_new_points="N"
            apply_boundary="N"
            inout="I"
          }
        }
      }]
    }
  }
}

set status [ SclFunction "EXIT GRAPHICS" {} ]