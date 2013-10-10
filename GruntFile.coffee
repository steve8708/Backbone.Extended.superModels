
config =
  useLocalIp: true

module.exports = (grunt) ->

  # Load our our dustom grunt tasks  - - - - - - - - - - - -

  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-prompt'
  grunt.loadNpmTasks 'grunt-contrib'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-text-replace'


  # Main config - - - - - - - - - - - - - - - - - - - - - -

  hostname = if config.useLocalIp then getLocalIp() else 'localhost'

  grunt.initConfig
    connect:
      server:
        options:
          port: 5050
          hostname: hostname

    coffee:
      compile:
        files:
          'backbone.extended.super-models.js': [
            'src/backbone.extended.super-models.coffee'
          ]

    coffeelint:
      src: [ 'src/**/*.coffee', 'GruntFile.coffee', 'tasks/*.coffee' ]

    watch:
      coffee:
        files: [ 'src/**/*.coffee' ]
        tasks: [ 'coffeelint', 'coffee' ]

      lint:
        files: [ 'GruntFile.coffee', 'tasks/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'coffeelint' ]

    uglify:
      main:
        files:
          'backbone.extended.super-models.min.js': [
            'backbone.extended.super-models.js'
          ]

    karma:
      options:
        browsers: [ 'PhantomJS' ]
        frameworks: [ 'mocha', 'chai' ]
        files: [ 'backbone.extended.super-models.js', 'test/**/*.coffee' ]

      single:
        singleRun: true

      watch:
        autoWatch: true

    replace:
      configVersion:
        src: [ 'src/backbone.extended.super-models.coffee' ]
        overwrite: true
        replacements: [
          from: /Backbone.extended.super-models.VERSION = '.*?'/i
          to: -> "Backbone.extended.super-models.VERSION " +
            "= '#{ packageVersion() }'"
        ]

      debugJS:
        src: [ 'backbone.extended.super-models.js' ]
        overwrite: true
        replacements: [
          from: /^/
          to: -> "/* backbone.extended.super-models.js" +
            " v#{ packageVersion() } (coffeescript output) */ \n\n"
        ]

      minJS:
        src: [ 'backbone.extended.super-models.min.js' ]
        overwrite: true
        replacements: [
          from: /^/
          to: -> "/* backbone.extended.super-models.min.js" +
            " v#{ packageVersion() } */ \n"
        ]

    bump:
      options:
        files: [ 'package.json' ]
        commitFiles: [
          'package.json'
          'src/backbone.extended.super-models.coffee'
          'backbone.extended.super-models.js'
          'backbone.extended.super-models.min.js'
        ]
        pushTo: 'origin'

    shell:
      checkUnstaged:
        command: 'git status'
        options:
          callback: (err, stdout, stderr, done) ->
            if /modified:|deleted:|untracked:/.test stdout
              grunt.fail.warn(
                'You have unstaged files, please commit or stash ' +
                'them before proceeding'
              )
            done()

    prompt:
      release:
        options:
          questions: [
            type: 'input'
            name: 'Confirm'
            message: 'This is OFFICIAL deployment, are you sure ' +
              'you want to continue? y/n'
            validate: (input) -> validatePrompt input
          ,
            type: 'input'
            name: 'Check committed'
            message: "And you are 100% certain you have commited all files? y/n"
            validate: (input) ->
              validatePrompt input
              grunt.log.writeln 'OK, proceeding to release!'
              true
          ]


  # Task Groups - - - - - - - - - - - - - - - - - - - - - -

  grunt.registerTask 'build', [
    'coffeelint'
    'coffee'
    # 'test'
  ]

  grunt.registerTask 'build:release', [
    'build'
    'uglify'
    'replace:debugJS'
    'replace:minJS'
  ]

  grunt.registerTask 'release:patch',   [
    'release:confirm'
    'bump-only:patch'
    'replace:configVersion'
    'release:build'
    'bump-commit'
  ]

  grunt.registerTask 'release:minor',   [
    'release:confirm'
    'bump-only:minor'
    'replace:configVersion'
    'release:build'
    'bump-commit'
  ]

  grunt.registerTask 'release:major',   [
    'release:confirm'
    'bump-only:major'
    'replace:configVersion'
    'release:build'
    'bump-commit'
  ]

  grunt.registerTask 'test-watch',      [ 'karma:watch' ]
  grunt.registerTask 'test',            [ 'karma:single' ]
  grunt.registerTask 'release:build',   [ 'build:release' ]
  grunt.registerTask 'watch-serve',     [ 'connect', 'watch' ]
  grunt.registerTask 'release:confirm', [ 'prompt', 'shell:checkUnstaged']


  # Grunt Helpers - - - - - - - - - - - - - - - - - - - - - - - - -

  packageVersion = ->
    grunt.file.readJSON('package.json').version

  validatePrompt = (input) ->
    if input.toLowerCase() is 'y'
      true
    else
      grunt.fail.warn "Aborted by user via command: #{ input }"


# Helpers  - - - - - - - - - - - - - - - - - - - - - - - - -

os = require 'os'

getLocalIp = ->
  interfaces = os.networkInterfaces()
  for name, value of interfaces
    for details in value
      if details.family is 'IPv4' and name is 'en1'
        return details.address