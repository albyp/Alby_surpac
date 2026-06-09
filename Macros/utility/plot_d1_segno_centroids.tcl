######################################################################
#
# Macro Name    : plot_d1_segno_centroid.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Mon Jun 8 2026
#
# Description   : 
#
###################################################################################################################
#
# Macro Name    : plot_d1_segno_centroid.tcl
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

set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d10" "STRCAT(d1, \" ( \", _string_segment_no, \" )\")" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
      }
    }
  }
}]

set status [ SclFunction "DRAW DESC" {
  frm00089={
    {
      range1=""
      range2=""
      range3=""
      ifld_num="d10"
      textalignment="<"
      position="Centroid"
      layer_name="$layerName"
      display_object_number=""
      display_trisolation_number=""
    }
  }
}]

#########################

SclGetActiveViewport ViewportHandle

$ViewportHandle SclGetActiveLayer SwaHandle

set layerName [$SwaHandle SclGetId]

set status [ SclFunction "GRAPHICS LAYER MATHS" {
  frm00702={
    {
      strrange="Y"
      main=table { str_range constraint field expr } {
        { "" "" "d10" "STRCAT(d1, \"\\n\", _string_segment_no)" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
        { "" "" "" "" }
      }
    }
  }
}]

set status [ SclFunction "DRAW DESC" {
  frm00089={
    {
      range1=""
      range2=""
      range3=""
      ifld_num="d10"
      textalignment="<"
      position="Centroid"
      layer_name="$layerName"
      display_object_number=""
      display_trisolation_number=""
    }
  }
}]

