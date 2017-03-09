#!/bin/bash

if [[ $# < 1 ]]; then
  echo USAGE $0 SOURCE_PATH 1>&2
  exit 1
fi

source="$1"

if [[ ! -f "$source/build/pdf.js" ]]; then
  echo "$source/build/pdf.js" not found 1>&2
  exit 1
fi

cat "$source/web/l10n.js" "$source/build/pdf.js" "$source/web/debugger.js" "$source/web/viewer.js" > pdf.js
patch -u pdf.js < pdf.js.patch

cp "$source/build/pdf.worker.js" .
#patch pdf.worker.js < pdf.worker.js.patch

cat "$source/web/viewer.html" | tr '\n' '\f' | sed -r 's/^.+<body [^>]*>/<pdfjs-wrapper>/' | sed -r 's/<\/body>.+$/<\/pdfjs-wrapper>/' | tr '\f' '\n' > ./viewer.html

uglifycss "$source/web/viewer.css" > viewer.css
node grunt/css-prefix.js viewer.css viewer.css pdfjs

sed -r 's/url\((")?images\//url\(\1@pdfjsImagePath\//g' < "$source/web/viewer.css" | uglifycss > viewer.less
node grunt/css-prefix.js viewer.less viewer.less pdfjs

cp "$source/web/cmaps/" "$source/web/images/" "$source/web/locale/" . -a

