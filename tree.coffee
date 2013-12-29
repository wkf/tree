_ = require '../SavantESM/node_modules/lodash'
t0 = a: 1, b: [1,2,3,4]
t1 = a: 2, b: {c: 1}

class Tree
  @isLeaf: (b) ->
    typeof b isnt 'object'

  @keys: (b) ->
    if b instanceof Array
      [0...b.length]
    else if b instanceof Object
      Object.keys(b)

  @branch: (b) ->
    if b instanceof Array
      []
    else if b instanceof Object
      {}

  @empty: (b) ->
    if b instanceof Array
      !b.length
    else if b instanceof Object
      !Object.keys(b).length
    else if typeof b is 'undefined'
      true

  @get: (b, k) ->
    b[k]

trees = (Ts...) ->

  anyLeaves = (ts) ->
    _.any ts, (t, i) ->
      Ts[i].isLeaf(t)

  keys = (ts) ->
    _(ts)
      .map (t, i) ->
        Ts[i].keys(t)
      .flatten()
      .uniq()
      .value()

  branches = (ts, k) ->
    _.map ts, (t, i) ->
      Ts[i].get(t, k)

  branch = (ts) ->
    Ts[0].branch(ts[0])

  empty = (v) ->
    Ts[0].empty(v)

  map = (ts..., fn, k) ->
    if anyLeaves(ts)
      fn ts..., k
    else
      _.reduce keys(ts), ((b, k) ->
        b[k] = r unless empty(r = map branches(ts, k)..., fn, k)
        b
      ), branch(ts)

  reduce = (m, ts..., fn, k) ->
    if anyLeaves(ts)
      fn m, ts..., k
    else
      _.reduce keys(ts), ((m, k) ->
        reduce m, branches(ts, k)..., fn, k
      ), m

  map: (ts..., fn) ->
    r unless empty(r = map ts..., fn, undefined)
  reduce: (m, ts..., fn) ->
    reduce(m, ts..., fn, undefined)

console.log trees(Tree, Tree).map t0, t1, (l0, l1, k) ->
  # console.log l0, l1, k
  # l1 if l0
  l0

console.log trees(Tree, Tree).reduce false, t0, t1, (m, l0, l1, k) ->
  # console.log m, l0, l1, k
  !!(l0 and l1)

