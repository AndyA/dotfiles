{CompositeDisposable} = require 'event-kit'
{repositoryForPath} = require './helpers'

module.exports =
class MinimapGitDiffBinding

  active: false

  constructor: (@gitDiff, @minimap) ->
    @editor = @minimap.getTextEditor()
    @decorations = {}
    @markers = null
    @subscriptions = new CompositeDisposable

    @subscriptions.add @editor.getBuffer().onDidStopChanging @updateDiffs

    if repository = @getRepo()
      @subscriptions.add repository.onDidChangeStatuses =>
        @scheduleUpdate()
      @subscriptions.add repository.onDidChangeStatus (changedPath) =>
        @scheduleUpdate() if changedPath is @editor.getPath()

    @scheduleUpdate()

  cancelUpdate: ->
    clearImmediate(@immediateId)

  scheduleUpdate: ->
    @cancelUpdate()
    @immediateId = setImmediate(@updateDiffs)

  updateDiffs: =>
    @removeDecorations()
    if @getPath() and @diffs = @getDiffs()
      @addDecorations(@diffs)

  addDecorations: (diffs) ->
    for {oldStart, newStart, oldLines, newLines} in diffs
      startRow = newStart - 1
      endRow = newStart + newLines - 2
      if oldLines is 0 and newLines > 0
        @markRange(startRow, endRow, '.minimap .git-line-added')
      else if newLines is 0 and oldLines > 0
        @markRange(startRow, startRow, '.minimap .git-line-removed')
      else
        @markRange(startRow, endRow, '.minimap .git-line-modified')

  removeDecorations: ->
    return unless @markers?
    marker.destroy() for marker in @markers
    @markers = null

  markRange: (startRow, endRow, scope) ->
    return if @editor.displayBuffer.isDestroyed()
    marker = @editor.markBufferRange([[startRow, 0], [endRow, Infinity]], invalidate: 'never')
    @minimap.decorateMarker(marker, type: 'line', scope: scope)
    @markers ?= []
    @markers.push(marker)

  destroy: ->
    @removeDecorations()
    @subscriptions.dispose()
    @diffs = null

  getPath: -> @editor.getBuffer()?.getPath()

  getRepositories: -> atom.project.getRepositories().filter (repo) -> repo?

  getRepo: -> @repository ?= repositoryForPath(@editor.getPath())

  getDiffs: ->
    @getRepo()?.getLineDiffs(@getPath(), @editor.getBuffer().getText())
