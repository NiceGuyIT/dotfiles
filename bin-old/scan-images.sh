#!/usr/bin/env bash


# Run gmic with the given arguments
run_gmic() {
	local fbase="${f%.*}"
	local fext="${f##*.}"
	local arg="${garg// /}"
	echo
	echo gmic -input "${f}" "${gcmd}" "${arg}" -output "${fbase}-${gext}.${fext}"
	gmic -input "${f}" "${gcmd}" "${arg}" -output "${fbase}-${gext}.${fext}"
	f="${fbase}-${gext}.${fext}"
}

# Run magick with the given arguments
run_magick() {
	local fbase="${f%.*}"
	local fext="${f##*.}"
	local arg="${garg// /}"
	echo
	echo magick "${f}" "${gcmd}" ${garg} "${fbase}-${gext}.${fext}"
	magick "${f}" "${gcmd}" ${garg} "${fbase}-${gext}.${fext}"
	f="${fbase}-${gext}.${fext}"
}

# Run Noteshrink with the given arguments
run_noteshrink() {
	local fbase="${f%.*}"
	local fext="${f##*.}"
	local arg="${garg// /}"
	echo
	echo noteshrink -verbose -debug ${garg} "${f}"
	~/projects/noteshrink/noteshrink/noteshrink -verbose ${garg} "${f}"
	# Noteshrink uses it's own output filename
	mv "${fbase}-shrunk.${fext}" "${fbase}-${gext}.${fext}"
	f="${fbase}-${gext}.${fext}"
}

# digiKam uses exiv2 to read metadata and exiv2 does not read tEXt (used by ImageMagic) from PNG files.
# See https://github.com/Exiv2/exiv2/issues/1343
fix_metadata() {
	local fbase="${f%.*}"

	# Extract tags
	exiftool -overwrite_original -tagsfromfile "${f}" "${f}.xmp"

	# DigiKam stores the information in base.png.xmp while exiv2 wants the filename base.xmp
	[[ -f "${fbase}.png.xmp" ]] && mv "${fbase}.png.xmp" "${fbase}.xmp"

	# Insert the EXIF tags
	exiv2 --insert X "${f}"

    # Add the resolution if not available.
    # Assume 600 dots per inch / 23622 dots per meter
    if ! exiv2 -pX "${f}" | grep -q 'tiff:ResolutionUnit'
    then
        # This doesn't update the xmp file
        exiv2 -M"set Xmp.tiff.ResolutionUnit 3" -M"set Xmp.tiff.XResolution 11811/50" -M"set Xmp.tiff.YResolution 11811/50" "${f}"
        # so we use exiftool to update it
        exiftool -overwrite_original -tagsfromfile "${f}" "${fbase}.xmp"
        # and then insert back into the png
        exiv2 --insert X "${f}"
    fi

	# The XMP file is not needed because we didn't add anything new
	[[ -f "${f}.xmp" ]] && rm "${f}.xmp"
	[[ -f "${fbase}.xmp" ]] && rm "${fbase}.xmp"

}



# Boost Screen
boostscreenreceipts() {
	local fbase="${f%.*}"
	local fext="${f##*.}"
	[[ -z "$arg" ]] && arg="0.5, 0, 0.5"
	local larg="${arg// /}"
	arg=""
	echo
	echo gmic -input "${f}" fx_compose_boostscreen "${larg}" -output "${fbase}-boostscreen.${fext}"
	gmic -input "${f}" fx_compose_boostscreen "${larg}" -output "${fbase}-boostscreen.${fext}"
	f="${fbase}-boostscreen.${fext}"
}

# Smooth Mean Curvature
smoothmeancurvature() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  # Another possibility is to use 4 iterations
  # fx_smooth_meancurvature 30,4,0,0,0,24,0,50,50
  echo gmic -input "${f}" fx_smooth_meancurvature 30,10,0,0,0,24,0,50,50 -output "${fbase}-smc.${fext}"
  gmic -input "${f}" fx_smooth_meancurvature 30,10,0,0,0,24,0,50,50 -output "${fbase}-smc.${fext}"
  f="${fbase}-smc.${fext}"
}

