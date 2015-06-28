{Emitter, CompositeDisposable} = require 'event-kit'

PluginManagement = require './mixins/plugin-management'

[Minimap, MinimapElement, MinimapPluginGeneratorElement, deprecate, semver] = []

# Public: The `Minimap` package provides an eagle-eye view of text buffers.
#
# It also provides API for plugin packages that want to interact with the
# minimap and be available to the user through the minimap settings.
#
# ## Plugins Interface
#
# Plugins should conform to the following interface:
#
# ```coffee
# class Plugin
#   void activatePlugin: ->
#   void deactivatePlugin: ->
#   bool isActive: ->
# ```
class Main
  PluginManagement.includeInto(this)

  ### Public ###

  # The minimap package version
  version: require('../package.json').version

  # The default minimap settings
  config:
    plugins:
      type: 'object'
      properties: {}
    autoToggle:
      type: 'boolean'
      default: true
    displayMinimapOnLeft:
      type: 'boolean'
      default: false
    displayCodeHighlights:
      type: 'boolean'
      default: true
      description: 'Toggles the render of the buffer tokens in the minimap.'
    displayPluginsControls:
      type: 'boolean'
      default: true
      description: 'You need to restart Atom for this setting to be effective.'
    minimapScrollIndicator:
      type: 'boolean'
      default: true
      description: 'Toggles the display of a side line showing which part of the buffer is currently displayed by the minimap. This side line will only appear if the minimap is taller than the editor view height.'
    useHardwareAcceleration:
      type: 'boolean'
      default: true
    adjustMinimapWidthToSoftWrap:
      type: 'boolean'
      default: true
      description: 'If this option is enabled and Soft Wrap is checked then the Minimap max width is set to the Preferred Line Length value.'
    charWidth:
      type: 'number'
      default: 1
      minimum: .5
    charHeight:
      type: 'number'
      default: 2
      minimum: .5
    interline:
      type: 'number'
      default: 1
      minimum: 0
      description: 'The space between lines in the minimap in pixels.'
    textOpacity:
      type: 'number'
      default: 0.6
      minimum: 0
      maximum: 1
      description: "The opacity used to render the line's text in the minimap."
    scrollAnimation:
      type: 'boolean'
      default: false
      description: 'Enables animations when scrolling by clicking on the minimap.'
    scrollAnimationDuration:
      type: 'integer'
      default: 300
      description: 'The duration of scrolling animations when clicking on the minimap.'
    createPluginInDevMode:
      type: 'boolean'
      default: false
    absoluteMode:
      type: 'boolean'
      default: false
      description: 'When enabled the text editor content will be able to flow below the minimap.'

  # Internal: The activation state of the minimap package.
  active: false

  # Internal: Used only at export time.
  constructor: ->
    @emitter = new Emitter

    # Commands Subscriptions
    @subscriptionsOfCommands = new CompositeDisposable
    @subscriptionsOfCommands.add atom.commands.add 'atom-workspace',
      'minimap:toggle': => @toggle()
      'minimap:generate-plugin': => @generatePlugin()

    # Other Subscriptions
    @subscriptions = new CompositeDisposable

    MinimapElement ?= require './minimap-element'
    MinimapElement.registerViewProvider()

  # Activates the minimap package.
  activate: ->
    @active = true
    @toggle() if atom.config.get 'minimap.autoToggle'

  # Deactivates the minimap package.
  deactivate: ->
    @deactivateAllPlugins()
    @subscriptions.dispose()
    @editorsMinimaps?.forEach (value, key) =>
      value.destroy()
      @editorsMinimaps.delete(key)
    @editorsMinimaps = undefined
    @toggled = false
    @active = false

  # Verifies that the passed-in version expression is satisfied by
  # the current minimap version.
  #
  # expectedVersion - A [semver](https://github.com/npm/node-semver)
  #                   compatible expression to match agains the minimap
  #                   version.
  #
  # Returns a {Boolean}.
  versionMatch: (expectedVersion) ->
    semver ?= require 'semver'
    semver.satisfies(@version, expectedVersion)

  # Toggles the minimap display.
  toggle: ->
    return unless @active
    if @toggled
      @toggled = false
      @editorsMinimaps?.forEach (value, key) =>
        value.destroy()
        @editorsMinimaps.delete(key)
      @subscriptions.dispose()
    else
      @toggled = true
      @initSubscriptions()

  # Opens the plugin generation view.
  generatePlugin: ->
    MinimapPluginGeneratorElement ?= require './minimap-plugin-generator-element'
    view = new MinimapPluginGeneratorElement()
    view.attach()

  # Calls the `callback` when the minimap package have been activated.
  #
  # callback - The callback {Function}.
  #
  # Returns a `Disposable`.
  onDidActivate: (callback) ->
    @emitter.on 'did-activate', callback

  # Calls the `callback` when the minimap package have been deactivated.
  #
  # callback - The callback {Function}.
  #
  # Returns a `Disposable`.
  onDidDeactivate: (callback) ->
    @emitter.on 'did-deactivate', callback

  # Calls the `callback` when a minimap have been created.
  #
  # callback - The callback {Function}. The callback will receive
  #            {Minimap} that was created.
  #
  # Returns a `Disposable`.
  onDidCreateMinimap: (callback) ->
    @emitter.on 'did-create-minimap', callback

  # Calls the `callback` when a plugin have been registered.
  #
  # callback - The callback {Function}. The event the callback will receive
  #            have the following properties:
  #            :name - The plugin name {String}.
  #            :plugin - The plugin {Object}.
  #
  # Returns a `Disposable`.
  onDidAddPlugin: (callback) ->
    @emitter.on 'did-add-plugin', callback

  # Calls the `callback` when a plugin have been unregistered.
  #
  # callback - The callback {Function}. The event the callback will receive
  #            have the following properties:
  #            :name - The plugin name {String}.
  #            :plugin - The plugin {Object}.
  #
  # Returns a `Disposable`.
  onDidRemovePlugin: (callback) ->
    @emitter.on 'did-remove-plugin', callback

  # Calls the `callback` when a plugin have been activated.
  #
  # callback - The callback {Function}. The event the callback will receive
  #            have the following properties:
  #            :name - The plugin name {String}.
  #            :plugin - The plugin {Object}.
  #
  # Returns a `Disposable`.
  onDidActivatePlugin: (callback) ->
    @emitter.on 'did-activate-plugin', callback

  # Calls the `callback` when a plugin have been deactivated.
  #
  # callback - The callback {Function}. The event the callback will receive
  #            have the following properties:
  #            :name - The plugin name {String}.
  #            :plugin - The plugin {Object}.
  #
  # Returns a `Disposable`.
  onDidDeactivatePlugin: (callback) ->
    @emitter.on 'did-deactivate-plugin', callback

  # Returns the {Minimap} object associated to the
  # passed-in `TextEditorElement`.
  #
  # editorElement - An `TextEditorElement` instance
  #
  # Returns a {Minimap}.
  minimapForEditorElement: (editorElement) ->
    return unless editorElement?
    @minimapForEditor(editorElement.getModel())

  # Returns the {Minimap} object associated to the
  # passed-in `TextEditor`.
  #
  # editorView - An `Editor` instance
  #
  # Returns a {Minimap}.
  minimapForEditor: (textEditor) ->
    return unless textEditor?

    Minimap ?= require './minimap'
    @editorsMinimaps ?= new Map

    minimap = @editorsMinimaps.get(textEditor)
    unless minimap?
      minimap = new Minimap({textEditor})
      @editorsMinimaps.set(textEditor, minimap)
      editorSubscription = textEditor.onDidDestroy =>
        @editorsMinimaps?.delete(textEditor)
        editorSubscription.dispose()

    minimap

  # Returns the {Minimap} of the active `TextEditor`.
  #
  # Returns a {Minimap}.
  getActiveMinimap: -> @minimapForEditor(atom.workspace.getActiveTextEditor())

  # Calls `iterator` for each present and future minimaps.
  # It returns a `Disposable` to unsubscribe the iterator from being called
  # for future views.
  #
  # iterator - A {Function} to call for each minimap view. It will receive
  #            the {Minimap} instance as parameter.
  #
  # Returns a `Disposable`.
  observeMinimaps: (iterator) ->
    return unless iterator?
    @editorsMinimaps?.forEach (minimap) -> iterator(minimap)
    createdCallback = (minimap) -> iterator(minimap)
    @onDidCreateMinimap(createdCallback)

  # Internal: Registers to the `observeTextEditors` method.
  initSubscriptions: ->
    @subscriptions.add atom.workspace.observeTextEditors (textEditor) =>
      minimap = @minimapForEditor(textEditor)

      editorElement = atom.views.getView(textEditor)
      minimapElement = atom.views.getView(minimap)

      @emitter.emit('did-create-minimap', minimap)

      minimapElement.attach()

# The minimap module is an instance of the {Minimap} class.
module.exports = new Main()
