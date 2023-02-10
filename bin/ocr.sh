#!/usr/bin/env bash

##
## It's expected the argument is the basename so that ${base}*.png is converted into ${base}.pdf.
##

# Input needs to be on separate lines. echo uses same line while ls doesn't
echo ls -1 ${@%-}-*.png \| tesseract - ${@%-} -l eng pdf
ls -1 ${@%-}-*.png | tesseract - ${@%-} -l eng pdf

exit

# Another version
for file in "$@"
do
    base="${file%.*}"
    pdf="${file%.*}.pdf"
    html="${file%.*}.html"
    echo $base
    tesseract "$file" "$base" -l eng hocr
    cat >> $html << EOT
</!DOCTYPE>
</?xml>
EOT
    hocr2pdf -i "$file" -o "$pdf" < "$html"
done

