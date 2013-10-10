# Setup - - - - - - - - - - - - - - - - - - - - - - - - - -

requireCompatible = typeof require is 'function'
isNode = typeof module isnt 'undefined'

Backbone = @Backbone or requireCompatible and require 'backbone'
_ = @_ or requireCompatible and require 'lodash'

config =
  dontRemoveAttributes: false
  dontStripElements: false
  logExpressionErrors: true
  logCompiledTemplate: false

pathSplitter = /[\.\[\]]/g


# Supermodel - - - - - - - - - - - - - - - - - - - - - - - -

superModel = (context, config = {}, attributes, options) ->
  @relations = _.extend {}, @relations, options.relations

  for key, value of @relations
    @addRelation key, value

  set: (key, value, options) ->
    if typeof key isnt 'string'
      @_set key, value
    else
      attrs = {}
      attrs[key] = value
      @_set attrs, options

  _set: (attributes, options) ->
    _super = @_super or Backbone.Model.prototype

    for key, value of attributes
      path = aplitPath key

      split = splitPath pathSplitter
      trailingKey = split.pop()

      if split.length
        base = @get split.join '.'
        if base
          if base.set
            base.set trailingKey, value
          else
            base[trailingKey] = value
      else
        if @relations[key]
          # FIXME: have special option to reset model vs set multiple properties
          if @attributes[key]
            @attributes[key].set key, value
          else
            _super.set @prepareRelation(@relation[key]) value
        else
          _super.set key, value
      @

  get: (key) ->
    res = @
    path = splitPath key

    for item, index in path
      return false unless res

      collection = typeof res.at is 'function'
      modelOrCollection = typeof res.get is 'function'

      if collection and isNumberString path
        res = res.at item

      if collection and not res or modelOrCollection
        res = res.get item
      else
        res = res[item]

  toJSON: (args...) ->
    refs = []
    attrs = _.clone @attributes

    for key, value of attrs
      if value and value.toJSON
        attrs[key] = value.toJSON args...

    attrs

  cleanup: ->

  addRelation: (key, value, reverseKey) ->
    valueIsCollection = isCollection value
    @relations[key] =
      type: if valueIsCollection then 'many' else 'one'
      collection: value if valueIsCollection
      model: is valueIsCollection then value::model else value
      constructor: value
      reverseKey: reverseKey

    @trigger 'removeRelation', key, @
    @trigger "removeRelation:#{key}", @

  prepareRelation: (item, attrs) ->
    res = new item.constructor attrs

    if item.reverseRelation
      res.set item.reverseRelation, @

    # Listen to and forward changes
    # TODO:
    #   foo[0]bar
    #   foo[*]bar
    #
    #   add:foo
    #   remove:foo
    #   reset:foo
    @listenTo res, 'all', (eventName, args...) =>
      if eventName.indexOf('change:') is 0
        @trigger "change:#{ item.key }.#{ eventName.substring 7 }", args...


  removeRelation: (key) ->
    delete @relations[key]
    @trigger 'removeRelation', key, @
    @trigger "removeRelation:#{key}", @


# Helpers - - - - - - - - - - - - - - - - - - - - - - - - -

isCollection = (value) ->
  isCollection = false
  parent = value
  while parent = parent.__super__
    if parent and parent.initialize is Backbone.Collection::initialize
      isCollection = true
  isCollection

isNumberString = (string) ->
  if not isNaN num = Number res
    num
  else
    res

splitPath = (key) ->
  key.split pathSplitter
  # key.split(pathSplitter).map (item) ->
  #   item.trim().replace /'|"/, ''


# Export - - - - - - - - - - - - - - - - - - - - - - - - - -

# This is managed by grunt build and comes from package.json
superModel.VERSION = '0.0.1'
superModel.config = config

if Backbone and Backbone.extensions and Backbone.extensions.view
  Backbone.extensions.view.superModel = superModel

if isNode
  module.exports = superModel

if requireCompatible and typeof define is 'function'
  define 'live-templates', ['backbone', 'backbone.extended'] -> superModel

if @Base and @Base.plugins and @Base.plugins.view
  @Base.plugins.view.superModel = superModel
