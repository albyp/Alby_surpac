######################################################################
#
# Macro Name    : g:/10 - survey/macro/blr_radius.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Tue Jun 23 2020
#
# Description   : Blast Radius macro
#
# Author        : Alby Palmer
#
######################################################################

puts "Macro running"

# Guido form to select SO file
set guiForm {
  GuidoForm guiForm {
    -label "Process Blast Radius"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS
    -width 40

    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS

      GuidoPanel panel_1 {
        -label "Input file"
        -layout CentreLineLayout
        -border etched true
        -width 30

        GuidoFileBrowserField inputFile {
          -label "Setout file"
          -format none
          -translate none
          -display_length 30
          -extension false
        }
      }
    }
  }
}

SclCreateGuidoForm guiFormHandle $guiForm {}

$guiFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

set status [ SclFunction "OPEN FILE" {
  layer="$inputFile"
  location="$inputFile"
  plugin="Surpac String Files"
  Surpac={
    IDRange=""
    range=""
    descriptions="true"
  }
  styles=""
  replace="true"
  rescale="true"
}]

set status [ SclFunction "LAYER BOUNDARY" {
  frmBoundary={
    {
      inputLayerName="$inputFile"
      stringRange=""
      createBoundaryForEachString="N"
      outputLayerName="Boundary#1"
      hullType="concave"
      numberOfNeighbours="3"
      automatic="Y"
      clusterPoints="N"
    }
  }
}]

set status [ SclFunction "SELECT LAYER" {
  activelayer="boundary#1"
}]

set status [ SclFunction "DELETE LAYER" {
  layer="$inputFile"
}]

set status [ SclFunction "SELECT ITEM IN 3D" {
  select_context="graphics"
  application_context="graphics"
  select_action="replace"
  boxSelect="true"
  x1="-1"
  x2="1"
  y1="-1"
  y2="1"
}]

set status [ SclFunction "CIRCLE" {
  frm00036=table { radius arcdist bearing dip } {
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
    { "500" "50" "0" "0" }
  }
}]

set status [ SclFunction "CIRCLE" {} ]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="delete_me"
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
      location="delete_me"
      object_num="1"
      obj_name=""
      plane="plan"
      check_distance="0.0050"
      break="Y"
      anyspots="Y"
      spotrng="1,32000"
      brktest="N"
      interpolate_new_points="N"
      apply_boundary="N"
      inout="I"
    }
  }
}]

set status [ SclFunction "DTM BOUNDARY" {
  frm00201={
    {
      dtmloc="delete_me"
      obj_id="1"
      trisol_id="1"
      bdyloc="blr1"
      istr="1521"
    }
  }
}]

set status [ SclFunction "EXECUTE OS COMMAND" {
  frm00462={
    {
      os_cmd="del delete_me*.*"
    }
  }
}]

set status [ SclFunction "EXIT GRAPHICS" {} ]


# # 200m
#############################

set status [ SclFunction "OPEN FILE" {
  layer="$inputFile"
  location="$inputFile"
  plugin="Surpac String Files"
  Surpac={
    IDRange=""
    range=""
    descriptions="true"
  }
  styles=""
  replace="true"
  rescale="true"
}]

set status [ SclFunction "LAYER BOUNDARY" {
  frmBoundary={
    {
      inputLayerName="$inputFile"
      stringRange=""
      createBoundaryForEachString="N"
      outputLayerName="Boundary#1"
      hullType="concave"
      numberOfNeighbours="3"
      automatic="Y"
      clusterPoints="N"
    }
  }
}]

set status [ SclFunction "SELECT LAYER" {
  activelayer="boundary#1"
}]

set status [ SclFunction "DELETE LAYER" {
  layer="$inputFile"
}]

set status [ SclFunction "SELECT ITEM IN 3D" {
  select_context="graphics"
  application_context="graphics"
  select_action="replace"
  boxSelect="true"
  x1="-1"
  x2="1"
  y1="-1"
  y2="1"
}]

set status [ SclFunction "CIRCLE" {
  frm00036=table { radius arcdist bearing dip } {
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
    { "200" "50" "0" "0" }
  }
}]

set status [ SclFunction "CIRCLE" {} ]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="delete_me"
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
      location="delete_me"
      object_num="1"
      obj_name=""
      plane="plan"
      check_distance="0.0050"
      break="Y"
      anyspots="Y"
      spotrng="1,32000"
      brktest="N"
      interpolate_new_points="N"
      apply_boundary="N"
      inout="I"
    }
  }
}]

set status [ SclFunction "DTM BOUNDARY" {
  frm00201={
    {
      dtmloc="delete_me"
      obj_id="1"
      trisol_id="1"
      bdyloc="blr2"
      istr="1522"
    }
  }
}]

set status [ SclFunction "EXECUTE OS COMMAND" {
  frm00462={
    {
      os_cmd="del delete_me*.*"
    }
  }
}]

set status [ SclFunction "EXIT GRAPHICS" {} ]

set status [ SclFunction "RECALL ANY FILE" {
  file="blr1.str"
  mode="openInNewLayer"
}]

set status [ SclFunction "RECALL ANY FILE" {
  file="blr2.str"
  mode="appendToCurrentLayer"
}]

set status [ SclFunction "FILE SAVE" {
  frmsaveFileAs={
    {
      output_file="blr_new"
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

set status [ SclFunction "EXECUTE OS COMMAND" {
  frm00462={
    {
      os_cmd="del blr1.*"
    }
  }
}]

set status [ SclFunction "EXECUTE OS COMMAND" {
  frm00462={
    {
      os_cmd="del blr2.*"
    }
  }
}]
