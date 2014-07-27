window.turnTo = (playerId) ->
  yourId = $(".you-field").attr('id').split('_')[0]
  if parseInt(playerId) == parseInt(yourId)
    $("input[type='submit']").prop('disabled',false)
  else
    $("input[type='submit']").prop('disabled',true)

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
