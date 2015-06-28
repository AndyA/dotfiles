
{View, $$} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'

module.exports =
  class MochaView extends View

    @content: ->
      @div =>
        css = 'tool-panel pannel panel-bottom padding native-key-bindings'
        @div class: css, outlet: 'script', tabindex: -1, =>
          @div id: 'mocha', class: 'panel-body padded output', outlet: 'output'

    initialize: (serializeState) ->
      atom.commands.add 'atom-workspace', "mocha:test", => @test()

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @detach()

    close: ->
      # Stop any running process and dismiss window
      @stop()
      @detach() if @hasParent()

    resetView: (title = 'Loading...') ->
      # Display window and load message
      # First run, create view
      atom.workspace.addBottomPanel(item: this) unless @hasParent()
      # Close any existing process and start a new one
      @stop()
      # Get script view ready
      @output.empty()

    saveAll: ->
      return unless atom.config.get('mocha.saveAllBeforeTest')
      atom.project.buffers.forEach (buffer) -> buffer.save() if buffer.isModified() and buffer.file?

    test: ->
      @resetView()
      @saveAll()
      fs   = require 'fs-plus'
      path = require 'path'
      testFiles = [];
      projectDirs = atom.project.getPaths()
      projectDirs.forEach (projectDir) ->
        specDir = path.join(projectDir, atom.config.get('mocha.specDirectory'))
        if (extensions =  atom.config.get('mocha.filterExtensions')?.split(',')) and extensions?.length
          extensions = for ext in extensions then ext.trim()
        else
          extensions = [".coffee", ".js"]
        projectFiles = fs.listTreeSync(specDir)
        Array::push.apply testFiles, fs.filterExtensions(projectFiles, extensions)
      Mocha = require 'mocha'
      mocha = new Mocha(reporter: Mocha.reporters.HTML)
      window.chai = require 'chai' #quick and dirty
      testFiles.forEach (file) ->
        mocha.addFile file
      try
        mocha.run()
      catch error
        errorstr = error.stack or error.toString()
        @output.append $$ ->
          @pre class: "error", =>
            @raw errorstr

      projectDirs.forEach (projectDir) ->
        for file of require.cache
          delete require.cache[file] if file.startsWith(projectDir)
