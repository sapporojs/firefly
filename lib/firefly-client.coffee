class Cursor
  constructor: ->
    color = Cursor.randomColor().join(",")
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

Cursor.cursors = {}

Cursor.randomColor = ->
  for _ in [ "red", "green", "blue" ]
    Math.floor Math.random() * 256

Cursor.add = (id) ->
  @cursors[id] = new Cursor(id).appear()

Cursor.get = (id) ->
  @cursors[id] ||= @add(id)

Cursor.remove = (id) ->
  cursor = @cursors[id]
  cursor?.remove()
  delete cursor

jQuery ($) ->
  socket = io.connect("http://tricknotes.no.de/")
  socket.on "info", (data) ->
    console.log JSON.stringify(data)

  socket.on "entry cursor", (data) ->
    Cursor.add data.id

  socket.on "move cursor", (data) ->
    screen = data.screen
    cursor = Cursor.get(data.id)
    cursor.update screen.x * w.width() / screen.width, screen.y * w.height() / screen.height

  socket.on "disconnect", (data) ->
    Cursor.remove data.id

  w = $(window)
  w.mousemove (e) ->
    socket.emit "mouse position",
      width: w.width()
      height: w.height()
      x: e.clientX
      y: e.clientY

  counter = $("<div />")
  counter.attr("align", "center").css(
    "font-size": "3em"
    "line-height": "1"
    top: 0
    left: w.width() - counter.width()
    width: 50
    height: 50
    "border-radius": 25
    position: "fixed"
    color: "white"
    "background-color": "rgb(128,30,0)"
  ).css("background-color", "rgba(128,30,0,0.4)").appendTo document.body

  notifyCount = (count) ->
    counter.css("left", w.width() - counter.width()).text(count).fadeIn 3000, ->
      counter.fadeOut 2000

  socket.on "change count", (data) ->
    notifyCount data.clientCount
