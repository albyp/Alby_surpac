######################################################################
#
# Macro Name    : plot_d1_centroid.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Mon Jun 8 2026
#
# Description   : 
#
######################################################################

SclGetActiveViewport ViewportHandle

$ViewportHandle SclGetActiveLayer SwaHandle

set layerName [$SwaHandle SclGetId]

set status [ SclFunction "DRAW DESC" {
  frm00089={
    {
      range1=""
      range2=""
      range3=""
      ifld_num="d1"
      textalignment="<"
      position="Centroid"
      layer_name="$layerName"
      display_object_number=""
      display_trisolation_number=""
    }
  }
}]