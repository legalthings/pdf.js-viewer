# PDF.js viewer

[PDF.js](https://mozilla.github.io/pdf.js/) is a Portable Document Format (PDF) library that is built with HTML5.

This is a build version of the PDF.js, including the viewer.

See https://github.com/legalthings/pdf.js-dist for learning and contributing.


## Installation

    bower install pdf.js-viewer

## Usage

```html
<html>
  <head>
    <title>PDF.js viewer</title>
    <script src="bower_components/pdf.js-viewer/pdf.js"></script>
    <link rel="stylesheet" href="bower_components/pdf.js-viewer/viewer.css">
    
    <style>
      html, body {
        height: 100%;
        width: 100%;
      }
    </style>
    
    <script>
      PDFJS.webViewerLoad('some-document.pdf');
    </script>
  </head>

  <body>
    <!--#include virtual="bower_components/pdf.js-viewer/viewer.html" --> 
  </body>
</html>
```

