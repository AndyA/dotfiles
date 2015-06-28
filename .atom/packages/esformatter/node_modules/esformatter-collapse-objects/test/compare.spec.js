//jshint node:true, eqnull:true
/*global describe, it, before*/
'use strict';

var esformatter = require('esformatter');
var fs = require('fs');
var collapseObjects = require('../');
var expect = require('chai').expect;


describe('compare input/output', function() {
  beforeEach(function() {
    esformatter.register(collapseObjects);
    this.config = {
      preset: 'default',

      lineBreak: {
        before: {
          ArrayExpressionClosing: 1
        },
        after: {
          ArrayExpressionOpening: 1,
          ArrayExpressionComma: 1
        }
      },

      collapseObjects: {
        ObjectExpression: {},
        ArrayExpression: {}
      }
    }
  });

  ['objects', 'arrays'].forEach(function (type) {
    describe('deep ' + type, function() {
      it('does not collapse beyond the max depth', function() {
        var input = getFile(type, 'input-depth.js');
        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-depth.js'));
      });

      it('ignores maxDepth if -1', function () {
        var input = getFile(type, 'input-depth.js');
        this.config.collapseObjects.ArrayExpression.maxDepth = -1;
        this.config.collapseObjects.ObjectExpression.maxDepth = -1;

        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-depth-negative.js'));
      })
    });

    describe('line lengths', function() {
      it('doesnt collapse long lines', function() {
        var input = getFile(type, 'input-linelength.js');
        this.config.collapseObjects.ObjectExpression.maxLineLength = 30;
        this.config.collapseObjects.ArrayExpression.maxLineLength = 30;
        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-linelength.js'));
      });
    });

    describe('keycounts', function() {
      it('doesnt collapse beyond a key count', function() {
        var input = getFile(type, 'input-keycount.js');
        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-keycount.js'));
      });

      it('never collapses with a key count of 0', function() {
        var input = getFile(type, 'input-keycount.js');
        this.config.collapseObjects.ArrayExpression.maxKeys = 0;
        this.config.collapseObjects.ObjectExpression.maxKeys = 0;
        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-keycount-0.js'));
      });

      it('ignores key count when -1', function() {
        var input = getFile(type, 'input-keycount.js');
        this.config.collapseObjects.ArrayExpression.maxKeys = -1;
        this.config.collapseObjects.ObjectExpression.maxKeys = -1;
        var output = esformatter.format(input, this.config);

        expect(output).to.be.eql(getFile(type, 'output-keycount-negative.js'));
      });

      it('supports whiteSpace settings', function() {
        var input = getFile(type, 'input-keycount.js');
        var config = Object.create(this.config);
        config.whiteSpace = {
          before: {
            ArrayExpressionClosing: 0,
            ArrayExpressionComma: 1,
            ObjectExpressionClosingBrace: 0,
            PropertyName: 0
          },
          after: {
            ArrayExpressionComma: 0,
            ArrayExpressionOpening: 0,
            ObjectExpressionOpeningBrace: 0,
            PropertyValue: 1
          }
        };
        var output = esformatter.format(input, config);

        expect(output).to.be.eql(getFile(type, 'output-keycount-2.js'));
      });
    });
  });
});

function getFile(type, name) {
  return fs.readFileSync('test/compare/' + type + '/' + name).toString();
}
