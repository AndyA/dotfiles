var defaults = require('defaults-deep');
var rocambole = require('rocambole');
var _tk = require('rocambole-token');
var _ws = require('rocambole-whitespace');

var MAX_DEPTH = 3;

var options;
var defaultOptions = {
  maxLineLength: 80,
  maxKeys: 3,
  maxDepth: 2,
  forbidden: [
    'FunctionExpression'
  ]
};

module.exports = {
  setOptions: function(opts) {
    options = defaults(opts.collapseObjects || {}, {
      ObjectExpression: defaultOptions,
      ArrayExpression: defaultOptions
    });
    _ws.setOptions(opts && opts.whiteSpace);
  },

  transformAfter: function(ast) {
    rocambole.recursive(ast, transform);
  }
};

function transform(node) {
  // Don't try to collapse non-objects or non-arrays
  if (!~Object.keys(options).indexOf(node.type)) return;

  var nodeOptions = options[node.type];

  var parentType = node.parent.type;
  if (parentType === 'Property' || parentType === 'ArrayExpression') {
    return;
  }

  // It collapses objects that are short enough
  // 0 indicates measurement failed, ignore
  if (nodeOptions.maxLineLength >= 0) {
    var length = expectedLength(node);
    if (length === 0 || length > nodeOptions.maxLineLength) {
      return;
    }
  }

  // if maxKeys is less than 0, ignore it completely (opt-out)
  if (nodeOptions.maxKeys >= 0) {
    if (getProperties(node).length > nodeOptions.maxKeys) {
      return;
    }
  }

  // if maxDepth is less than 0, ignore it completely (opt-out)
  if (nodeOptions.maxDepth >= 0) {
    if (exceedsDepth(node, nodeOptions.maxDepth)) {
      return;
    }
  }

  for (var i = 0; i < getProperties(node).length; i++) {
    if (~nodeOptions.forbidden.indexOf(getValueAt(node, i).type)) {
      return;
    }
  }

  // if none of the above returns, collapse the whitespace.
  collapse(node);
  limitSpaces(node);
}

function exceedsDepth(root, max) {
  var depth = 0;
  var depths = {};
  rocambole.moonwalk(root, function (node) {
    // don't count objects more than once that we've
    // seen at this depth level
    if (isComposite(node) && !depths[node.depth]) {
      depths[node.depth] = true;
      depth++;
    }
  })

  return depth > max;
}

function isComposite(node) {
  return (node.type === 'ObjectExpression' || node.type === 'ArrayExpression');
}

function getProperties(node) {
  return node.properties || node.elements;
}

function getValueAt(node, key) {
  if (node.properties) {
    return node.properties[key].value;
  } else if (node.elements) {
    return node.elements[key];
  }
}

// Below from https://gist.github.com/jzaefferer/23bef744ffea751b2668
// Copyright Jörn Zaefferer; licensed MIT
function collapse(node) {
  // This one seems short
  _tk.eachInBetween(node.startToken, node.endToken, function(token) {
    if (_tk.isBr(token)) {
      // Remove all whitespace/indent after the line break
      var next = token.next;
      while (_tk.isEmpty(next)) {
        _tk.remove(next);
        next = next.next;
      }

      // Remove the line break itself
      _tk.remove(token);
    }
  });
}

function expectedLength(node) {
  var length = 0;

  var startOfTheLine = _tk.findPrev(node.startToken, 'LineBreak');

  // No linebreak indicates first line of the file, find first token instead
  if (!startOfTheLine) {
    startOfTheLine = _tk.findPrev(node.startToken, function(token) {
      return !token.prev;
    });
  }
  var firstChar = _tk.findNextNonEmpty(startOfTheLine);

  // Need to take into consideration the indent
  _tk.eachInBetween(startOfTheLine, firstChar, function(token) {
    length += String(token.raw || token.value).length;
  });

  var prev;
  _tk.eachInBetween(firstChar, node.endToken, function(token) {
    if (_tk.isEmpty(token)) {

      // Empty tokens are "collapsed" (multiple linebreaks/whitespace becomes
      // a single whitespace)
      length += _tk.isEmpty(prev) ? 0 : 1;
      prev = token;
      return;
    }

    // Don't collapse objects with line comments; block comments should be okay
    if (token.type === 'LineComment') {
      length += 1000;
    }
    length += String(token.raw || token.value).length;
    prev = token;
  });

  if (length === 0) {
    throw new Error('Failed to measure length of object expression: ' + node.toString());
  }

  return length;
}

function limitSpaces(node) {
  if (node.type === 'ArrayExpression') {
    limitArraySpaces(node);
  } else {
    limitObjectSpaces(node);
  }
}

function limitArraySpaces(node) {
  node.elements.forEach(function(el) {
    // sparse arrays have `null` elements
    if (!el) return;

    var prev = _tk.findPrevNonEmpty(el.startToken);
    if (prev.value === ',') {
      _ws.limit(prev, 'ArrayExpressionComma');
    }
  });

  // opening/closing takes precedence over comma rules
  _ws.limitAfter(node.startToken, 'ArrayExpressionOpening');
  _ws.limitBefore(node.endToken, 'ArrayExpressionClosing');
}

function limitObjectSpaces(node) {
  node.properties.forEach(function(prop) {
    _ws.limitBefore(prop.key.startToken, 'PropertyName');
    _ws.limitAfter(prop.key.endToken, 'PropertyName');
    _ws.limitBefore(getValueStart(prop), 'PropertyValue');
    _ws.limitAfter(getValueEnd(prop), 'PropertyValue');
  });

  // opening/closing takes precedence over property rules
  _ws.limitAfter(node.startToken, 'ObjectExpressionOpeningBrace');
  _ws.limitBefore(node.endToken, 'ObjectExpressionClosingBrace');
}

// borrowed from esformatter/lib/hooks/ObjectExpression
function getValueStart(prop) {
  var start = prop.value.startToken;
  return (prop.kind === 'get' || prop.kind === 'set') ?
    start :
    // we need to grab first/last "executable" token to avoid issues (see #191)
    _tk.findNext(_tk.findPrev(start, ':'), _tk.isCode);
}

// borrowed from esformatter/lib/hooks/ObjectExpression
function getValueEnd(prop) {
  // we need to grab next "," or "}" because value might be surrounded by
  // parenthesis which would break the regular logic
  var end = _tk.findNext(prop.value.endToken, [',', '}']);
  return _tk.findPrev(end, _tk.isCode);
}
