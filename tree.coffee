_ = require 'lodash'

t0 = a: 1, b: [1,2,3,4]
t1 = a: 2, b: {c: 1}

class Tree
  @isLeaf: (b) ->
    not _.isObject(b)

  @keys: (b) ->
    if _.isArray(b)
      [0...b.length]
    else if _.isObject(b)
      Object.keys(b)

  @branch: (b) ->
    if _.isArray(b)
      []
    else if _.isObject(b)
      {}

  @empty: (b) ->
    if _.isArray(b)
      false
    else if _.isObject(b)
      !Object.keys(b).length
    else
      _.isUndefined(b)

  @get: (b, k) ->
    b[k]

  @set: (b, k, v) ->
    return b if _.isArray(b) and not _.isNumber(k)

    b[k] = v unless @empty(v)
    b

trees = (Ts...) ->
  T = (i) ->
    Ts[i] or _.last(Ts)

  anyLeaves = (ts) ->
    _.any ts, (t, i) ->
      T(i).isLeaf(t)

  keys = (ts) ->
    _(ts)
      .map (t, i) ->
        T(i).keys(t)
      .flatten()
      .uniq()
      .value()

  branches = (ts, k) ->
    _.map ts, (t, i) ->
      T(i).get(t, k)

  branch = (ts) ->
    T(0).branch(ts[0])

  empty = (v) ->
    T(0).empty(v)

  mapper_ = (ts, fn) ->
    (b, k) ->
      T(0).set(b, k, map branches(ts, k)..., fn, k)

  reducer_ = (ts, fn) ->
    (m, k) ->
      reduce m, branches(ts, k)..., fn, k

  map = (ts..., fn, k) ->
    if anyLeaves(ts)
      fn ts..., k
    else
      _.reduce keys(ts), mapper_(ts, fn), branch(ts)

  reduce = (m, ts..., fn, k) ->
    if anyLeaves(ts)
      fn m, ts..., k
    else
      _.reduce keys(ts), reducer_(ts, fn), m

  map: (ts..., fn) ->
    r unless empty(r = map ts..., fn, undefined)

  reduce: (m, ts..., fn) ->
    reduce(m, ts..., fn, undefined)

console.log trees(Tree, Tree).map t0, t1, (l0, l1, k) ->
  # console.log l0, l1, k
  # l1 if l0
  l1

console.log trees(Tree, Tree).reduce false, t0, t1, (m, l0, l1, k) ->
  # console.log m, l0, l1, k
  !!(l0 and l1)

# Trees.type(Schema, Resource).reduce false, schema, resource, (valid, schemaNode, resourceNode, key) ->

# Walk(schema, resource).as(Schema, Resource).reduce true, (v, sN, rN, k) ->
# w = Walk.as(Schema, Resource)
# W(schema, resource).reduce true

# (schema, resource)

# _.all ps, Project.isValid

# _(ps)
#   .map Project.parse
#   .test ->
#     if @all Project.valid
#       @map (p) ->
#         p.name
#     else
#       []
#   .value()

# _.map ps, Project.parse
