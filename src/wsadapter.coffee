
try
  {Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, TopicMessage, CatchAllMessage, User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, TopicMessage, CatchAllMessage, User} = prequire 'hubot'


#{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, TopicMessage, CatchAllMessage, User} = require('hubot')

io            = require('socket.io-client')



class wsAdapter extends Adapter

  socket=null

  constructor: ->
    console.log("constructor FIRING !!!")
    super
    self=@
    
    @robot.logger.info "wsAdapter bot Loaded..."
    

  send: (envelope, strings...) ->
    #console.log("in send method")
    #socket.emit 'message', 'message': "#{str}" for str in strings
   
    #verbose but then I can see what is going on:
    i = undefined
    len = undefined
    str = undefined
    i = 0
    len = strings.length
    while i < len
      str = strings[i]
      socket.emit 'message', 'message': '' + str.replace /\n/g, "<br>"
      i++
    

  emote: (envelope, strings...) ->
    @send envelope, "* #{str}" for str in strings

  reply: (envelope, strings...) ->
    strings = strings.map (s) -> "#{envelope.user.name}: #{s}"
    @send envelope, strings...

  run: ->
    #not sure why the emit is needed..
    @emit 'connected'
    @buildWebSocket()


  shutdown: () ->
    @robot.logger.info "shutdown function called.."
    #@robot.shutdown()
    #process.exit 0

  buildWebSocket: () ->

    @robot.logger.info "websocket being build"

    socket = io.connect('http://localhost:3000')
    

    socket.on 'conEvt', ((data) ->
      @robot.logger.info "connection event recieved back from chat server"
      @robot.logger.info data
      socket.emit 'join', 'user': 'hubot'
      socket.emit 'joinRoom', 'room': 'hubot'
      return
    ).bind(this)  

    #adding general error handler...
    socket.on 'error', (error) ->
      @robot.logger.error "socket was in error"
      @robot.logger.error error
      return

    socket.on 'error',->
      @robot.logger.error socket was in error
      

    #recieving messages from chat server...
    #I really hate this sytax on getting around scoping issues...

    socket.on 'message', ((data) ->
      @robot.logger.info "message recieved from the chat server"
      @robot.logger.info data
     
      #need userID and userName.  
      this.robot.logger.info "recieving message and accessing the robot..."

      userId = process.env.HUBOT_SHELL_USER_ID or '1'
      if userId.match (/\A\d+\z/)
        userId = parseInt(userId)

      userName = process.env.HUBOT_SHELL_USER_NAME or 'Shell'
      user = this.robot.brain.userForId userId, name: userName, room: 'Shell'
      @receive new TextMessage user, data, 'messageId'


      return
    ).bind(this)



exports.use = (robot) ->
  new wsAdapter robot

