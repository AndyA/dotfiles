{TextEditorView, View} = require 'atom-space-pen-views'
{spawn, exec} = require 'child_process'
ansihtml = require 'ansi-html-stream'
readline = require 'readline'
{addClass, removeClass} = require 'domutil'
{resolve, dirname, extname} = require 'path'
fs = require 'fs'

lastOpenedView = null

module.exports =
class CommandOutputView extends View
  cwd: null
  @content: ->
    @div tabIndex: -1, class: 'panel cli-status panel-bottom', =>
      @div class: 'cli-panel-body', =>
        @pre class: "terminal", outlet: "cliOutput"
      @div class: 'cli-panel-input', =>
        @subview 'cmdEditor', new TextEditorView(mini: true, placeholderText: 'input your command here')
        @div class: 'btn-group', =>
          @button outlet: 'killBtn', click: 'kill', class: 'btn hide', 'kill'
          @button click: 'destroy', class: 'btn', 'destroy'
          @span class: 'icon icon-x', click: 'close'

  initialize: ->
    @userHome = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    cmd = 'test -e /etc/profile && source /etc/profile;test -e ~/.profile && source ~/.profile; node -pe "JSON.stringify(process.env)"'
    shell = atom.config.get 'terminal-panel.shell'
    exec cmd, {shell}, (code, stdout, stderr) ->
      try
        process.env = JSON.parse(stdout)
      catch e
    atom.commands.add 'atom-workspace',
      "cli-status:toggle-output": => @toggle()

    atom.commands.add @cmdEditor.element,
      'core:confirm': =>
        inputCmd = @cmdEditor.getModel().getText()
        @cliOutput.append "\n$>#{inputCmd}\n"
        @scrollToBottom()
        args = []
        # support 'a b c' and "foo bar"
        inputCmd.replace /("[^"]*"|'[^']*'|[^\s'"]+)/g, (s) =>
          if s[0] != '"' and s[0] != "'"
            s = s.replace /~/g, @userHome
          args.push s
        cmd = args.shift()
        if cmd == 'cd'
          return @cd args
        if cmd == 'ls' and atom.config.get('terminal-panel.overrideLs')
          return @ls args
        if cmd == 'clear'
          @cliOutput.empty()
          @message '\n'
          return @cmdEditor.setText ''
        @spawn inputCmd, cmd, args

  showCmd: ->
    @cmdEditor.show()
    @cmdEditor.css('visibility', '')
    @cmdEditor.getModel().selectAll()
    @cmdEditor.setText('') if atom.config.get('terminal-panel.clearCommandInput')
    @cmdEditor.focus()
    @scrollToBottom()

  scrollToBottom: ->
    @cliOutput.scrollTop 10000000

  flashIconClass: (className, time=100)=>
    addClass @statusIcon, className
    @timer and clearTimeout(@timer)
    onStatusOut = =>
      removeClass @statusIcon, className
    @timer = setTimeout onStatusOut, time

  destroy: ->
    _destroy = =>
      if @hasParent()
        @close()
      if @statusIcon and @statusIcon.parentNode
        @statusIcon.parentNode.removeChild(@statusIcon)
      @statusView.removeCommandView this
    if @program
      @program.once 'exit', _destroy
      @program.kill()
    else
      _destroy()

  kill: ->
    if @program
      @program.kill()

  open: ->
    @lastLocation = atom.workspace.getActivePane()
    @panel = atom.workspace.addBottomPanel(item: this) unless @hasParent()
    if lastOpenedView and lastOpenedView != this
      lastOpenedView.close()
    lastOpenedView = this
    @scrollToBottom()
    @statusView.setActiveCommandView this
    @cmdEditor.focus()
    @cliOutput.css('font-family', atom.config.get('editor.fontFamily'))
    @cliOutput.css('font-size', atom.config.get('editor.fontSize') + 'px')
    @cliOutput.css('max-height', atom.config.get('terminal-panel.windowHeight') + 'vh')

  close: ->
    @lastLocation.activate()
    @detach()
    @panel.destroy()
    lastOpenedView = null

  toggle: ->
    if @hasParent()
      @close()
    else
      @open()

  cd: (args)->
    args = [atom.project.path] if not args[0]
    dir = resolve @getCwd(), args[0]
    fs.stat dir, (err, stat) =>
      if err
        if err.code == 'ENOENT'
          return @errorMessage "cd: #{args[0]}: No such file or directory"
        return @errorMessage err.message
      if not stat.isDirectory()
        return @errorMessage "cd: not a directory: #{args[0]}"
      @cwd = dir
      @message "cwd: #{@cwd}"

  ls: (args) ->
    files = fs.readdirSync @getCwd()
    filesBlocks = []
    files.forEach (filename) =>
      filesBlocks.push @_fileInfoHtml(filename, @getCwd())
    filesBlocks = filesBlocks.sort (a, b) ->
      aDir = a[1].isDirectory()
      bDir = b[1].isDirectory()
      if aDir and not bDir
        return -1
      if not aDir and bDir
        return 1
      a[2] > b[2] and 1 or -1
    filesBlocks = filesBlocks.map (b) ->
      b[0]
    @message filesBlocks.join('') + '<div class="clear"/>'

  _fileInfoHtml: (filename, parent) ->
    classes = ['icon', 'file-info']
    filepath = parent + '/' + filename
    stat = fs.lstatSync filepath
    if stat.isSymbolicLink()
      classes.push 'stat-link'
      stat = fs.statSync filepath
    if stat.isFile()
      if stat.mode & 73 #0111
        classes.push 'stat-program'
      # TODO check extension
      classes.push 'icon-file-text'
    if stat.isDirectory()
      classes.push 'icon-file-directory'
    if stat.isCharacterDevice()
      classes.push 'stat-char-dev'
    if stat.isFIFO()
      classes.push 'stat-fifo'
    if stat.isSocket()
      classes.push 'stat-sock'
    if filename[0] == '.'
      classes.push 'status-ignored'
    ["<span class=\"#{classes.join ' '}\">#{filename}</span>", stat, filename]

  getGitStatusName: (path, gitRoot, repo) ->
    status = (repo.getCachedPathStatus or repo.getPathStatus)(path)
    if status
      if repo.isStatusModified status
        return 'modified'
      if repo.isStatusNew status
        return 'added'
    if repo.isPathIgnore path
      return 'ignored'

  message: (message) ->
    @cliOutput.append message
    @showCmd()
    removeClass @statusIcon, 'status-error'
    addClass @statusIcon, 'status-success'

  errorMessage: (message) ->
    @cliOutput.append message
    @showCmd()
    removeClass @statusIcon, 'status-success'
    addClass @statusIcon, 'status-error'

  getCwd: ->
    extFile = extname atom.project.getPaths()[0]

    if extFile == ""
      if atom.project.getPaths()[0]
        projectDir = atom.project.getPaths()[0]
      else
        if process.env.HOME
          projectDir = process.env.HOME
        else if process.env.USERPROFILE
          projectDir = process.env.USERPROFILE
        else
          projectDir = '/'
    else
      projectDir = dirname atom.project.getPaths()[0]

    @cwd or projectDir or @userHome

  spawn: (inputCmd, cmd, args) ->
    @cmdEditor.css('visibility', 'hidden')
    htmlStream = ansihtml()
    htmlStream.on 'data', (data) =>
      @cliOutput.append data
      @scrollToBottom()
    shell = atom.config.get 'terminal-panel.shell'
    try
      @program = exec inputCmd, stdio: 'pipe', env: process.env, cwd: @getCwd(), shell: shell
      @program.stdout.pipe htmlStream
      @program.stderr.pipe htmlStream
      removeClass @statusIcon, 'status-success'
      removeClass @statusIcon, 'status-error'
      addClass @statusIcon, 'status-running'
      @killBtn.removeClass 'hide'
      @program.once 'exit', (code) =>
        console.log 'exit', code if atom.config.get('terminal-panel.logConsole')
        @killBtn.addClass 'hide'
        removeClass @statusIcon, 'status-running'
        @program = null
        addClass @statusIcon, code == 0 and 'status-success' or 'status-error'
        @showCmd()
      @program.on 'error', (err) =>
        console.log 'error' if atom.config.get('terminal-panel.logConsole')
        @cliOutput.append err.message
        @showCmd()
        addClass @statusIcon, 'status-error'
      @program.stdout.on 'data', =>
        @flashIconClass 'status-info'
        removeClass @statusIcon, 'status-error'
      @program.stderr.on 'data', =>
        console.log 'stderr' if atom.config.get('terminal-panel.logConsole')
        @flashIconClass 'status-error', 300

    catch err
      @cliOutput.append err.message
      @showCmd()
