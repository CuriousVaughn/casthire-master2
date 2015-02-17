# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

casting = null
name = gon.username
id = null
names = {}
timerId = null
selectedPeers = []

jQuery ->
  if $('.controller_castings').length > 0
    startTimer(gon.casting.started_interview) if gon.casting.started_interview

    $('#mute').click ->
      woopra.track "mute"
      casting.mute()
      $('#mute').css('display', 'none')
      $('#unmute').css('display', 'block')

    $('#unmute').click ->
      woopra.track "unmute"
      casting.unmute()
      $('#mute').css('display', 'block')
      $('#unmute').css('display', 'none')

    $('#muteVideo').click ->
      woopra.track "mute video"
      casting.pauseVideo()
      $('#muteVideo').css('display', 'none')
      $('#unmuteVideo').css('display', 'block')

    $('#unmuteVideo').click ->
      woopra.track "unmute video"
      casting.resumeVideo()
      $('#muteVideo').css('display', 'block')
      $('#unmuteVideo').css('display', 'none')

    $('#selectDevices').click ->
      $(this).toggleClass('btn-clicked')
      $('#devicePicker').toggle()

    $('#btn-close').click ->
      $('#devicePicker').css('display', 'none')
      $('#selectDevices').removeClass('btn-clicked')

    $('#group-title').click ->
      toggleGroupDetails()

    $('.tooltip-trigger').mouseenter ->
      $(this).children('.tooltip-right').css('display', 'block')

    $('.tooltip-trigger').mouseleave ->
      $(this).children('.tooltip-right').css('display', 'none')

    #this is if the user the moderator
    if name
      startCasting()
    $("#nameForm").submit (event) ->
      event.preventDefault()
      name = $('#name').val()
      startCasting()

startCasting = ->
    $("#nameBox").css('display', 'none');
    webRTCSupported()

    $('.alert').css('display', 'block');

    casting = new SimpleWebRTC(
      localVideoEl: 'localVideo',
      remoteVideosEl: 'remoteVideos',
      autoRemoveVideos: false,
      autoRequestMedia: true
    )

    window.casting = casting #this is being exposed for the inputs js to access start/stop stream

    casting.on "readyToCall", ->
      joinRoom()

    casting.on 'videoAdded', (video, peer) ->
      setupPeer(video, peer.id)

    casting.on 'videoRemoved', (video, peer) ->
      $('#'+peer.id).remove()
      setVideoSize()

    $(window).resize ->
      setVideoSize()

joinRoom = ->
  #hide permissions, show main
  $('.alert').css('display', 'none')
  $('#permissions').css('display', 'none')
  $('#main').css('display', 'block')
  room = gon.private_id  || "casthire_#{gon.casting.id}"
  casting.joinRoom room
  id = casting.connection.socket.sessionid

  $.ajax
    url: "/castings/#{gon.casting.id}/register"
    type: "post"
    data:
      peer: id
      username: name
    dataType: "json"
    success: (returned_value) ->
      addEvents(id)

  # Set size of videos
  setTimeout (-> setVideoSize()), 1000

addEvents = (id) ->
  pusher = new Pusher gon.pusher_key
  if (gon.private_id)
    chan = "presence-#{gon.private_id}"
  else
    chan = "presence-casthire_#{gon.casting.id}"
  channel = pusher.subscribe(chan)
  channel.bind 'kick', (data) ->
    if data['peer'] == id
      casting.leaveRoom()
      $('#main').css('display', 'none')
      $('#ended').css('display', 'none')

  channel.bind 'interview', (data) ->
    startTimer(data['time']) if data['time']
    for peer in data['peers']
      if peer == id
        joinInterview data['interview']

  channel.bind 'stop_interview', (data) ->
    stopTimer()

  channel.bind 'pusher:subscription_succeeded', (subscribers) ->
    subscribers.each (subscriber) ->
      interviewBar = $('#' + subscriber.info.peer + '_bar')
      nametag = $('<div class="nametag">' + subscriber.info.name + '</div>')
      interviewBar.prepend(nametag)
      names[subscriber.info.peer] = subscriber.info.name

  channel.bind 'pusher:member_added', (subscriber) ->
    interviewBar = $('#' + subscriber.info.peer + '_bar')
    nametag = $('<div class="nametag">' + subscriber.info.name + '</div>')
    interviewBar.prepend(nametag)
    names[subscriber.info.peer] = subscriber.info.name

  channel.bind 'pusher:member_removed', (subscriber) ->
    delete names[subscriber.info.peer]
    if subscriber.id == 'Host' && window.location.href.match(/\/private/i)
      window.location.href = "/castings/#{gon.casting.id}/apply"

  $('#loading').css('display', 'block')

