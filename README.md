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

## Upgrading the source

Normally mozilla's PDF js viewer, will only run as standalone. This version is patched so you can include it within a
page.

To update this version, get the pdf.js source code and build the project

    git clone https://github.com/mozilla/pdf.js.git
    cd pdf.js
    npm install
    node make generic
    cd ..

And update the files from source and patch them

    cd pdf.js-viewer
    npm install
    ./build.sh ../pdf.js/build/generic/

### Manual patching

When updating to a new minor (or major) version, it's likely than one or more of the chunks can't be applied. This
means you need to do these modifications manually.


#### function getL10nData()

The viewer uses `l10n.js` with a `<link rel="resource" type="application/l10n">` header for internationalization. This
chunk makes using that optional.

       function getL10nData(key, args, fallback) {
         var data = gL10nData[key];
         if (!data) {
    -      console.warn('#' + key + ' is undefined.');
    +      if (Object.keys(gL10nData).length > 0) {
    +        console.warn('#' + key + ' is undefined.');
    +      }
           if (!fallback) {
             return null;
           }

#### Dynamic paths

The viewer uses relative paths to JavaScript files. This doesn't work when the viewer is embedded on a web page.
Instead the paths are determined based on the path of the current JavaScript file.

    -PDFJS.imageResourcesPath = './images/';
    -  PDFJS.workerSrc = '../build/pdf.worker.js';
    -  PDFJS.cMapUrl = '../web/cmaps/';
    -  PDFJS.cMapPacked = true;
    +var scriptTagContainer = document.body ||
    +                         document.getElementsByTagName('head')[0];
    +var pdfjsSrc = scriptTagContainer.lastChild.src;
    +
    +if (pdfjsSrc) {
    +  PDFJS.imageResourcesPath = pdfjsSrc.replace(/pdf\.js$/i, 'images/');
    +  PDFJS.workerSrc = pdfjsSrc.replace(/pdf\.js$/i, 'pdf.worker.js');
    +  PDFJS.cMapUrl = pdfjsSrc.replace(/pdf\.js$/i, 'cmaps/');
    +}
    +
    +PDFJS.cMapPacked = true;

#### Explicitly load a PDF document

The viewer shouldn't start loading a (default) document when it's loaded. Instead we want to expose the initialization,
so it can be called in JavaScript with `PDFJS.webViewerLoad()`.

    -document.addEventListener('DOMContentLoaded', webViewerLoad, true);
    +// document.addEventListener('DOMContentLoaded', webViewerLoad, true);
    +PDFJS.webViewerLoad = function (src) {
    +  if (src) DEFAULT_URL = src;
    +
    +  webViewerLoad();
    +}

On several places the code assumes that a PDF is loaded, which (because of the explicit load) might not be the case. We
need to check if `pdfDocument` is set before using it.

##### PDFViewerApplication.pagesCount() and PDFLinkService.pagesCount()

         get pagesCount() {
    -      return this.pdfDocument.numPages;
    +      return this.pdfDocument ? this.pdfDocument.numPages : 0;
         },

_The pagesCount method for both `PDFViewerApplication` and `PDFLinkService`. Both need to be patched._

##### PDFViewerApplication.cleanup()

       cleanup: function pdfViewCleanup() {
         this.pdfViewer.cleanup();
         this.pdfThumbnailViewer.cleanup();
    -    this.pdfDocument.cleanup();
    +    if (this.pdfDocument) {
    +      this.pdfDocument.cleanup();
    +    }
       },

#### overlayManagerRegister

The overlay is registered when the viewer is loaded. The original code will only do this once and give an error on each
subsequent call. Escpecially with single-page applications (eg an Angular app), the viewer may be loaded multiple times.
This patch causes pdf.js to unregister an unusued (closed) overlay.

       register: function overlayManagerRegister(name, callerCloseMethod, canForceClose) {
         return new Promise(function (resolve) {
           var element, container;
           if (!name || !(element = document.getElementById(name)) ||
               !(container = element.parentNode)) {
             throw new Error('Not enough parameters.');
           } else if (this.overlays[name]) {
    -        throw new Error('The overlay is already registered.');
    +        if (this.active !== name) {
    +          this.unregister(name);
    +        } else {
    +          throw new Error('The overlay is already registered and active.');
    +        }
           }

#### webViewerChange trigger on file upload dialog

Whenever a file dialog is used (so with any `<input type="file">` on the page), the file is loaded into the pdf.js
viewer. We don't want this behaviour, so comment it out.

    -window.addEventListener('change', function webViewerChange(evt) {
    +/*window.addEventListener('change', function webViewerChange(evt) {
       var files = evt.target.files;
       if (!files || files.length === 0) {
         return;
    @@ -17627,7 +17647,7 @@
         setAttribute('hidden', 'true');
       document.getElementById('download').setAttribute('hidden', 'true');
       document.getElementById('secondaryDownload').setAttribute('hidden', 'true');
    -}, true);
    +}, true);*/

#### handleMouseWheel()

The JavaScript pdf.js file might be loaded while the viewer isn't being displayed. This causes an error on mouse move.
We need to check if the viewer is initialized, before handling the event.

     function handleMouseWheel(evt) {
    +  // Ignore mousewheel event if pdfViewer isn't loaded
    +  if (!PDFViewerApplication.pdfViewer) return;

#### Load code for worker using AJAX if needed

A [Web Worker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) can't use code from
a same-origin domain. The CORS headers don't apply.

he patch will cause pdf.js to first try to create the Worker the regular way, with a URL to the JavaScript source. If
this fails, the source if fetched using AJAX and used to create an
[object url](https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL). If this also fails, pdf.js will go
onto it's last resort by calling `setupFakeWorker()`.

    +    /**
    +     * Needed because workers cannot load scripts outside of the current origin (as of firefox v45).
    +     * This patch does require the worker script to be served with a (Access-Control-Allow-Origin: *) header
    +     * @patch
    +     */
    +    var loadWorkerXHR = function(){
    +      var url = PDFJS.workerSrc;
    +      var jsdfd = PDFJS.createPromiseCapability();
    +
    +      if (url.match(/^blob:/) || typeof URL.createObjectURL === 'undefined') {
    +        jsdfd.reject(); // Failed loading using blob
    +      }
    +
    +      var xmlhttp;
    +      xmlhttp = new XMLHttpRequest();
    +
    +      xmlhttp.onreadystatechange = function(){
    +        if (xmlhttp.readyState != 4) return;
    +
    +        if (xmlhttp.status == 200) {
    +          info('Loaded worker source through XHR.');
    +          var workerJSBlob = new Blob([xmlhttp.responseText], { type: 'text/javascript' });
    +          jsdfd.resolve(window.URL.createObjectURL(workerJSBlob));
    +        } else {
    +          jsdfd.reject();
    +        }
    +      };
    +
    +      xmlhttp.open('GET', url, true);
    +      xmlhttp.send();
    +      return jsdfd.promise;
    +    }
    +
    +    var workerError = function() {
    +      loadWorkerXHR().then(function(blob) {
    +        PDFJS.workerSrc = blob;
    +        loadWorker();
    +      }, function() {
    +        this.setupFakeWorker();
    +      }.bind(this));
    +    }.bind(this);
    +
    
    -    if (!globalScope.PDFJS.disableWorker && typeof Worker !== 'undefined') {
    +    var loadWorker = function() {
           var workerSrc = PDFJS.workerSrc;
           if (!workerSrc) {
             error('No PDFJS.workerSrc specified');
    @@ -3559,6 +3603,8 @@
             // Some versions of FF can't create a worker on localhost, see:
             // https://bugzilla.mozilla.org/show_bug.cgi?id=683280
             var worker = new Worker(workerSrc);
    +        worker.onerror = workerError;
    +
             var messageHandler = new MessageHandler('main', worker);
             this.messageHandler = messageHandler;
    
    @@ -3589,11 +3635,16 @@
             return;
           } catch (e) {
             info('The worker has been disabled.');
    +        workerError();
           }
    -    }
    +    }.bind(this);
         // Either workers are disabled, not supported or have thrown an exception.
         // Thus, we fallback to a faked worker.
    -    this.setupFakeWorker();
    +    if (!globalScope.PDFJS.disableWorker && typeof Worker !== 'undefined') {
    +      loadWorker();
    +    } else {
    +      this.setupFakeWorker();
    +    }
       }

