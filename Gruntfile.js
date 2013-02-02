module.exports = function(grunt) {
"use strict";

  grunt.initConfig({
    pkg: grunt.file.readJSON("package.json"),
    watch: {
      js: {
        files: [
          "Gruntfile.js",
          "src/js/**/*.js"
        ],
        tasks: ["js"],
        options: {
          debounceDelay: 3000,
          interval: 1000
        }
      },
      css: {
        files: [
          "src/scss/*.scss"
        ],
        tasks: ["css"],
        options: "<%= watch.js.options %>"
      },
      all: {
        files: [
          "<%= watch.js.files %>",
          "<%= watch.css.files %>"
        ],
        tasks: ["js", "css"],
        options: "<%= watch.js.options %>"
      }
    },
    concat: {
      dist: {
        src: [
          "src/js/app.js",
          "src/js/model/*.js",
          "src/js/collection/*.js",
          "src/js/view/*.js"
        ],
        dest: "static/js/<%= pkg.name %>.js"
      }
    },
    uglify: {
      dist: {
        src: "<%= concat.dist.dest %>",
        dest: "static/js/<%= pkg.name %>.min.js"
      }
    },
    jshint: {
      options: {
        jshintrc: ".jshintrc"
      },
      all: ["Gruntfile.js", "<%= concat.dist.src %>"]
    },
    compass: {
      dev: {
        options: {
          config: "compass_config.rb",
          environment: "development"
        }
      },
      prod: {
        options: {
          config: "compass_config.rb",
          environment: "production"
        }
      }
    }
  });

  // load grunt plugings
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-concat");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-contrib-jshint");
  grunt.loadNpmTasks("grunt-contrib-compass");

  // tasks
  grunt.registerTask("js", ["jshint", "concat", "uglify"]);
  grunt.registerTask("css", ["compass:prod"]);
};