# Smooth Mean Curvature for receipts
smoothmeancurvaturereceipts() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo gmic -input "${f}" fx_smooth_meancurvature 30,4,0,0,0,24,0,50,50 -output "${fbase}-smc.${fext}"
  gmic -input "${f}" fx_smooth_meancurvature 30,4,0,0,0,24,0,50,50 -output "${fbase}-smc.${fext}"
  f="${fbase}-smc.${fext}"
}

# Smooth Median
smoothmedian() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo gmic -input "${f}" fx_smooth_median 7,255,0,4,50,50 -output "${fbase}-smoothmedian.${fext}"
  gmic -input "${f}" fx_smooth_median 7,255,0,4,50,50 -output "${fbase}-smoothmedian.${fext}"
  f="${fbase}-smoothmedian.${fext}"
}

# Anti-alias
antialias() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo gmic -input "${f}" gcd_anti_alias 200,0.4,255,4 -output "${fbase}-antialias.${fext}"
  gmic -input "${f}" gcd_anti_alias 200,0.4,255,4 -output "${fbase}-antialias.${fext}"
  f="${fbase}-antialias.${fext}"
}

# Sharpen tones
sharpentones() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo gmic -input "${f}" gcd_sharpen_tones 1,128,0,4 -output "${fbase}-sharpentones.${fext}"
  gmic -input "${f}" gcd_sharpen_tones 1,128,0,4 -output "${fbase}-sharpentones.${fext}"
  f="${fbase}-sharpentones.${fext}"
}

# Moire removal
moireremoval() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo gmic -input "${f}" iain_moire_removal 5,5,2 -output "${fbase}-moire.${fext}"
  gmic -input "${f}" iain_moire_removal 5,5,2 -output "${fbase}-moire.${fext}"
  f="${fbase}-moire.${fext}"
}

# Noteshrink; 8 colors
noteshrink8() {
  #f="${1}"
  local fbase="${f%.*}"
  local fext="${f##*.}"
  echo
  echo ./noteshrink -verbose -debug -colors 8 "${f}"
  ~/projects/noteshrink/noteshrink/noteshrink -verbose -debug -colors 8 "${f}"
  # Noteshrink uses it's own output filename
  mv "${fbase}-shrunk.${fext}" "${fbase}-shrunk8.${fext}"
  f="${fbase}-shrunk8.${fext}"
}

# Noteshrink; 4 colors
noteshrink4() {
	#f="${1}"
	local fbase="${f%.*}"
	local fext="${f##*.}"
	echo
	echo ./noteshrink -verbose -debug -colors 4 "${f}"
	~/projects/noteshrink/noteshrink/noteshrink -verbose -debug -colors 4 "${f}"
	# Noteshrink uses it's own output filename
	mv "${fbase}-shrunk.${fext}" "${fbase}-shrunk4.${fext}"
	f="${fbase}-shrunk4.${fext}"
}

# Noteshrink; Screened letter
noteshrinkscreenedletter() {
	#f="${1}"
	local fbase="${f%.*}"
	local fext="${f##*.}"
	echo
	echo ~/projects/noteshrink/noteshrink/noteshrink -verbose -brightness-threshold 0.05 -saturation-threshold 0.10 -colors 4 "${f}"
	~/projects/noteshrink/noteshrink/noteshrink -verbose -brightness-threshold 0.05 -saturation-threshold 0.10 -colors 4 "${f}"
	# Noteshrink uses it's own output filename
	mv "${fbase}-shrunk.${fext}" "${fbase}-shrinkscreenedletter.${fext}"
	f="${fbase}-shrinkscreenedletter.${fext}"
}

# Noteshrink; Screened letter
noteshrinkscreenedcolor() {
	#f="${1}"
	local fbase="${f%.*}"
	local fext="${f##*.}"
	echo
	echo ~/projects/noteshrink/noteshrink/noteshrink -verbose -brightness-threshold 0.10 -saturation-threshold 0.15 -colors 16 "${f}"
	~/projects/noteshrink/noteshrink/noteshrink -verbose -brightness-threshold 0.10 -saturation-threshold 0.15 -colors 16 "${f}"
	# Noteshrink uses it's own output filename
	mv "${fbase}-shrunk.${fext}" "${fbase}-shrinkscreenedletter.${fext}"
	f="${fbase}-shrinkscreenedletter.${fext}"
}

