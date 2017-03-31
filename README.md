# PDF.js viewer

[PDF.js](https://mozilla.github.io/pdf.js/) is a Portable Document Format (PDF) library that is built with HTML5.

This is a build version of the PDF.js, including the viewer.


## Installation

    bower install pdf.js-viewer

## Usage

Include `viewer.html` using [SSI](http://httpd.apache.org/docs/2.4/howto/ssi.html) or your favorite templating system.

```html
<html>
  <head>
    <title>PDF.js viewer</title>
    <script src="bower_components/pdf.js-viewer/pdf.js"></script>
    <link rel="stylesheet" href="bower_components/pdf.js-viewer/viewer.css">
    
    <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
    </style>
  </head>

  <body>
    <div class="pdfjs">
      <!--#include virtual="bower_components/pdf.js-viewer/viewer.html" --> 
    </div>

    <script>
      // note that the file can also be a Uint8Array if you want to serve binary data
      var file = 'some-document.pdf'; 

      // This initializes the webviewer, the file may be passed in to it to initialize the viewer with a pdf directly
      window.PDFJS.webViewerLoad(); 

      // open a file in the viewer
      window.PDFViewerApplication.open(file);
    </script>
  </body>
</html>
```

## Upgrading the source

Normally mozilla's PDF js viewer, will only run as standalone. We forked the project and patched it, so you can include it
within a page.

To update this version, get the patched pdf.js source code and build the project

    git clone https://github.com/legalthings/pdf.js.git
    cd pdf.js
    npm install
    gulp generic
    cd ..

And update the files from source and patch them

    cd pdf.js-viewer
    npm install
    ./build.sh ../pdf.js/build/generic/
