PrivatePub.subscribe "/games/new", (data, channel) ->
  currentUserId = parseInt($('#current_user').val())
  if currentUserId == data.opponent_id
    alert(data.initiator_name + ' wants to play a game with you!')
    $.ajax "/games/#{data.game.id}/opponent_decision",
      type: 'POST'
      dataType: 'html'
      data: { answer: true, opponent_id: data.opponent_id, game_id: data.game.id, initiator_id: data.initiator_id }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(errorThrown)
      success: (data, textStatus, jqXHR) ->
        window.location.replace data

PrivatePub.subscribe "/users/new", (data, channel) ->
  userName = data.user.name
  userId = data.user.id
  window.addUser(userId, userName)

PrivatePub.subscribe "/users/availability", (data, channel) ->
  userId = data.user.id
  availability = data.user.availabile
  userName = data.user.name
  if availability == true
    window.addUser(userId, userName)
  else if availability == false
    window.removeUser(userId)

window.addUser = (userId, userName) ->
  $("#opponents").append("<li id=#{userId}><a href='/games/new?opponent_id=#{userId}'>#{userName}</a></li>")
  if $('li').length == 1
    $("#users-present").show()
    $("#users-absent").hide()

window.removeUser = (userId) ->
  $("li##{userId}").remove()
  if $('li').length == 0
    $("#users-present").hide()
    $("#users-absent").show()

window.nameListed = (userId, elements) ->
  if userId not in elements
    window.location.replace('/')

window.updateAvailability = (userId, availability, path) ->
  $.ajax "/users/#{userId}/update_availability",
    type: 'POST'
    dataType: 'html'
    data: { availability: availability }
    success: ->
      window.location.replace path

