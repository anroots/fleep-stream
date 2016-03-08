Fleep = require './fleep'
events = require 'events'
Handler = require './handler'

if not process.env.FLEEP_EMAIL or not process.env.FLEEP_PASSWORD
  console.error 'FLEEP_EMAIL and FLEEP_PASSWORD environment variables are required.'
  process.exit()

emitter = new events.EventEmitter
fleep = new Fleep emitter

handler = new Handler
handler.attach emitter

fleep.login process.env.FLEEP_EMAIL, process.env.FLEEP_PASSWORD

emitter.on 'login.complete', (client) ->
  console.info 'Listening for Fleep events...'
  fleep.poll()

