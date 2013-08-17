module.exports = (grunt) ->
  "use strict"

  # set ENV for compass.sh (bundle exec compass)
  process.env.PATH += ":."

  grunt.initConfig(
    pkg: grunt.file.readJSON("package.json")

    watch:
      coffee:
        files: [
          "coffee/**/*.coffee"
        ]
        tasks: ["js"]
        options:
          debounceDelay: 1000
      scss:
        files: [
          "scss/*.scss"
        ]
        tasks: ["css"]
        options: "<%= watch.coffee.options %>"
      all:
        files: [
          "<%= watch.coffee.files %>"
          "<%= watch.scss.files %>"
        ]
        tasks: ["js", "css"]
        options: "<%= watch.coffee.options %>"

    coffee:
      compile:
        files:
          "static/js/app.js": [
            "coffee/app.coffee"
            "coffee/controllers/*.coffee"
            "coffee/directives/*.coffee"
            "coffee/services/*.coffee"
          ]

    uglify:
      dest:
        files: "static/js/app.min.js": ["static/js/app.js"]

    concat:
      prod:
        src: [
          "bower_components/angular/angular.min.js"
          "static/js/app.min.js"
        ]
        dest: "static/js/all.js"
      dev:
        src: [
          "bower_components/angular/angular.js"
          "static/js/app.js"
        ]
        dest: "static/js/all.min.js"

    compass:
      dist:
        options:
          config: "config/compass.rb"

    cssmin:
      compress:
        files:
          "static/css/app.min.css": [ "static/css/app.css" ]
  )

  # load grunt plugings
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-cssmin"

  grunt.registerTask 'js', ['coffee', 'uglify', 'concat']
  grunt.registerTask 'css', ['compass', 'cssmin']
  grunt.registerTask 'default', ['js', 'css']