# Safe remove
remove() {
	# [[ ]] only checks if the variable is empty.
	"${keep}" && return
	[[ -f "${1}" ]] && rm "${1}"
}

# Screened text with color, mainly from credit reports
screened() {

	# gmic fx_LCE 80,0.75,1,1,0,11
	garg="80,0.75,1,1,7,11"
	gcmd="fx_LCE"
	gext="lce"
	run_gmic
	old="$f"

	# gmic fx_compose_boostscreen 0.7,0,0.7
	garg="0.7,0,0.7"
	gcmd="fx_compose_boostscreen"
	gext="boostscreen"
	run_gmic
	remove "$old"
	old="$f"

	# gmic gcd_anti_alias 200,0.4,255,4
	garg="200,0.4,255,11"
	gcmd="gcd_anti_alias"
	gext="antialias"
	run_gmic
	remove "$old"
	old="$f"

	# noteshrink -brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 16
	garg="-brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 16"
	gcmd=""
	gext="noteshrink"
	run_noteshrink
	remove "$old"
	old="$f"

	# gmic gcd_despeckle 5,10
	garg="5,10"
	gcmd="gcd_despeckle"
	gext="despeckle"
	run_gmic
	remove "$old"
	old="$f"

	# magic -colors 16
	garg="16"
	gcmd="-colors"
	gext="colors16"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"

}

# Screened text with color. Not as good as screened above
screenedcolor() {

	# magic -contrast-stretch 0.2x0.5%
	garg="0.2x0.5%"
	gcmd="-contrast-stretch"
	gext="contraststretch"
	run_magick
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_compose_vividscreen 0.6,0,0.7
	garg="0.6,0,0.7"
	gcmd="fx_compose_vividscreen"
	gext="vividscreen"
	run_gmic
	remove "$old"
	old="$f"

	# magic -contrast-stretch 0.2x5%
	garg="0.2x5%"
	gcmd="-contrast-stretch"
	gext="contraststretch"
	run_magick
	remove "$old"
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old"
	old="$f"

	noteshrinkscreenedcolor
	remove "$old"
	old="$f"

	# magic -colors 16
	garg="16"
	gcmd="-colors"
	gext="colors16"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"

}

# Good for documents signed in blue ink
blueink() {

	# Remove the black edges
	# magic -shave 1%x0.5%
	garg="1%x0.5%"
	gcmd="-shave"
	gext="shave"
	run_magick
	remove "$old"
	old="$f"

	# magic -deskew 40%
	garg="40%"
	gcmd="-deskew"
	gext="deskew"
	run_magick
	remove "$old"
	old="$f"

	# gmic fx_sharp_abstract 2,10,0.5,0,11,50,50
	garg="2,10,0.5,0,11,50,50"
	gcmd="fx_sharp_abstract"
	gext="sharpabstract"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_compose_boostscreen 0.7,0,0.7
	garg="0.7,0,0.7"
	gcmd="fx_compose_boostscreen"
	gext="boostscreen"
	run_gmic
	remove "$old"
	old="$f"

	# gmic iain_constrained_sharpen 1,3,10,5,0,11,2
	garg="1,3,10,5,0,11,2"
	gcmd="iain_constrained_sharpen"
	gext="constrainedsharpen"
	run_gmic
	remove "$old"
	old="$f"

	# magic -colors 8
	garg="8"
	gcmd="-colors"
	gext="colors8"
	run_magick
	remove "$old"
	old="$f"

	# noteshrink -brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 8
	# FIXME: Sometimes the blue ink will be removed leaving traces of other colors
	#garg="-brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 8"
	#gcmd=""
	#gext="noteshrink"
	#run_noteshrink
	#remove "$old"
	#old="$f"

	# gmic changes the density (resolution) for some reason
	# magic -density -density 236.22x236.22 -units PixelsPerCentimeter
	garg="236.22x236.22 -units PixelsPerCentimeter"
	gcmd="-density"
	gext="resolution"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"

}