setVideoSize = ->
  videos = $('.video-container')
  counter = $('#remoteVideos').children().length + 1

  if counter == 1
    videos.width('100%')
  else
    splitX = Math.ceil(Math.sqrt(counter))
    splitYWholeRows = Math.floor(counter / splitX)
    splitYRemainder = counter % splitX
    splitY = splitYWholeRows + splitYRemainder

    videoWidth = Math.floor(100 / splitX) + '%'
    videoHeight = Math.floor(($(window).height() - $('nav').height()) / splitY)

    videos.css('width', videoWidth)
    videos.css('height', videoHeight)

updateGroupList = (buttons) ->
  buttons.click ->
    $(this).parent().remove()

toggleGroupDetails = (action) ->
  indicator = $('#group-indicator')
  details = $('#group-details')
  if (action == 'show')
    indicator.removeClass('fa-caret-right').addClass('fa-caret-down')
    details.css('display', 'block')
  else
    if (indicator.hasClass('fa-caret-down'))
      indicator.removeClass('fa-caret-down').addClass('fa-caret-right')
      details.css('display', 'none')
    else
      indicator.removeClass('fa-caret-right').addClass('fa-caret-down')
      details.css('display', 'block')

setupPeer = (video, peerId) ->
  $('#loading').css('display', 'none')

  $('#' + peerId).addClass('video-container clearfix')

  # Set width of videos
  setVideoSize()

  $('#'+peerId).append("<div id='#{peerId}_bar' class='interview-bar'></div>")
  interviewBar = $('#'+peerId+'_bar')

  if names[peerId]
    nametag = $('<div class="nametag">' + names[peerId] + '</div>')
    interviewBar.append(nametag)

  if $('.controller_castings.action_show').length > 0
    setTimeout (->
      # Create and append interview/kick bar
      currentVideo = interviewBar.prev()

      interviewBar
        .append("<a id='kick_#{peerId}' href='#' class='btn btn-danger btn-xs btn-action' data-peer='#{peerId}'>Kick</a>")
        .append("<a id='interview_#{peerId}' href='#' class='btn btn-warning btn-xs btn-action' data-peer='#{peerId}'>Interview</a>")
        .append("<a id='group_interview_#{peerId}' href='#' class='btn btn-warning btn-xs btn-action' data-peer='#{peerId}'>Add to Group Interview</a>")

      $("#kick_"+peerId).click ->
        woopra.track "kick"
        $.ajax
          url: "/castings/#{gon.casting.id}/kick"
          type: "post"
          data:
            peer: peerId
          dataType: "json"
          success: (returned_value) ->
            return
      $("#interview_"+peerId).click ->
        woopra.track "interview"
        #todo: this is where we could build an array of peers to send to the backend.
        #we would then need another way to start interview.
        $.ajax
          url: "/castings/#{gon.casting.id}/interview"
          type: "post"
          data:
            peers: [ peerId ]
          dataType: "json"
          success: (returned_value) ->
            joinInterview(returned_value['interview'])
            return

      $('#group_interview_'+peerId).click ->
        $('#group-list').append('<li>' + names[peerId] + '<a class="fa fa-times btn-remove-name"></a></li>')
        toggleGroupDetails('show')
        updateGroupList($('.btn-remove-name'))
        selectedPeers.push(peerId)

      $('#group-interview').click ->
        woopra.track "group interview"
        $.ajax
          url: "/castings/#{gon.casting.id}/interview"
          type: "post"
          data:
            peers: selectedPeers
          dataType: "json"
          success: (returned_value) ->
            joinInterview(returned_value['interview'])
            return
      ), 1000

joinInterview = (interviewId) ->
  woopra.track "joined interview"
  $('#remoteVideos').empty()
  casting.leaveRoom()
  window.location.href = "/castings/#{gon.casting.id}/private/#{interviewId}"

webRTCSupported = () ->
  PC = window.mozRTCPeerConnection or window.webkitRTCPeerConnection
  if PC == undefined
    $('#permissions').css('display', 'none')
    $('.alert').css('display', 'block')
    $('#unsupported').css('display', 'block')

startTimer = (time) ->
  $('#timer').css('display', 'block');
  seconds = moment().diff time, 'seconds';
  clearInterval(timerId) if timerId

  timerId = setInterval =>
    seconds++
    prettyTime = moment().startOf('day').seconds(seconds).format('H:mm:ss');
    $('#timer').html(prettyTime)
  , 1000

stopTimer = () ->
  $('#timer').css('display', 'none');
  clearInterval(timerId) if timerId
