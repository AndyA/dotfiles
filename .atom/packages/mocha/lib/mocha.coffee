{CompositeDisposable} = require 'atom'
MochaView = require './mocha-view'

module.exports =
  mochaView: null
  config:
    specDirectory:
      type: 'string',
      default: './spec/'
    saveAllBeforeTest:
      type: 'boolean',
      default: true
    filterExtensions:
      type: 'string',
      default: ".coffee, .js"
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @mochaView = new MochaView(state.mochaViewState)
    @subscriptions.add atom.commands.add 'atom-workspace',
      'core:close': => @mochaView?.close()
      'core:cancel': => @mochaView?.close()
  deactivate: ->
    @mochaView.destroy()
    @subscriptions.dispose()
  serialize: ->
    mochaViewState: @mochaView?.serialize?()
