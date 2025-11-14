#!/usr/bin/env bash

# digiKam uses exiv2 to read metadata and exiv2 does not read tEXt (used by ImageMagic) from PNG files.
# See https://github.com/Exiv2/exiv2/issues/1343

# for png in *.png; do echo "===== $png ====="; exiftool -image:all -short -groupNames $png; done | less

#for png in *.png
#do
#	echo "===== ${png} ====="
#	# Gather metadata
#	exiftool -All -short -groupNames "${png}" > "${png}.txt"
#done
#exit


for png in $*
do
	echo "===== ${png} ====="
	base="${png%.*}"

	# Extract tags
	exiftool -overwrite_original -tagsfromfile "${png}" "${png}.xmp"

	# DigiKam stores the information in base.png.xmp while exiv2 wants the filename base.xmp
	[[ -f "${base}.png.xmp" ]] && mv "${base}.png.xmp" "${base}.xmp"

	# Insert the EXIF tags
	exiv2 --insert X "${png}"

	# Add the resolution if not available.
	# Assume 600 dots per inch / 23622 dots per meter
	if ! exiv2 -pX "${png}" | grep -q 'tiff:ResolutionUnit'
	then
		# This doesn't update the xmp file
		exiv2 -M"set Xmp.tiff.ResolutionUnit 3" -M"set Xmp.tiff.XResolution 11811/50" -M"set Xmp.tiff.YResolution 11811/50" "${png}"
		# so we use exiftool to update it
		exiftool -overwrite_original -tagsfromfile "${png}" "${base}.xmp"
		# and then insert back into the png
		exiv2 --insert X "${png}"
	fi

	[[ -f "${base}.xmp" ]] && mv "${base}.xmp" "${base}.png.xmp"

done

