url                   = require 'url'
{CompositeDisposable} = require 'atom'

PerldocView = require './perldoc-view'

module.exports =
  config:
    triggerOnSave:
      type        : 'boolean'
      description : 'Watch will trigger on save.'
      default     : false
    binary:
      type: 'string'
      description: 'Path to `pod2html`'
      default: '/usr/local/bin/pod2html'

  perldocview: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perldoc:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'perldoc:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        new PerldocView(editorId: pathname.substring(1))
      else
        new PerldocView(filePath: pathname)

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    uri = "perldoc://editor/#{editor.id}"

    previewPane = atom.workspace.paneForURI(uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForURI(uri))
      return

    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (perldocview) ->
      if perldocview instanceof PerldocView
        perldocview.renderHTML()
        previousActivePane.activate()

  deactivate: ->
    @subscriptions.dispose()