# Good for documents signed in blue ink
monochrome() {

	# gmic fx_sharp_abstract 2,10,0.5,0,11,50,50
	garg="2,10,0.5,0,11,50,50"
	gcmd="fx_sharp_abstract"
	gext="sharpabstract"
	run_gmic
	old="$f"

	# magic -colorspace Gray
	garg="Gray"
	gcmd="-colorspace"
	gext="grayscale"
	run_magick
	remove "$old"
	old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	#garg="30,4,0,0,0,24,11,50,50"
	#gcmd="fx_smooth_meancurvature"
	#gext="smoothmeancurvature"
	#run_gmic
	#remove "$old"
	#old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	#garg="10,7,2,0,11,50,50"
	#gcmd="fx_smooth_bilateral"
	#gext="smoothbilateral"
	#run_gmic
	#remove "$old"
	#old="$f"

	# gmic fx_compose_boostscreen 0.7,0,0.7
	#garg="0.7,0,0.7"
	#gcmd="fx_compose_boostscreen"
	#gext="boostscreen"
	#run_gmic
	#remove "$old"
	#old="$f"

	# gmic iain_constrained_sharpen 1,3,10,5,0,11,2
	#garg="1,3,10,5,0,11,2"
	#gcmd="iain_constrained_sharpen"
	#gext="constrainedsharpen"
	#run_gmic
	#remove "$old"
	#old="$f"

	# noteshrink -brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 4
	#garg="-brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 4"
	#gcmd=""
	#gext="noteshrink"
	#run_noteshrink
	#remove "$old"
	#old="$f"

	# gmic fx_LCE 100,0.5,1,1,0,11
	garg="100,0.5,1,1,7,11"
	gcmd="fx_LCE"
	gext="lce"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_compose_vividscreen 0.6,0,0.7
	garg="0.6,0,0.7"
	gcmd="fx_compose_vividscreen"
	gext="vividscreen"
	run_gmic
	remove "$old"
	old="$f"

	# noteshrink -brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 4
	garg="-brightness-threshold 0.20 -saturation-threshold 0.05 -sample-fraction 0.15 -colors 4"
	gcmd=""
	gext="noteshrink"
	run_noteshrink
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"


	# magic -clahe -25x25%+128+3
	#garg="25x25%+128+3"
	#gcmd="-clahe"
	#gext="clahe"
	#run_magick
	#old="$f"

	# gmic fx_smooth_abstract 75,0,20,1,30,11,50,50
	#garg="75,0,20,1,30,11,50,50"
	#gcmd="fx_smooth_abstract"
	#gext="smoothabstract"
	#run_gmic
	#remove "$old"
	#old="$f"

}

