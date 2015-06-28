LinterHandlebarsProvider = require './linter-handlebars-provider'


module.exports =

  activate: ->
    console.log "activate linter-handlebars" # if atom.inDevMode()

    if not atom.packages.getLoadedPackage 'linter'
      atom.notifications.addError """
        [linter-handlebars] `linter` package not found, please install it.
      """

  provideLinter: -> LinterHandlebarsProvider
