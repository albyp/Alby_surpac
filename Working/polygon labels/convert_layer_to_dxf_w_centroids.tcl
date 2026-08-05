######################################################################
#
# Macro Name    : convert_layer_to_dxf_w_centroids.tcl
#
# Version       : Surpac 7.2 (x64)
#
# Creation Date : Tue Aug 04 2026
#
# Author        : Alby Palmer
#
# Description   : Create DXF file from active layer. Geometry strings
#                 are written as polylines. Text labels are placed
#                 per segment using this priority:
#                   1. A manually digitised label point from the
#                      dedicated label string ($labelString) that
#                      falls inside the segment's polygon.
#                   2. If no manual label point falls inside the
#                      segment, an automatically computed "pole of
#                      inaccessibility" point (guaranteed interior,
#                      even for concave/wedge/crescent shapes), with
#                      the segment's own d3 attribute as label text.
#
######################################################################

set labelString 20




#
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

# ------------------------------------------------------------------
# procs - DXF writing
# ------------------------------------------------------------------

proc DXFTextFromPoint {writeFile strNum easting northing rl d1 pen} {
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
    puts $writeFile "$d1"
}

# Created by: Ash Colton from Dassault Systemes
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

proc DXFCloseFile {writeFile} {
  puts $writeFile "0"
  puts $writeFile "SEQEND"
  puts $writeFile "0"
  puts $writeFile "ENDSEC"
  puts $writeFile "0"
  puts $writeFile "EOF"
}

# ------------------------------------------------------------------
# procs - pole of inaccessibility (auto label placement fallback)
# ------------------------------------------------------------------

# Ray-casting point-in-polygon test
proc PointInPolygon {px py xs ys} {
    set n [llength $xs]
    set inside 0
    set j [expr {$n - 1}]
    for {set i 0} {$i < $n} {incr i} {
        set xi [lindex $xs $i]
        set yi [lindex $ys $i]
        set xj [lindex $xs $j]
        set yj [lindex $ys $j]
        if { (($yi > $py) != ($yj > $py)) &&
             ($px < ($xj - $xi) * ($py - $yi) / ($yj - $yi) + $xi) } {
            set inside [expr {!$inside}]
        }
        set j $i
    }
    return $inside
}

# Shortest distance from a point to a single line segment
proc PointSegDist {px py x1 y1 x2 y2} {
    set dx [expr {$x2 - $x1}]
    set dy [expr {$y2 - $y1}]
    if {$dx == 0 && $dy == 0} {
        return [expr {hypot($px - $x1, $py - $y1)}]
    }
    set t [expr {(($px - $x1) * $dx + ($py - $y1) * $dy) / ($dx*$dx + $dy*$dy)}]
    if {$t < 0} {set t 0}
    if {$t > 1} {set t 1}
    set cx [expr {$x1 + $t * $dx}]
    set cy [expr {$y1 + $t * $dy}]
    return [expr {hypot($px - $cx, $py - $cy)}]
}

# Shortest distance from a point to the polygon boundary (min over all edges)
proc DistToPolygonBoundary {px py xs ys} {
    set n [llength $xs]
    set minD 1e18
    set j [expr {$n - 1}]
    for {set i 0} {$i < $n} {incr i} {
        set d [PointSegDist $px $py \
                 [lindex $xs $j] [lindex $ys $j] \
                 [lindex $xs $i] [lindex $ys $i]]
        if {$d < $minD} {set minD $d}
        set j $i
    }
    return $minD
}

# Coarse-to-fine grid search for the point of maximum distance to the
# boundary, constrained to be inside the polygon. Returns {x y}.
proc PoleOfInaccessibility {xs ys {gridDivisions 20} {refinePasses 4}} {
    set xmin [lindex $xs 0]; set xmax $xmin
    set ymin [lindex $ys 0]; set ymax $ymin
    foreach x $xs {
        if {$x < $xmin} {set xmin $x}
        if {$x > $xmax} {set xmax $x}
    }
    foreach y $ys {
        if {$y < $ymin} {set ymin $y}
        if {$y > $ymax} {set ymax $y}
    }

    set cx [expr {($xmin + $xmax) / 2.0}]
    set cy [expr {($ymin + $ymax) / 2.0}]
    set halfW [expr {($xmax - $xmin) / 2.0}]
    set halfH [expr {($ymax - $ymin) / 2.0}]

    if {$halfW <= 0} {set halfW 1.0}
    if {$halfH <= 0} {set halfH 1.0}

    set bestX $cx
    set bestY $cy
    set bestD -1

    for {set pass 0} {$pass < $refinePasses} {incr pass} {
        set stepX [expr {(2.0 * $halfW) / $gridDivisions}]
        set stepY [expr {(2.0 * $halfH) / $gridDivisions}]
        set foundAny 0

        for {set i 0} {$i <= $gridDivisions} {incr i} {
            set px [expr {$cx - $halfW + $i * $stepX}]
            for {set j 0} {$j <= $gridDivisions} {incr j} {
                set py [expr {$cy - $halfH + $j * $stepY}]
                if {[PointInPolygon $px $py $xs $ys]} {
                    set d [DistToPolygonBoundary $px $py $xs $ys]
                    if {$d > $bestD} {
                        set bestD $d
                        set bestX $px
                        set bestY $py
                        set foundAny 1
                    }
                }
            }
        }

        if {!$foundAny && $bestD < 0} {
            return [list [lindex $xs 0] [lindex $ys 0]]
        }

        set cx $bestX
        set cy $bestY
        set halfW [expr {$halfW / 3.0}]
        set halfH [expr {$halfH / 3.0}]
    }

    return [list $bestX $bestY]
}

