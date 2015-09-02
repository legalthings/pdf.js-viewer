cp source/build/pdf.worker.js source/web/cmaps/ source/web/images/ source/web/locale/ . -a

cat source/web/l10n.js source/build/pdf.js source/build/pdf.worker.js source/web/compatibility.js source/web/debugger.js source/web/viewer.js > pdf.js

uglifycss source/web/viewer.css > viewer.css
node grunt/css-prefix.js viewer.css viewer.css pdfjs

