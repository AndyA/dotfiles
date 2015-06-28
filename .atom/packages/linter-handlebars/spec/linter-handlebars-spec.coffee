{ resetConfig } = require './test-helper'

LinterHandlebarsProvider = require '../lib/linter-handlebars-provider'

describe "Lint handlebars", ->
  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('linter-handlebars')
    resetConfig()

  describe "missing open block", ->
    it 'retuns one error', ->

      waitsForPromise ->
        atom.workspace.open('./files/error-missing-open.hbs')
          .then (editor) -> LinterHandlebarsProvider.lint(editor)
          .then (messages) ->

            expect(messages.length).toEqual(1)
            expect(messages[0].text).toEqual("Expecting 'EOF', got 'OPEN_ENDBLOCK'")
            expect(messages[0].range).toEqual([[2, 0], [2, 7]])