# ------------------------------------------------------------------
# pen setup
# ------------------------------------------------------------------

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
set pen(20) 0
set pen(109) 0
set pen(1599) 0

puts "Converting $layerName to DXF"

set layerNameWithoutExt [file rootname $layerName]
set fileName "$layerNameWithoutExt.dxf"
set writeFile [open "$fileName" "w"]

DXFHeaderLines $writeFile

$SwaHandle SclGetStrings StringsHandle

# ------------------------------------------------------------------
# Pass 1: collect manual label points from the dedicated label string
# ------------------------------------------------------------------

set labelPoints [list]

$StringsHandle SclIterateFirst StringsIterator
while {[$StringsIterator SclIterateNext StringHandle] == $SCL_TRUE} {
  set strNum [$StringHandle SclGetId]
  if {$strNum != $labelString} {
    continue
  }
  $StringHandle SclIterateFirst StringIterator
  while {[$StringIterator SclIterateNext SegmentHandle] == $SCL_TRUE} {
    $SegmentHandle SclIterateFirst SegmentIterator
    while {[$SegmentIterator SclIterateNext PointHandle] == $SCL_TRUE} {
      set lx  [$PointHandle SclGetValueByName x]
      set ly  [$PointHandle SclGetValueByName y]
      set lz  [$PointHandle SclGetValueByName z]
      set ld1 [$PointHandle SclGetValueByName d1]
      lappend labelPoints [list $lx $ly $lz $ld1]
    }
  }
}

# ------------------------------------------------------------------
# Pass 2: draw geometry strings, resolving one label per segment
# ------------------------------------------------------------------

$StringsHandle SclIterateFirst StringsIterator
while {[$StringsIterator SclIterateNext StringHandle] == $SCL_TRUE} {
  set strNum [$StringHandle SclGetId]

  # The label string itself carries no geometry to draw - skip it.
  if {$strNum == $labelString} {
    continue
  }

  $StringHandle SclIterateFirst StringIterator
  while {[$StringIterator SclIterateNext SegmentHandle] ==  $SCL_TRUE} {
    set segNum [$SegmentHandle SclGetId]
    $SegmentHandle SclIterateFirst SegmentIterator

    set segXs [list]
    set segYs [list]
    set segZs [list]
    set lastD3 ""

    set pointNum 1
    while {[$SegmentIterator SclIterateNext PointHandle] == $SCL_TRUE} {
      set x  [$PointHandle SclGetValueByName x]
      set y  [$PointHandle SclGetValueByName y]
      set z  [$PointHandle SclGetValueByName z]
      set lastD3 [$PointHandle SclGetValueByName d3]

      lappend segXs $x
      lappend segYs $y
      lappend segZs $z

      if {$pointNum == 1} {
        DXFLineFirstPoint $writeFile $strNum $x $y $z $pen($strNum)
        incr pointNum
        continue
      }
      DXFLineSubsequentPoints $writeFile $strNum $x $y $z
    }
    DXFLineEndSegment $writeFile

    # Try to find a manual label point that falls inside this segment
    set matched 0
    foreach lp $labelPoints {
      set lx  [lindex $lp 0]
      set ly  [lindex $lp 1]
      set lz  [lindex $lp 2]
      set ld1 [lindex $lp 3]
      if {[PointInPolygon $lx $ly $segXs $segYs]} {
        DXFTextFromPoint $writeFile $strNum $lx $ly $lz $ld1 $pen($strNum)
        set matched 1
        break
      }
    }

    # No manual label found inside this segment - fall back to an
    # automatically computed interior point, labelled with d3.
    if {!$matched} {
      set pole [PoleOfInaccessibility $segXs $segYs]
      set poleX [lindex $pole 0]
      set poleY [lindex $pole 1]
      set poleZ [lindex $segZs end]
      DXFTextFromPoint $writeFile $strNum $poleX $poleY $poleZ $lastD3 $pen($strNum)
    }
  }
}

DXFCloseFile $writeFile
close $writeFile

puts "Macro to convert string to DXF is complete."