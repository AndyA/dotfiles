# esformatter-collapse-objects

[esformatter](https://github.com/millermedeiros/esformatter) plugin for
conditionally collapsing object and array literals.

## Features
* Conditionally formats literals on a single line, while leaving others expanded
* Respects your original esformatter whitespace settings
* Conditions include a **max line-length**, a **max number of keys/elements** in the literal,
  a **max depth** of the literal (when it contains other objects or arrays), or when
  it contains complex expressions like inline functions.


## Usage

install it:

```sh
npm install esformatter-collapse-objects
```

and something like this to your esformatter config file:

```json
{
  "plugins": [
    "esformatter-collapse-objects"
  ]
}
```

### Important: Update your esformatter config

This plugin works by relying on esformatter expanding the relevant expressions,
and conditionally collapsing them back down to a single line. Therefore, you
need to have esformatter expand them in the first place (esformatter defaults to
expanding object literals, but not array literals).

Add the following to your esformatter config when collapsing arrays:

```json
"lineBreak": {
  "before": {
    "ArrayExpressionClosing": 1
  },
  "after": {
    "ArrayExpressionOpening": 1,
    "ArrayExpressionComma": 1
  }
},
```

Since expressions were collapsed, you might be surprised that some appear as
`{a:b,c:d}`. This is because esformatter defaults are tuned toward expanded
expressions. Try merging the following into your config for whitespace before
each property in an object:

```json
{
  "whiteSpace": {
    "before": {
      "PropertyName": 1
    }
}
```

## Options

The following is the default configuration for the plugin:

```js

{
  ObjectExpression: {
    maxLineLength: 80,
    maxKeys: 3,
    maxDepth: 2,
    forbidden: [
      'FunctionExpression'
    ]
  },
  ArrayExpression: {
    maxLineLength: 80,
    maxKeys: 3,
    maxDepth: 2,
    forbidden: [
      'FunctionExpression'
    ]
  }
}
```

Options map esprima AST Node types (in this case both ObjectExpression and
ArrayExpression) to their respective options, just like indentation in
esformatter.

### maxLineLength (int)
If the literal exceeds a certain number of columns collapsed, it will *not* be collapsed.


Use a `maxLineLength` of `-1` to ignore this option.

### forbidden (Array)
You can also avoid collapsing literals under certain conditions
like a maximum number of keys, or when they contain other nodes like
FunctionExpression.

```js
[function foo() { return 'bar' }]
```

for example, could never occur since FunctionExpression is forbidden when
trying to collapse a literal if this is set.


Use a `forbidden` of `[]` to ignore this option.

### maxDepth (int)
You can also limit the depth of nested literals. All literals begin at a depth
of 1, and *for performance reasons setting a maxDepth of greater than 3 is
ignored*. For example, `{foo: { bar: 'baz' }}` has a depth of two and would be
collapsed if the maxDepth is 2 or greater.


Use a `maxDepth` of `-1` to opt out of this functionality.

## JavaScript API

Register the plugin and call esformatter like so:

```js
// register plugin
esformatter.register(require('esformatter-collapse-objects'));
// pass options as second argument
var output = esformatter.format(str, options);
```

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).

## Credits

Huge thanks to Jörn Zaefferer, who published [an MIT-licensed gist](https://gist.github.com/jzaefferer/23bef744ffea751b2668)
which serves as the foundation for this module.
