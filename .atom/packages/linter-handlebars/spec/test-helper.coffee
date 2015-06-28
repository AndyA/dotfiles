{ config } = require '../lib/init'


module.exports.resetConfig = ->

  Object.keys(config or {}).forEach (key) ->
    atom.config.set("linter-less.#{key}", config[key].default)
