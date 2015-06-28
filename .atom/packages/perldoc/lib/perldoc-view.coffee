path = require 'path'
pod2html = require './pod2html'
{CompositeDisposable, Disposable} = require 'atom'
{$, $$$, ScrollView}  = require 'atom-space-pen-views'
_ = require 'underscore-plus'

module.exports =
class PerldocView extends ScrollView
  atom.deserializers.add(this)

  editorSub           : null
  onDidChangeTitle    : -> new Disposable()
  onDidChangeModified : -> new Disposable()

  @deserialize: (state) ->
    new PerldocView(state)

  @content: ->
    @div class: 'perldoc', tabindex: -1

  constructor: ({@editorId, filePath}) ->
    super
    if @editorId?
      @resolveEditor(@editorId)
    else
      if atom.workspace?
        @subscribeToFilePath(filePath)
      else
        # @subscribe atom.packages.once 'activated', =>
        atom.packages.onDidActivatePackage =>
          @subscribeToFilePath(filePath)

  serialize: ->
    deserializer : 'PerldocView'
    filePath     : @getPath()
    editorId     : @editorId

  destroy: ->
    # @unsubscribe()
    @editorSub.dispose()

  subscribeToFilePath: (filePath) ->
    @trigger 'title-changed'
    @handleEvents()
    @renderHTML()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents()
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        @parents('.pane').view()?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      # @subscribe atom.packages.once 'activated', =>
      atom.packages.onDidActivatePackage =>
        resolve()
        @renderHTML()

  editorForId: (editorId) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleEvents: =>

    changeHandler = =>
      @renderHTML()
      pane = atom.workspace.paneForURI(@getURI())
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    @editorSub = new CompositeDisposable

    if @editor?
      if not atom.config.get("perldoc.triggerOnSave")
        @editorSub.add @editor.onDidChange _.debounce(changeHandler, 700)
      else
        @editorSub.add @editor.onDidSave changeHandler
      @editorSub.add @editor.onDidChangePath => @trigger 'title-changed'

  renderHTML: ->
    @showLoading()
    if @editor?
      @renderHTMLCode()

  renderHTMLCode: (text) ->
    if not atom.config.get("perldoc.triggerOnSave") then @editor.save()

    pod2html @editor.getText(), atom.config.get('perldoc.binary'), (html) =>
      @html html

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} perldoc"
    else
      "Perldoc"

  getURI: ->
    "perldoc://editor/#{@editorId}"

  getPath: ->
    if @editor?
      @editor.getPath()

  showError: (result) ->
    failureMessage = result?.message

    @html $$$ ->
      @h2 'perldoc failed'
      @h3 failureMessage if failureMessage?

  showLoading: ->
    @html $$$ ->
      @div class: 'perldoc-spinner', 'Loading perldoc preview \u2026'
