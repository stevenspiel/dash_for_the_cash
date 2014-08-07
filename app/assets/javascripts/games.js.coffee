window.playerReady = ->
  $('.ready-button').hide()
  $('#waiting').show()

window.notice = (message) ->
  $('#notice').text(message)

window.move = (playerId, position) ->
  player = $("[id^='#{playerId}']").attr('class').split('-')[0]
  $(".#{player}-position").removeClass("#{player}-position")
  $("##{playerId}_#{position}").addClass("#{player}-position")

window.base = (playerId, basePosition) ->
  if parseInt(basePosition) != 0
    player = $("[id^='#{playerId}']").attr('class').split('-')[0]
    for position in [1..basePosition]
      $("##{playerId}_#{position}").addClass("#{player}-base")

window.baseReset = (playerId, basePosition) ->
  player = $("[id^='#{playerId}']").attr('class').split('-')[0]
  for position in [1..12]
    $("##{playerId}_#{position}").removeClass("#{player}-base")

window.traps = (playerId, trapPosition) ->
  $("##{playerId}_#{trapPosition}").siblings().addClass("trap")

window.removeTrap = (playerId, trapPosition) ->
  $("##{playerId}_#{trapPosition}").siblings().removeClass("trap")
  
window.trapsReset = (playerId, basePosition) ->
  for position in [1..12]
    $("##{playerId}_#{position}").removeClass("trap")

window.disableButtons = (playerId, position, basePosition) ->


window.restartRound = ->
  $('#timer-display').text()
  window.beginRound()

window.beginRound = ->
  # READY GO! text
  $('button').removeClass("disabled")
  window.resetRound()
  window.countdownAndSubmit()

window.resetRound = ->
  $('#instructions-overlay').hide()
  $('button').removeClass('selected')

window.countdownAndSubmit = ->
  time = 7
  $timer = $('#timer-display')
  $timer.show().text(time)

  window.gamePlayTime = setInterval ->
    time -= 1
    if time >= 0
      $timer.text(time)
      if time == 0
        $timer.text("")
        window.submitMoves()
  , 1000

window.submitMoves = ->
  gameId = $("button:first").data('game-id')
  playerId = $("button:first").data('played-by')
  opponentId = $("button:first").data('played-on')

  if $("button.selected").length != 1
    move = "fail"
  else
    move = $("button.selected").attr('id')

  $.ajax "/games/#{gameId}/play",
    type: 'POST'
    dataType: 'html'
    data: { playerId: playerId, opponentId: opponentId, move: move }
    success: ->
      # nothing
    error: ->
