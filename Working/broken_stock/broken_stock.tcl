######################################################################
#
# Macro Name    : github/alby_surpac/working/broken stock/record.tcl
#
# Version       : Surpac 6.9 (x64)
#
# Creation Date : Mon May  4 14:13:47 2020
#
# Description   :
#
# Author        : Alby Palmer
#
######################################################################

puts "Macro running"

######################################################################
# Gui myForm
######################################################################
set myForm {
  GuidoForm myForm {
    -label "Broken stocks report"
    -default_buttons
    -defaults_key sectionsfile
    -layout BoxLayout Y_AXIS


  }
}

SclCreateGuidoForm myFormHandle $myForm {}

$myFormHandle SclRun {}
if {$_status == "cancel"} then {
  puts "Macro cancelled"
  return
}

######################################################################
# Defaults
######################################################################
