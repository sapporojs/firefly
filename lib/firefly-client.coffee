class FireFly
  constructor: ->
    color = FireFly.randomColor().join(",")
    @body = jQuery("<div />").css(
      height: 14
      width: 14
      "border-radius": 7
      position: "fixed"
      "background-color": "rgb(#{color})"
    ).css("background-color", "rgba(#{color}, 0.3)")

  appear: ->
    @body.appendTo document.body
    this

  update: (x, y) ->
    @body.css
      left: x
      top: y

  remove: ->
    @body.remove()

FireFly.cursors = {}

FireFly.randomColor = ->
  for _ in [ "red", "green", "blue" ]
    Math.floor Math.random() * 256

FireFly.add = (id) ->
  @cursors[id] = new FireFly(id).appear()

FireFly.get = (id) ->
  @cursors[id] ||= @add(id)

FireFly.remove = (id) ->
  cursor = @cursors[id]
  cursor?.remove()
  delete cursor

# set listener for counter changed event
window.counterListener = (count) ->
  # noop

jQuery ($) ->
  socket = io.connect("http://tricknotes.no.de/")
  socket.on "info", (data) ->
    console.log JSON.stringify(data)

  socket.on "entry cursor", (data) ->
    FireFly.add data.id

  socket.on "move cursor", (data) ->
    screen = data.screen
    cursor = FireFly.get(data.id)
    cursor.update screen.x * w.width() / screen.width, screen.y * w.height() / screen.height

  socket.on "disconnect", (data) ->
    FireFly.remove data.id

  w = $(window)
  w.mousemove (e) ->
    socket.emit "mouse position",
      width: w.width()
      height: w.height()
      x: e.clientX
      y: e.clientY

  socket.on "change count", (data) ->
    window.counterListener data.clientCount
