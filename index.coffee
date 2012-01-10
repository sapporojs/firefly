fs = require('fs')
coffee = require('coffee-script')

firefly_client_source = fs.readFileSync(__dirname + '/lib/firefly-client.coffee').toString()
firefly_client_source_compiled = coffee.compile(firefly_client_source)

port = Number(process.env.PORT || 80)

require('zappa') port, ->

  @get '/js/firefly.js': ->
    @send(firefly_client_source_compiled)

  @on 'connection': ->
    @broadcast 'entry cursor', { @id }

  @on 'mouse position': ->
    @broadcast 'move cursor', { @id, screen: @data }

  @on 'disconnect': ->
    @broadcast 'disconnect', { @id }

  clientCount = 0

  @on 'connection': ->
    clientCount += 1
    @broadcast 'change count', { clientCount }
    @emit 'change count', { clientCount }

  @on 'disconnect': ->
    clientCount -= 1
    @broadcast 'change count', { clientCount }
