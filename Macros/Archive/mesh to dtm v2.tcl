###############################
# MESH, DENSE DTM & SIMPLE DTM
# Written by Alby Palmer 02/11/2019
###############################

puts "Macro running"

#Tags
set gf _gf


# Initial form
set myForm {
  GuidoForm myForm {
    -label "Mesh / DTM Tools"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 40
    
    GuidoPanel panel_left {
    -layout BoxLayout Y_AXIS
    
      #Title
      GuidoLabel bold_label {
      -label "<html><h1>Create DTM from Mesh</h1><br>
      <font color=\"red\">Set the work directory to the correct folder before proceeding</html>"
      -font_highlight 1 1 1
      }
      
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
      
      GuidoPanel panel_2 {
        -label "Input type"
        -layout CentreLineLayout
        -border etched true
        -width 30
        # Radio buttons for filetype
        GuidoButtonGroupPanel filetype {
          -label "Input file type"
          GuidoRadioButton filetype {
            -caption "DXF"
            -selected_value "dxf"
          }
          GuidoRadioButton filetype {
            -caption "DTM"
            -selected_value "dtm"
          }
        }
      }
      
      GuidoPanel panel_3 {
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
      
      GuidoPanel panel_4 {
        -label "Options"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoCheckBox simpledtm {
          -label "Simplified DTM?"
          -caption "Yes"
          -selected_value "Yes"
          -unselected_value "No"
        }
        
        GuidoComboBox simpleagg {
          -label "<html>Simplify Aggression<br>
              <font color=\"red\">Use 2 for general use.</html>"
          -width 1.5
          -format integer
          -null false
          -exclusive false
          -default 2
          -value_in 1 2 3 4 5 6 7 8 9 10
          -low_bound 1
          -high_bound 10
          -dependency {"[$simpledtm getCurrentValue]" == "Yes"}
        }
        
        GuidoField spotstring {
          -label "Spotheight string"
          -format integer
          -null false
          -default 1007
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

######
# DXF
######
if {$filetype == "dxf"} {
  
  set status [ SclFunction "RECALL ANY FILE" {
    file="$inputfile.dxf"
    mode="openInNewLayer"
  }]
  
  set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="$outputfile"
      output_type="Surpac String Files"
      outputExt=".str"
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
  }]
  
  set status [ SclFunction "EXIT GRAPHICS" {} ]
  
  set status [ SclFunction "RECALL ANY FILE" {
    file="$outputfile.str"
    mode="openInNewLayer"
  }]
  
  set status [ SclFunction "STRING RENUMBER RANGE" {
    frm00068={
      {
        old_str_range="1,999999"
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
          Purpose=""
          range=""
          FileFormat="text"
          ForceValidation="true"
          ForceCompatibility="true"
        }
        saveStyle="N"
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
}

######
# DTM
######
if {$filetype == "dtm"} {
  
  set status [ SclFunction "RECALL ANY FILE" {
    file="$inputfile.dtm"
    mode="openInNewLayer"
  }]
  
  set status [ SclFunction "STRING RENUMBER RANGE" {
    frm00068={
      {
        old_str_range="1,999999"
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
          Purpose=""
          range=""
          FileFormat="text"
          ForceValidation="true"
          ForceCompatibility="true"
        }
        saveStyle="N"
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
}

if {$simpledtm == "Yes"} {
  set status [ SclFunction "RECALL ANY FILE" {
    file="$outputfile.dtm"
    mode="openInNewLayer"
  }]
  
  set status [ SclFunction "MESH SIMPLIFY" {
	  frmsolidsSimplify={
		{
		  obj_range=""
		  trisol_range=""
		  aggressiveness="$simpleagg"
		  outputOptions="new"
		  outputLayerName="$outputfile.dtm_simplify"
		}
	  }
	}]
  
  set status [ SclFunction "FILE SAVE" {
	  frmsaveFileAs={
		{
		  output_file="$outputfile$gf"
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
	}]

	set status [ SclFunction "EXIT GRAPHICS" {} ]

	set status [ SclFunction "RECALL ANY FILE" {
	  file="$outputfile$gf.str"
	  mode="none"
	}]

	set status [ SclFunction "STRING RENUMBER RANGE" {
	  frm00068={
		{
		  old_str_range="1,999999"
		  new_str_range="$spotstring"
		}
	  }
	}]

	set status [ SclFunction "FILE SAVE" {
	  frmsaveFileAs={
		{
		  output_file="$outputfile$gf"
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
	}]

	set status [ SclFunction "CREATE DTM" {
	  frm00126={
		{
		  location="$outputfile$gf"
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

	set status [ SclFunction "EXIT GRAPHICS" {} ]
}
