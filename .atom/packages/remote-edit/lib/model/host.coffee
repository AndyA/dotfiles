Serializable = require 'serializable'
async = require 'async'
{Emitter} = require 'atom'
hash = require 'string-hash'
_ = require 'underscore-plus'
osenv = require 'osenv'

module.exports =
  class Host
    Serializable.includeInto(this)
    atom.deserializers.add(this)

    constructor: (@alias = null, @hostname, @directory = "/", @username = osenv.user(), @port, @localFiles = [], @usePassword, @lastOpenDirectory) ->
      @localFiles = [] if atom.config.get 'remote-edit.clearFileList'
      @emitter = new Emitter

    destroy: ->
      @emitter.dispose()

    getConnectionString: ->
      throw new Error("Function getConnectionString() needs to be implemented by subclasses!")

    connect: (callback, connectionOptions = {}) ->
      throw new Error("Function connect(callback) needs to be implemented by subclasses!")

    close: (callback) ->
      throw new Error("Needs to be implemented by subclasses!")

    getFilesMetadata: (path, callback) ->
      throw new Error("Function getFiles(Callback) needs to be implemented by subclasses!")

    getFileData: (file, callback) ->
      throw new Error("see subclass")

    serializeParams: ->
      throw new Error("Must be implemented in subclass!")

    writeFile: (file, text, callback) ->
      throw new Error("Must be implemented in subclass!")

    isConnected: ->
      throw new Error("Must be implemented in subclass!")

    hashCode: ->
      hash(@hostname + @directory + @username + @port)

    addLocalFile: (localFile) ->
      @localFiles.push(localFile)
      @emitter.emit 'did-change', localFile

    removeLocalFile: (localFile) ->
      @localFiles = _.reject(@localFiles, ((val) -> val == localFile))
      @emitter.emit 'did-change', localFile

    delete: ->
      for file in @localFiles
        file.delete()
      @emitter.emit 'did-delete', this

    invalidate: ->
      @emitter.emit 'did-change'

    onDidChange: (callback) ->
      @emitter.on 'did-change', callback

    onDidDelete: (callback) ->
      @emitter.on 'did-delete', callback

    onInfo: (callback) ->
      @emitter.on 'info', callback