# Letters with screened boxes
screenedletter() {

	# magic -contrast-stretch 0.2x0.5%
	garg="0.2x0.5%"
	gcmd="-contrast-stretch"
	gext="contraststretch"
	run_magick
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	remove "$old"
	old="$f"

	# magic -colorspace Gray
	garg="Gray"
	gcmd="-colorspace"
	gext="grayscale"
	run_magick
	remove "$old"
	old="$f"

	# gmic fx_compose_vividscreen 0.6,0,0.7
	garg="0.6,0,0.7"
	gcmd="fx_compose_vividscreen"
	gext="vividscreen"
	run_gmic
	remove "$old"
	old="$f"

	# magic -contrast-stretch 0.2x5%
	garg="0.2x5%"
	gcmd="-contrast-stretch"
	gext="contraststretch"
	run_magick
	remove "$old"
	old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_sharp_abstract 4,10,0.5,0,11,50,50
	#garg="4,10,0.5,0,11,50,50"
	garg="4,3,0.5,0,11,50,50"
	gcmd="fx_sharp_abstract"
	gext="sharpabstract"
	run_gmic
	remove "$old"
	old="$f"

	noteshrinkscreenedletter
	remove "$old"
	old="$f"

	# magic -colors 16
	garg="16"
	gcmd="-colors"
	gext="colors16"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"

	return


	# gmic iain_constrained_sharpen 0.75,3,10,10,0,11,2
	garg="0.75,3,10,10,0,11,2"
	gcmd="iain_constrained_sharpen"
	gext="constrainedsharpen"
	run_gmic
	remove "$old"
	old="$f"

	# gmic iain_constrained_sharpen 0.75,3,10,10,0,11,2
	#garg="0.75,3,10,10,0,11,2"
	#gcmd="iain_constrained_sharpen"
	#gext="constrainedsharpen"
	#run_gmic
	remove "$old"
	#old="$f"

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_blackandwhite 0.25,0,0.25,0,0.25,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,11,50,50
	#garg="0.25,0,0.25,0,0.25,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,11,50,50"
	#gcmd="fx_blackandwhite"
	#gext="blackandwhite"
	#run_gmic
	remove "$old"
	#old="$f"

	# gmic iain_constrained_sharpen 1,3,10,5,0,11,2
	garg="1,3,10,5,0,11,2"
	gcmd="iain_constrained_sharpen"
	gext="constrainedsharpen"
	run_gmic
	remove "$old"
	old="$f"

	# gmic gcd_despeckle 5,10
	#garg="5,10"
	#gcmd="gcd_despeckle"
	#gext="despeckle"
	#run_gmic
	remove "$old"
	#old="$f"

	# gmic gcd_anti_alias 60,0.3,50,11
	#garg="60,0.3,50,11"
	#gcmd="gcd_anti_alias"
	#gext="antialias"
	#run_gmic
	remove "$old"
	#old="$f"

	# gmic fx_sharp_abstract 4,10,0.5,0,11,50,50
	#garg="4,10,0.5,0,11,50,50"
	garg="4,3,0.5,0,11,50,50"
	gcmd="fx_sharp_abstract"
	gext="sharpabstract"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old"
	old="$f"

	# gmic fx_compose_boostscreen 0.7,0,0.7
	#garg="0.7,0,0.7"
	#gcmd="fx_compose_boostscreen"
	#gext="boostscreen"
	#run_gmic
	#remove "$old
	#old="$f"

	noteshrinkscreenedletter
	remove "$old"
	old="$f"

	# magic -colors 4
	garg="4"
	gcmd="-colors"
	gext="colors4"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"
}

# Letters with color
colorletter() {

	# Use this
	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	# gmic fx_sharp_abstract 4,10,0.5,0,11,50,50
	# gmic fx_compose_boostscreen 0.7,0,0.7

	# gmic fx_smooth_meancurvature 30,4,0,0,0,24,11,50,50
	garg="30,4,0,0,0,24,11,50,50"
	gcmd="fx_smooth_meancurvature"
	gext="smoothmeancurvature"
	run_gmic
	old="$f"

	# gmic fx_sharp_abstract 4,10,0.5,0,11,50,50
	garg="4,10,0.5,0,11,50,50"
	gcmd="fx_sharp_abstract"
	gext="sharpabstract"
	run_gmic
	remove "$old" && old="$f"

	# gmic fx_compose_boostscreen 0.7,0,0.7
	garg="0.7,0,0.7"
	gcmd="fx_compose_boostscreen"
	gext="boostscreen"
	run_gmic
	remove "$old" && old="$f"

	noteshrink4
	remove "$old" && old="$f"

	# magic -colors 4
	garg="4"
	gcmd="-colors"
	gext="colors4"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"
}

# Receipts
receipts() {

	# Other tests
	# gmic afre_contrastfft 30,50,1
	# gmic fx_retrofade 20,6,40,0,50,50
	# gmic fx_charcoal 6,70,170,0,1,0,50,70,255,255,255,0,0,0,0,0,50,50
	# gmic fx_sharp_abstract 3,6,0.5,0,11,50,50
	# gmic fx_sharp_abstract 4,10,0.5,0,0,50,50
	# gmic iain_constrained_sharpen 10,10,0,10,0,7,1

	# Use this
	# gmic fx_LCE 100,2,1,1,7,11
	# gmic fx_smooth_bilateral 10,7,2,0,0,50,50
	# gmic fx_stamp 1,50,0.5,0,0,0,1,11,50,50
	# gmic -input "${f}" gcd_despeckle 5,10 -output "${fbase}-despeckle.${fext}"

	# gmic fx_LCE 100,2,1,1,7,11
	garg="100,2,1,1,7,11"
	gcmd="fx_LCE"
	gext="lce"
	run_gmic
	old="$f"

	# gmic fx_smooth_bilateral 10,7,2,0,0,50,50
	garg="10,7,2,0,0,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	remove "$old" && old="$f"

	# gmic fx_stamp 1,50,0.5,0,0,0,1,11,50,50
	garg="1,50,0.5,0,0,0,1,11,50,50"
	gcmd="fx_stamp"
	gext="stamp"
	run_gmic
	remove "$old" && old="$f"

	# gmic gcd_despeckle 5,10
	garg="5,10"
	gcmd="gcd_despeckle"
	gext="despeckle"
	run_gmic
	remove "$old" && old="$f"

	noteshrink4
	remove "$old" && old="$f"

	# magic -colors 4
	garg="4"
	gcmd="-colors"
	gext="colors4"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"
}

