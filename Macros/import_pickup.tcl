######################################################################
#
# Macro Name    : import_pickup.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Mon Jun 8 2026
#
# Author        : Alby Palmer
#
# Description   : Imports csv file (code, y, x, z, desc)
#                 uses logicals "DOWNLOADS" as the base folder.
#
######################################################################
puts "Macro running"

set form [subst {
	GuidoForm form {
		-label "Import pickup from csv"
		-default_buttons
		-defaults_key sectionsfile
		-layout BoxLayout Y_AXIS
		-width 25
		-height 5

		GuidoPanel panel_left {
			-layout BoxLayout Y_AXIS

      GuidoFileBrowserField inputFile {
        -start_dir "DOWNLOADS:"
        -label "Select pickup file"
        -format none
        -translate none
        -file_mask "*.csv"
        -display_length 15
        -extension false
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

set fileName [file tail $inputFile]

set status [ SclFunction "IMPORT COORDINATES" {
  frm00279={
    {
      inloc="$inputFile"
      inrange=""
      iext="csv"
      swa_desc="Y"im
      newloc="$fileName"
      komma="Y"
      sep=","
      hd_rec="N"
      ax_rec="N"
      numdesc="1"
    }
  }
  frm00280={
    {
      iord_str="1"
      iord_y="2"
      iord_x="3"
      iord_z="4"
    }
  }
  frm00281={
    {
      iord_desc="5"
    }
  }
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="$fileName.str"
  mode="none"
}]
