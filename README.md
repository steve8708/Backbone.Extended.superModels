# Backbone.Extended.superModals

Maximum performance nested models, two-way 1-n and n-n relations, and nested model/collection event bubbling.

Inspired by [backbone-relational](https://github.com/PaulUithol/Backbone-relational),
[backbone-associations](http://dhruvaray.github.io/backbone-associations/),
[backbone-nested](https://github.com/afeld/backbone-nested), and
[batman.js](http://batmanjs.com/)

```coffeescript

model.set 'activePerson', name: { first: 'john', last: 'doe' }
model.get 'activePerson.name.first' # -> 'john'

# Supermodels automatically detects that PeopleCollection is a collection
# so is defined as a 'many' relationship
model.addRelation 'people', PeopleCollection

# Nested getting and setting with collections
model.set 'people', [ name: { first: 'charles', last: 'oreily' } ]
model.get 'people' # => PeopleCollection with one model

# Nested getting and setting with collections and models + objects
model.set 'people[0].name.first', 'charlie'
model.get 'people[0].name.last' # -> 'oreily'

# Nested event binding
model.on 'change:people[0].name', ->
model.on 'change:people[*].name.last', ->
model.on 'add:people', ->
model.on 'remove:people', ->

# Model add and remove methods (for nested collections)
model.add 'people', name: first: 'jane', last: 'doe'
model.remove 'people[0]'

```

Documentation coming soon...