# Check Stubs
checkstubs() {

	# Other tests
	# gmic afre_contrastfft 30,50,1
	# gmic fx_retrofade 20,6,40,0,50,50
	# gmic fx_charcoal 6,70,170,0,1,0,50,70,255,255,255,0,0,0,0,0,50,50
	# gmic fx_sharp_abstract 3,6,0.5,0,11,50,50
	# gmic fx_sharp_abstract 4,10,0.5,0,0,50,50
	# gmic iain_constrained_sharpen 10,10,0,10,0,7,1

	# Use this
	# gmic fx_LCE 100,2,1,1,7,11
	noteshrink gmic fx_smooth_bilateral 10,7,2,0,0,50,50
	# gmic fx_stamp 1,50,0.5,0,0,0,1,11,50,50
	# gmic -input "${f}" gcd_despeckle 5,10 -output "${fbase}-despeckle.${fext}"

	# gmic fx_smooth_bilateral 10,7,2,0,11,50,50
	garg="10,7,2,0,11,50,50"
	gcmd="fx_smooth_bilateral"
	gext="smoothbilateral"
	run_gmic
	old="$f"

	# gmic gcd_despeckle 5,10
	garg="5,10"
	gcmd="gcd_despeckle"
	gext="despeckle"
	run_gmic
	remove "$old" && old="$f"

	# gmic fx_stamp 1,50,0.5,0,0,0,1,11,50,50
	garg="1,50,0.5,0,0,0,1,11,50,50"
	gcmd="fx_stamp"
	gext="stamp"
	run_gmic
	remove "$old" && old="$f"

	noteshrink4
	remove "$old" && old="$f"

	# magic -colors 4
	garg="4"
	gcmd="-colors"
	gext="colors4"
	run_magick
	remove "$old"
	old="$f"

	fbase="${orig%.*}"
	fext="${orig##*.}"
	mv "${f}" "${fbase}-${action}.${fext}"
	f="${fbase}-${action}.${fext}"
}

# Process all images in the directory
input="${HOME}/NiceGuyIT/imaging-processing/scanned"
output="${HOME}/NiceGuyIT/imaging-processing/processed"
processing="${HOME}/image-processing"
keep=false
# Old is used in the action functions
old=""
for action in receipts checkstubs colorletter screenedletter screenedcolor blueink monochrome screened; do
	# Make sure all directories exist
	[[ ! -d "${input}/${action}" ]] && echo "Creating directory ${input}/${action}" && mkdir --parents "${input}/${action}"
	[[ ! -d "${output}/${action}" ]] && echo "Creating directory ${output}/${action}" && mkdir --parents "${output}/${action}"
	[[ ! -d "${processing}/${action}" ]] && echo "Creating directory ${processing}/${action}" && mkdir --parents "${procesing}/${action}"

	cd "${input}/${action}/" || continue

	for f in Scan-*[0-9][0-9][0-9][0-9][0-9][0-9].png; do
		[[ ! -f "${f}" ]] && echo "Nothing to process for ${action}" && continue

		echo "Processing ${f} for ${action}"
		echo cp -p "${f}" "${processing}/${action}/"
		cp -p "${f}" "${processing}/${action}/"
		orig="${f}"

		cd "${processing}/${action}/" || continue
		echo "${action}"
		"${action}"

		# Fix the metaedata
		fix_metadata

		echo mv "${orig}" "${output}/${action}"
		mv "${orig}" "${output}/${action}"
		echo mv "${f}" "${output}/${action}"
		mv "${f}" "${output}/${action}"

		# Move back to the action directory to process more files
		cd "${input}/${action}/" || continue

		# Remove the original file
		remove "${orig}"

	done
done
