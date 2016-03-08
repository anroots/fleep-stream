// Generated by CoffeeScript 1.10.0
(function() {
  var Client, Fleep, fleepClient;

  Client = require('node-rest-client').Client;

  fleepClient = new Client;

  fleepClient.registerMethod('login', 'https://fleep.io/api/account/login', 'POST');

  fleepClient.registerMethod('poll', 'https://fleep.io/api/account/poll', 'POST');

  fleepClient.registerMethod('sync', 'https://fleep.io/api/account/sync', 'POST');

  fleepClient.registerMethod('sync_conversations', 'https://fleep.io/api/account/sync_conversations', 'POST');

  Fleep = (function() {
    function Fleep(emitter) {
      this.ticket;
      this.cookie;
      this.horizon = 0;
      this.emitter = emitter;
    }

    Fleep.prototype.poll = function() {
      var args;
      args = {
        data: {
          ticket: this.ticket,
          event_horizon: this.horizon
        },
        headers: {
          'Content-Type': 'application/json',
          'Cookie': this.cookie
        }
      };
      return fleepClient.methods.poll(args, (function(_this) {
        return function(data) {
          var event, i, len, ref;
          _this.horizon = data.event_horizon;
          ref = data.stream;
          for (i = 0, len = ref.length; i < len; i++) {
            event = ref[i];
            _this.emitter.emit(event.mk_rec_type, event, _this);
          }
          return _this.poll(args);
        };
      })(this));
    };

    Fleep.prototype.sync = function(sync_cursor) {
      var args;
      if (sync_cursor == null) {
        sync_cursor = null;
      }
      args = {
        data: {
          ticket: this.ticket,
          sync_cursor: sync_cursor
        },
        headers: {
          'Content-Type': 'application/json',
          'Cookie': this.cookie
        }
      };
      return fleepClient.methods.sync_conversations(args, (function(_this) {
        return function(data) {
          var event, i, len, ref;
          ref = data.stream;
          for (i = 0, len = ref.length; i < len; i++) {
            event = ref[i];
            if (event.mk_rec_type !== 'message') {
              _this.emitter.emit(event.mk_rec_type, event, _this);
            }
          }
          if (data.sync_cursor) {
            return _this.sync(data.sync_cursor);
          }
        };
      })(this));
    };

    Fleep.prototype.login = function(email, password) {
      var args;
      args = {
        data: {
          email: email,
          password: password
        },
        headers: {
          'Content-Type': 'application/json'
        }
      };
      return fleepClient.methods.login(args, (function(_this) {
        return function(data, response) {
          _this.ticket = data.ticket;
          _this.cookie = response.headers['set-cookie'][0];
          args = {
            data: {
              ticket: _this.ticket
            },
            headers: {
              'Content-Type': 'application/json',
              'Cookie': _this.cookie
            }
          };
          _this.sync();
          return fleepClient.methods.sync(args, function(data) {
            _this.horizon = data.event_horizon;
            return _this.emitter.emit('login.complete', _this);
          });
        };
      })(this));
    };

    return Fleep;

  })();

  module.exports = Fleep;

}).call(this);
