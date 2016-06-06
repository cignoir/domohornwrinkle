App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    new_item = $(data['message']).hide()
    $('#container').prepend(new_item)
    new_item.fadeIn('slow')

  speak: (message) ->
    @perform 'speak', message: message
