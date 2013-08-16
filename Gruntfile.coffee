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
        tasks: ["coffee"]
        options:
          debounceDelay: 1000
      scss:
        files: [
          "scss/*.scss"
        ]
        tasks: ["compass:dist"]
        options: "<%= watch.coffee.options %>"
      all:
        files: [
          "<%= watch.coffee.files %>"
          "<%= watch.scss.files %>"
        ]
        tasks: ["coffee", "compass:dist"]
        options: "<%= watch.coffee.options %>"
    coffee:
      compile:
        files:
          "static/js/petatube2.js": [
            "coffee/app.coffee"
            "coffee/controllers/*.coffee"
            "coffee/directives/*.coffee"
            "coffee/services/*.coffee"
          ]
    compass:
      dist:
        options:
          config: "config/compass.rb"
          environment: "production"
      dev:
        options:
          config: "config/compass.rb"
          environment: "development"
  )

  # load grunt plugings
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-compass"

  grunt.registerTask 'default', ['coffee', 'compass:dist']
