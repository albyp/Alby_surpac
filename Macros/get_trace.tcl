######################################################################
#
# Macro Name    : g:/10 - survey/macro/get_trace.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Wed Mar 25 2020
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
        -label "Input"
        -layout CentreLineLayout
        -border etched true
        -width 30

        GuidoButtonGroupPanel noe {
          -label "GET Trace"

          GuidoRadioButton noea {
            -caption "New"
            -selected_value "0"
          }

          GuidoRadioButton noeb {
            -caption "Existing"
            -selected_value "1"
          }
        }

        # Trace File
        GuidoFileBrowserField traceinput {
          -label "GET trace file"
          -format none
          -translate none
          -display_length 30
          -extension false
          -dependency {"[$noea getCurrentValue]" == "0"}
        }

        # Contour File
        GuidoFileBrowserField contourinput {
          -label "Trace contour file"
          -format none
          -translate none
          -display_length 30
          -extension false
          -dependency {"[$noeb getCurrentValue]" == "1"}
        }
      }

      # GET Options
      GuidoPanel panel_2 {
        -label "GET settings"
        -layout CentreLineLayout
        -border etched true
        -width 30

        GuidoField getLabel {
          -label "GET Label"
          -display_length 5
          -format none
          -null false
        }

        GuidoField rngMin {
          -label "Min RL"
          -display_length 5
          -format none
          -null false
        }

        GuidoField rngMax {
          -label "Max RL"
          -display_length 5
          -format none
          -null false
        }

        GuidoField rngInt {
          -label "Interval"
          -display_length 5
          -format none
          -null false
          -default 2.5
        }

        GuidoField getStr {
          -label "String"
          -display_length 5
          -format integer
          -null false
          -default 1529
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

# ##########
# Constants
# ##########
set contour _contour
set und _

 # set pathprofile G:10 - Survey/admin/surpac_solid_profiles
 # set dia5 G:10 - Survey/admin/surpac_solid_profiles/profile_5m_circle.str
 # set dia10 G:10 - Survey/admin/surpac_solid_profiles/profile_10m_circle.str

# ##########
# Generate Contour
# ##########
if {$noe == "0"} {
	set status [ SclFunction "EXIT GRAPHICS" {} ]

	set status [ SclFunction "RECALL ANY FILE" {
	  file="$traceinput.str"
	  mode="appendToCurrentLayer"
	}]

	set status [SclSelectPoint pnt "Select the trace" layer str_no seg_no pnt_no x y z desc]

	set status [ SclFunction "TRIANGULATE CENTRE LINE AND PROFILE" {
	  frm00497={
		{
		  plloc="profile_5m_circle.str"
		  plid=""
		  use_explicit_object_id="N"
		  scale="1"
		  yoff="0"
		  xoff="0"
		  zoff="0"
		  rotation="0"
		  gfactor="1"
		  vcon="N"
		  triangulate_first_face="N"
		  triangulate_last_face="N"
		}
	  }
	  select_point={
		{
		  winx="0"
		  winy="0"
		  objectx="$x"
		  objecty="$y"
		  objectz="$z"
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
			FileFormat="binary"
			range=""
			Purpose=""
			ForceCompatibility="true"
			ForceValidation="true"
		  }
		  saveStyle="N"
		}
	  }
	}]

	set status [ SclFunction "EXIT GRAPHICS" {} ] ;# Necessary?

	set status [ SclFunction "EXTRACT CONTOUR" {
	  frm04949={
		{
		  dtmloc="delete_me"
		  dtmfld="Z"
		  object_id="1"
		  trisolation_id="2"
		  cloc="$traceinput$contour"
		  contval="N"
		  deftype="I"
		  conmin="$rngMin"
		  conmax="$rngMax"
		  ci="$rngInt"
		  index="N"
		}
	  }
	}]

	set status [ SclFunction "EXIT GRAPHICS" {} ]

	set status [ SclFunction "RECALL ANY FILE" {
	  file="$traceinput$contour.str"
	  mode="openInNewLayer"
	}]

	set status [ SclFunction "STRING RENUMBER RANGE" {
	  frm00068={
		{
		  old_str_range="1,32000"
		  new_str_range="$getStr"
		}
	  }
	}]

	set status [ SclFunction "GRAPHICS LAYER MATHS" {
	  frm00702={
		{
		  strrange="Y"
		  main=table { str_range constraint field expr } {
			{ "" "" "d1" "\"$getLabel\"" }
		  }
		}
	  }
	}]

	set status [ SclFunction "FILE SAVE" {
	  frmsaveFileAs={
		{
		  output_file="$traceinput$contour"
		  output_type="Surpac String Files"
		  outputExt=".str"
		  Surpac={
			FileFormat="text"
			range=""
			Purpose="Contours for $getLabel"
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
}

# ##########
# Contour Splits
# ##########
set fromRL $rngMax
set toRL $rngMin



while {$fromRL >= $toRL} {
  set fromRLPlus [expr {$fromRL + 1}]

  set status [ SclFunction "EXIT GRAPHICS" {} ]

  set status [SclFunction "RECALL ANY FILE" {
      file="$traceinput$contour.str"
      mode="openInNewLayer"
  }]

  set status [ SclFunction "CLIP BY PLANE" {
    frmTrimByElevation={
      {
        clippingPlane="Z"
        min_slider="990"
        min_plane_value="$fromRL"
        max_slider="1000"
        max_plane_value="$fromRLPlus"
        retain="Y"
        newlayerStorage="N"
        pureStringData="Y"
        anySpotHeight="N"
      }
    }
  }]

  set status [ SclFunction "FILE SAVE" {
    frmsaveFileAs={
      {
        output_file="$getLabel$und$fromRL"
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

  set fromRL [expr {$fromRL - 2.5}]

}
