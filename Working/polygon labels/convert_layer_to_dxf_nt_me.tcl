###########################################################################################
#
# Created by: Ash Colton from Dassault Systemes (Ph +61 8 9420 1384 or email ash.colton@3ds.com
#
# Description: Converts a string file into DXF.  Meant for closed polygons that have a description in the d2 field you want to see in the DXF
#
# History: Based on a macro by Gary Johnson (Alcoa) and converted into flexible, layer based conversion macro. Gaz did the reverse engineering on the DXF
#
# Modified 17/09/21 for CMM Survey Blast Boundary Files |Removed any use of green/ blue/red/ magenta to not be confused with ore|
#
###########################################################################################

SclGetActiveViewport ViewportHandle
$ViewportHandle SclGetActiveLayer SwaHandle
set layerName [$SwaHandle SclGetId]
set stringCount [$SwaHandle SclGetStrings strH]
set stringCount [$strH SclCountItems]
#puts $stringCount
if {$stringCount <= 0} {
  puts "No strings in active layer.  Bring in the file to convert to DXF and try again."
  return
}

proc DXFHeaderLines {writeFile} {
  puts $writeFile "0"
  puts $writeFile "SECTION"
  puts $writeFile "2"
  puts $writeFile "ENTITIES"
}

proc DXFLineFirstPoint {writeFile strNum easting northing rl pen} {
  puts $writeFile "0"
  puts $writeFile "POLYLINE"
  puts $writeFile "70"
  puts $writeFile "8"
  puts $writeFile "8"
  puts $writeFile "BDY_$strNum"
  puts $writeFile "62"
  puts $writeFile "$pen"
  puts $writeFile "66"
  puts $writeFile "1"
  puts $writeFile "0"
  puts $writeFile "VERTEX"
  puts $writeFile "70"
  puts $writeFile "32"
  puts $writeFile "8"
  puts $writeFile "BDY_$strNum"
  puts $writeFile "10"
  puts $writeFile "$easting"
  puts $writeFile "20"
  puts $writeFile "$northing"
  puts $writeFile "30"
  puts $writeFile "$rl"
}

proc DXFLineSubsequentPoints {writeFile strNum easting northing rl} {
  puts $writeFile "0"
  puts $writeFile "VERTEX"
  puts $writeFile "70"
  puts $writeFile "32"
  puts $writeFile "8"
  puts $writeFile "BDY_$strNum"
  puts $writeFile "10"
  puts $writeFile "$easting"
  puts $writeFile "20"
  puts $writeFile "$northing"
  puts $writeFile "30"
  puts $writeFile "$rl"
}

proc DXFLineEndSegment {writeFile} {
  puts $writeFile "0"
  puts $writeFile "SEQEND"
  puts $writeFile "8"
  puts $writeFile "CMM"
}

proc DXFText {writeFile strNum easting northing rl d2 pen} {
  puts $writeFile "0"
  puts $writeFile "TEXT"
  puts $writeFile "8";# DXF code for layer name
  puts $writeFile "Text_$strNum";# Actual layer name
  puts $writeFile "62";# DXF code for Pen Number or Line Colour
  puts $writeFile "$pen";# Actual pen number
  puts $writeFile "10";# DXF code for Easting
  puts $writeFile "$easting";# Actual Easting
  puts $writeFile "20";# DXF code for Northing
  puts $writeFile "$northing";# Actual Northing
  puts $writeFile "30";# DXF code for Elevation
  puts $writeFile "$rl";# Actual Elevation
  puts $writeFile "40";# DXF code for Text Height
  puts $writeFile "2.0";# Actual text height. Note WRU 0.02 is 2 and 0.3 is 30
  puts $writeFile "50";# DXF code for slope of the text. Note 0 is 90 degrees, 90 is south to north, 180 is upside down right to left
  puts $writeFile "25";# Actual slope of text
  puts $writeFile "1";# DXF code for labelling the point
  puts $writeFile "$d2"
}

proc DXFCloseFile {writeFile} {
  puts $writeFile "0"
  puts $writeFile "SEQEND"
  puts $writeFile "0"
  puts $writeFile "ENDSEC"
  puts $writeFile "0"
  puts $writeFile "EOF"
}

set colourList [list "Black" "Red" "Yellow" "Green" "Cyan" "Blue" "Magenta" "Brown" "Greeny Brown" "Navy Blue" "Dark Green" "Sea Green" "Purple" "Grey"]
set penList [list       0      1      2        3      4      5        6        32          52           62          102          120      213      254]

#Set more pen numbers below based on the string number.  List of pens and their colours above
set pen(1) 0
set pen(2) 0
set pen(3) 0
set pen(4) 0
set pen(5) 0
set pen(6) 0
set pen(7) 0
set pen(8) 0
set pen(1599) 0

puts "Converting $layerName to DXF"

set layerNameWithoutExt [file rootname $layerName]
set fileName "$layerNameWithoutExt.dxf"
set writeFile [open "$fileName" "w"]

DXFHeaderLines $writeFile

$SwaHandle SclGetStrings StringsHandle
$StringsHandle SclIterateFirst StringsIterator
while {[$StringsIterator SclIterateNext StringHandle] == $SCL_TRUE} {
  set strNum [$StringHandle SclGetId]
  $StringHandle SclIterateFirst StringIterator
  while {[$StringIterator SclIterateNext SegmentHandle] ==  $SCL_TRUE} {
    set segNum [$SegmentHandle SclGetId]
    $SegmentHandle SclIterateFirst SegmentIterator
    set xmin [$SegmentHandle SclGetValueByName xmin]
    set xmax [$SegmentHandle SclGetValueByName xmax]
    set ymin [$SegmentHandle SclGetValueByName ymin]
    set ymax [$SegmentHandle SclGetValueByName ymax]
    set zmin [$SegmentHandle SclGetValueByName zmin]
    set zmax [$SegmentHandle SclGetValueByName zmax]
    set xCentroid [SclExpr ($xmin+$xmax)/2]
    set yCentroid [SclExpr ($ymin+$ymax)/2]
    set zCentroid [SclExpr ($zmin+$zmax)/2]
    set pointNum 1
    while {[$SegmentIterator SclIterateNext PointHandle] == $SCL_TRUE} {
      set x [$PointHandle SclGetValueByName x]
      set y [$PointHandle SclGetValueByName y]
      set z [$PointHandle SclGetValueByName z]
      set d2 [$PointHandle SclGetValueByName d2]
      if {$pointNum == 1} {
        DXFLineFirstPoint $writeFile $strNum $x $y $z $pen($strNum)
        incr pointNum
        continue
      }
      DXFLineSubsequentPoints $writeFile $strNum $x $y $z
    }
    DXFLineEndSegment $writeFile
    DXFText $writeFile $strNum $xCentroid $yCentroid $zCentroid $d2 $pen($strNum)
  }
}

DXFCloseFile $writeFile
close $writeFile

puts "Macro to convert string to DXF is complete."









































