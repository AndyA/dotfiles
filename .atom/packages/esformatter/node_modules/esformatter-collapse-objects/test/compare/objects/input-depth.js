"use strict";

var nestedTwo = {
  foo: {
    bar: 'baz'
  }
};

var nestedThree = {
  foo: {
    bar: {
      baz: [1, 2, 3]
    }
  }
};

var nestedTwoEmpty = {
  foo: {}
}

var nestedFunction = {
  foo: function() {
    return 'bar';
  }
}
