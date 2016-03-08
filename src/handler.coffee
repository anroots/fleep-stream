striptags = require 'striptags'
colors = require 'colors'

class Handler
  constructor: ->
    @conversations = {}
    @contacts = {}

  attach: (emitter) ->
    emitter.on 'message', (event) =>
      topic = @conversations[event.conversation_id].bgBlue.white
      contact = @contacts[event.profile_id].white.bgBlack
      message = striptags(event.message)
      console.log "#{topic}  #{contact} #{message}"

    emitter.on 'conv', (event) =>
      return if not event.topic
      @conversations[event.conversation_id] = event.topic

    emitter.on 'contact', (event) =>
      @contacts[event.account_id] = event.display_name


module.exports = Handler