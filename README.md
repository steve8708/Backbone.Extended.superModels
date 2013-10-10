# Backbone.Extended.liveTemplates

Maximum performance nested models, two-way relations, and model event bubbling.

Inspired by [backbone-relational](https://github.com/PaulUithol/Backbone-relational),
[backbone-associations](http://dhruvaray.github.io/backbone-associations/),
[backbone-nested](https://github.com/afeld/backbone-nested), and
[batman.js](http://batmanjs.com/)

```coffeescript

model.set 'activePerson', name: { first: 'john', last: 'doe' }
model.get 'activePerson.name.first' # -> 'john'

# Supermodels automatically detects that peoplecollection is a collection
# so is a 'many' relationship
model.addRelation 'people', PeopleCollection

model.set 'people', [ name: first: 'charles', last: 'oreily' ]
model.get 'people' # => PeopleCollection with one model

model.set 'people[0].name.first', 'charles'
model.get 'people[0].name.last'

# Nested event binding
model.on 'change:people[0].name', ->
model.on 'change:people[*].name.last', ->
model.on 'add:people'

model.add 'people', name: first: 'jane', last: 'doe'
model.remove 'people[0]'

```

Documentation coming soon...
