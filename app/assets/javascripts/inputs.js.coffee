#javascript to write input controls
audioSelect = null
videoSelect = null

jQuery =>
  if (!!navigator.userAgent.match(/firefox/i))
    jQuery('#inputs').hide()
  else
    audioSelect = document.querySelector("select#audioSource")
    videoSelect = document.querySelector("select#videoSource")
    if (audioSelect && videoSelect)
      if $('.controller_castings').length > 0
        navigator.getUserMedia = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia
        if typeof MediaStreamTrack isnt "undefined"
          MediaStreamTrack.getSources gotSources

        audioSelect.onchange = audioChanged
        videoSelect.onchange = videoChanged
        start()

gotSources = (sourceInfos) ->
  i = 0

  while i isnt sourceInfos.length
    sourceInfo = sourceInfos[i]
    option = document.createElement("option")
    option.value = sourceInfo.id
    if sourceInfo.kind is "audio"
      option.text = sourceInfo.label or "microphone " + (audioSelect.length + 1)
      audioSelect.appendChild option
    else if sourceInfo.kind is "video"
      option.text = sourceInfo.label or "camera " + (videoSelect.length + 1)
      videoSelect.appendChild option
    else
      console.log "Some other kind of source: ", sourceInfo
    ++i
  return

#
#  return
#errorCallback = (error) ->
#  console.log "navigator.getUserMedia error: ", error
#  return

videoChanged = () ->
  woopra.track "Triggered Change of Video"
  start()

audioChanged = () ->
  woopra.track "Triggered Change of Audio"
  start()

start = () ->
  return if videoSelect.value == "Default"
  audioSource = audioSelect.value
  videoSource = videoSelect.value
  constraints =
    audio:
      optional: [sourceId: audioSource]
    video:
      optional: [sourceId: videoSource]
  window.casting.config.media = constraints
  window.casting.stopLocalVideo()
  $('#copiedRemote').empty()
  window.casting.startLocalVideo()

#  navigator.getUserMedia constraints, successCallback, errorCallback
  return
