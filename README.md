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
      PDFJS.webViewerLoad('some-document.pdf');
    </script>
  </body>
</html>
```

