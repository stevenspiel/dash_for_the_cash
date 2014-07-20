PrivatePub.subscribe "/users/new", (data, channel) ->
  userName = data.user.name
  userId = data.user.id
  $("#opponents").append('<li><a href="/games/new?opponent_id='+userId+'">'+userName+'</a></li>')
  $("#users-present").show()
  $("#users-absent").hide()

PrivatePub.subscribe "/games/new", (data, channel) ->
  currentUserId = parseInt($('#current_user').val())
  answer = false

  if currentUserId != data.initiator_id
    if confirm(data.initiator_name + ' wants to play a game with you. Accept?')
      answer = true
    $.ajax "/games/#{data.game.id}/opponent_decision",
      type: 'POST'
      dataType: 'html'
      data: { answer: answer, opponent_id: data.opponent_id, game_id: data.game.id, initiator_id: data.initiator_id }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)
        console.log(errorThrown)
        console.log(errorThrown)
      success: (data, textStatus, jqXHR) ->
        window.location.replace data
