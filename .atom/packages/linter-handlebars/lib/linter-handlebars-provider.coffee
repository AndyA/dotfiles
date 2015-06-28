path = require 'path'
Handlebars = require 'handlebars'
XRegExp = require('xregexp').XRegExp

module.exports =

  grammarScopes: ['text.html.handlebars', 'source.hbs', 'source.handlebars']

  scope: 'file'

  lintOnFly: true

  regex: XRegExp(
    'Parse error on line (?<line>[0-9]+)+:\n' +
    '[^\n]*\n' +
    '[^\n]*\n' +
    '(?<message>.*)'
  )

  lint: (textEditor) ->

    return new Promise (resolve, reject) =>

      messages = []
      bufferText = textEditor.getText()

      try
        Handlebars.precompile bufferText, {}

      catch err
        XRegExp.forEach err.message, @regex, (match) =>

          messages.push {
            type: 'Error'
            text: match.message
            filePath: textEditor.getPath()
            range: @lineRange match.line - 1, bufferText
          }

      resolve(messages)

  lineRange: (lineIdx, bufferText) ->

    line = bufferText.split(/\n/)[lineIdx] or ''
    pre = String line.match /^\s*/

    return [[lineIdx, pre.length], [lineIdx, line.length]]
