Client = require('node-rest-client').Client

clientOptions =
    proxy:
      host: process.env.PROXY_HOST,
      port: process.env.PROXY_PORT,
      tunnel: true

fleepClient = new Client clientOptions

fleepClient.registerMethod 'login', 'https://fleep.io/api/account/login', 'POST'
fleepClient.registerMethod 'poll', 'https://fleep.io/api/account/poll', 'POST'
fleepClient.registerMethod 'sync', 'https://fleep.io/api/account/sync', 'POST'
fleepClient.registerMethod 'sync_conversations', 'https://fleep.io/api/account/sync_conversations', 'POST'

class Fleep
  constructor: (emitter) ->
    @ticket
    @cookie
    @horizon = 0
    @emitter = emitter

  poll: ->
    args =
      data:
        ticket: @ticket
        event_horizon: @horizon
      headers:
        'Content-Type': 'application/json'
        'Cookie': @cookie
    
    fleepClient.methods.poll args, (data) =>
      @horizon = data.event_horizon
      for event in data.stream
        @emitter.emit event.mk_rec_type, event, @
      @poll args

  sync: (sync_cursor = null) ->
    args =
      data:
        ticket: @ticket
        sync_cursor: sync_cursor
      headers:
        'Content-Type': 'application/json'
        'Cookie': @cookie

    fleepClient.methods.sync_conversations args, (data) =>
      for event in data.stream
        @emitter.emit event.mk_rec_type, event, @ unless event.mk_rec_type is 'message'
      if data.sync_cursor
        @sync data.sync_cursor
      
  login: (email, password) ->
    args =
      data:
        email: email
        password: password
      headers:
        'Content-Type': 'application/json'
    
    fleepClient.methods.login args, (data, response) =>

      @ticket = data.ticket
      @cookie = response.headers['set-cookie'][0]
      
      args =
        data:
          ticket: @ticket
        headers:
          'Content-Type': 'application/json'
          'Cookie': @cookie
      
      @sync()      

      fleepClient.methods.sync args, (data) =>
        @horizon = data.event_horizon
        @emitter.emit 'login.complete', @

module.exports = Fleep