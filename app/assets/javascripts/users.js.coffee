$ ->
  $('#tier').change (e) ->
    tier = $(e.target).val()
    $('#selected_tier').val(tier)
    
  $('#become-available').click (e) ->
    $('#finding-player-overlay').show()
    interval = setInterval ->
      $('#find-opponent').submit()
      clearInterval(interval)
    , 3200
