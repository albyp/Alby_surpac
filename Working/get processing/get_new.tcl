######################################################################
#
# Macro Name    : g:/10 - survey/working/alby/macro_working/get processing/get_trace_process.tcl
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

      # Has the Trace Contour been made

      # Input File
      GuidoPanel panel_1 {
        -label "Inputs"
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


        GuidoFileBrowserField traceinput {
          -label "GET trace file"
          -format none
          -translate none
          -display_length 30
          -extension false
          -dependency {"[$noea getCurrentValue]" == "0"}
        }

        GuidoFileBrowserField contourinput {
          -label "Trace contour file"
          -format none
          -translate none
          -display_length 30
          -extension false
          -dependency {"[$noeb getCurrentValue]" == "1"}
        }
      }

      GuidoPanel panel_2 {
        -label "Trace settings"
        -layout CentreLineLayout
        -border etched true
        -width 30

        GuidoField getlabel {
          -label "GET Label"
          -display_length 25
          -format none
          -null false
        }

        GuidoField flitchrng {
          -label "Flitch interval"
          -format integer
          -null false
          -default 2.5
          -dependency {"[$noea getCurrentValue]" == "0"}
        }

        GuidoButtonGroupPanel profdia {
          -label "GET Radius"
          -dependency {"[$noeb getCurrentValue]" == "1"}

          GuidoRadioButton dia {
            -caption "2.5m Radius"
            -selected_value "dia5"
          }

          GuidoRadioButton dia {
            -caption "5m Radius"
            -selected_value "dia10"
          }
        }

        # Possibly add option to allow for different size profiles to be applied (i.e. 2.5m radius, 5m radius)
      }

      GuidoPanel panel_3 {
        -layout CentreLineLayout vertical
        -border etched true
        -width 15

        GuidoButtonGroupPanel pit {
          -label "Pit"
          -layout BoxLayout X_AXIS

          GuidoRadioButton pita {
            -caption "GW"
            -selected_value "gw"
          }

          GuidoRadioButton pitb {
            -caption "TW"
            -selected_value "tw"
          }

          GuidoRadioButton pitc {
            -caption "ERL"
            -selected_value "erl"
          }
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
set contours _contours

set pathprofile G:10 - Survey/admin/surpac_solid_profiles
set dia5 G:10 - Survey/admin/surpac_solid_profiles/profile_5m_circle.str
set dia10 G:10 - Survey/admin/surpac_solid_profiles/profile_10m_circle.str

if {$dia == "dia5"} {
  set $profile $dia5
}

if {$dia == "dia10"} {
  set $profile $dia10
}

# ##########
# Main Functions
# ##########

# If new GET trace
if {$noea == "0"} {
  set status [ SclFunction "EXIT GRAPHICS" {} ]

  set status [ SclFunction "RECALL ANY FILE"  {
    file="$traceinput.str"
    mode="openInNewLayer"
  }]

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

  set status [ SclFunction "EXTRACT CONTOUR" {
    frm04949={
      {
        dtmloc="delete_me"
        dtmfld="Z"
        object_id="1"
        trisolation_id="2"
        cloc="$traceinput$contours"
        contval="N"
        deftype="R"
        conrng="0,1000,2.5"
        index="N"
      }
    }
  }]

}

# If existing GET trace contour
if {$noeb == "1"} {
  set status [ SclFunction "RECALL ANY FILE"  {
    file="$contourinput.str"
    mode="openInNewLayer"
  }]
}
