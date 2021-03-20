###############################
# Floor Deviation Plan
# Written by Alby Palmer 10/02/2021
###############################

puts "Macro running"

# Tags and defaults
  # Set to string number for pit design string
  set backgroundSTR 1
  # Set to the max RL of any pits/dump in question
  set RLMax 1000

# Main Form
set myForm {
  GuidoForm form {
    -label "Create Floor Deviation Plan"
    -layout BoxLayout Y_AXIS
    -default_buttons
    -defaults_key sectionsfile
    -width 40
   
    GuidoPanel panel_left {
      -layout BoxLayout Y_AXIS
      
      # Title
      GuidoLabel bold_label {
        -label "<html><h1>Create Floor Deviation Plan</h1><br>
        <font color=\"red\">Set the work directory to the correct folder before proceeding</html>"
        -font_highlight 1 1 1
      }
      
      # Panel for selecting DTM files (current pit and design pit)
      GuidoPanel panel_1 {
        -label "Input files"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoFileBrowserField currentPitDTM {
          -label "Select current pit"
          -format none
          -file_mask "*.dtm"
          -width 25
          -null false
        }
        
        GuidoFileBrowserField designPitSTR {
          -label "Select design pit"
          -format none
          -file_mask "*.str"
          -width 25
        }
      }
      
      GuidoPanel panel_2 {
        -label "Options"
        -layout CentreLineLayout
        -border etched true
        -width 30
        
        GuidoField RL {
          -label "Enter floor RL"
          -display_length 5
          -null false
        }
      }
    }
  }
}

# Run form
SclCreateGuidoForm myFormHandle $myForm {}
$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}


# Main functions
# Recall current pit DTM
set status [ SclFunction "OPEN FILE" {
  layer="current pit"
  location="$currentPitDTM"
  plugin="Surpac DTM Files"
  Surpac={
    descriptions="true"
    range=""
    IDRange=""
  }
  styles="SSI_STYLES:\\styles.ssi"
  replace="true"
  rescale="true"
}]


#Colour band DTM
set status [ SclFunction "DRAW DTM/3DM" {
  frm00530={
    {
      range1="1"
      range2="1"
      false_colour_type="4"
      colours=table { colour label expression } {
        { "grey" "" "dip>=10" }
        { "light grey" "" "z>=0 & z<[expr ($RL-0.6)]" }
        { "cerulean" "LOW 0.6m - 0.8m" "z>=[expr ($RL-0.8)] & z<=[expr ($RL-0.6)]" }
        { "blue" "LOW 0.4m - 0.6m" "z>=[expr ($RL-0.6)] & z<=[expr ($RL-0.4)]" }
        { "cyan" "LOW 0.2m - 0.4m" "z>=[expr ($RL-0.4)] & z<=[expr ($RL-0.2)]" }
        { "green" "OKAY" "z>=[expr ($RL-0.2)] & z<=[expr ($RL+0.2)]" }
        { "yellow" "HIGH 0.2m - 0.4m" "z>=[expr ($RL+0.2)] & z<=[expr ($RL+0.4)]" }
        { "orange" "HIGH 0.4m - 0.6m" "z>=[expr ($RL+0.4)] & z<=[expr ($RL+0.6)]" }
        { "magenta" "HIGH 0.6m - 0.8m" "z>=[expr ($RL+0.6)] & z<=[expr ($RL+0.8)]" }
        { "light grey" "" "z>[expr ($RL+0.6)]" }
      }
      layer_name="current pit"
    }
  }
}]

# Recall design strings
set status [ SclFunction "RECALL ANY FILE" {
  file="$designPitSTR"
  mode="openInNewLayer"
}]

# Renumber design strings to string set in defaults
set status [ SclFunction "STRING RENUMBER RANGE" {
  frm00068={
    {
      old_str_range="1,32000"
      new_str_range="$backgroundSTR"
    }
  }
}]

# Clips strings below the target RL
set status [ SclFunction "CLIP BY PLANE" {
  frmTrimByElevation={
    {
      clippingPlane="Z"
      min_plane_value="$RL"
      max_plane_value="$RLMax"
      retain="Y"
      newlayerStorage="N"
      pureStringData="Y"
      anySpotHeight="N"
    }
  }
}]

# Backup
# set status [ SclFunction "CLIP BY PLANE" {
  # frmTrimByElevation={
    # {
      # clippingPlane="Z"
      # min_slider="600"
      # min_plane_value="$RL"
      # max_slider="1000"
      # max_plane_value="$RLMax"
      # retain="Y"
      # newlayerStorage="N"
      # pureStringData="Y"
      # anySpotHeight="N"
    # }
  # }
# }]

# Create plotting form (with drawing number etc)
