######################################################################
#
# Macro Name    : g:/10 - survey/working/alby/macro_working/get processing/get_processing.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Mon Mar 23 12:15:54 2020
#
# Description   : 
#
######################################################################

set status [ SclFunction "RECALL ANY FILE" {
  file="GET.str"
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
      cloc="contours"
      contval="N"
      deftype="R"
      conrng="0,1000,2.5"
      index="N"
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
      new_str_range="1"
    }
  }
}]

set status [ SclFunction "NEW LAYER" {
  frm00488={
    {
      swa_name="rl_layer_1"
    }
  }
}]

set status [ SclFunction "LAYER OPTIONS" {
  layername="get.str"
  visible="false"
}]

set status [ SclFunction "SECTION" {} ]

set status [ SclFunction "IDENTIFY POINT" {
  select_point=table { winx winy objectx objecty objectz snap_projection } {
    { "-0.067" "0.289" "437298.441" "6911280.083" "465.002" "off" }
    { "-0.040" "0.398" "437299.591" "6911281.128" "467.181" "off" }
  }
}]

set status [ SclFunction "CLEAN STRING" {
  frm00605={
    {
      _action="cancel"
    }
  }
}]

set status [ SclFunction "INTERSECT HORIZONTAL" {} ]

