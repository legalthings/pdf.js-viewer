module.exports = function (grunt) {
  'use strict';
  
  grunt.loadNpmTasks('grunt-css-prefix');

  grunt.initConfig({
    css_prefix: {
      libname: {
        options: {
          prefix: '.pdfjs ',
          punctuation: ''
        },
        files: {
          'build/web/viewer.css': ['source/web/viewer.css']
        }
      }
    }
  });
  
  grunt.registerTask('default', ['css_prefix']);
};

