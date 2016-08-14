{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, TopicMessage, CatchAllMessage, User} = require('hubot')

io            = require('socket.io-client')



class wsAdapter extends Adapter

  socket=null

  constructor: ->
    console.log("constructor FIRING !!!")
    super
    self=@
    
    @robot.logger.info " Adapter Bot Loaded..."
    

  send: (envelope, strings...) ->
    console.log("in send method")
    #console.log chalk.bold("#{str}") for str in strings
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
    console.log("shutdown function called..")
    #@robot.shutdown()
    #process.exit 0

  buildWebSocket: () ->

    console.log("websocket being build")
    @robot.logger.info "scoping the robot"

    socket = io.connect('http://localhost:3000')
    

    socket.on 'conEvt', ((data) ->
      console.log 'connection event recieved back from chat server'
      console.log data
      socket.emit 'join', 'user': 'hubot'
      socket.emit 'joinRoom', 'room': 'hubot'
      return
    ).bind(this)  

    #adding general error handler...
    socket.on 'error', (error) ->
      console.log 'socket was in error '
      console.log error
      return

    socket.on 'error',->
      console.log 'socket was in error '
      

    #recieving messages from chat server...
    #I really hate this sytax on getting around scoping issues...

    socket.on 'message', ((data) ->
      console.log 'message recieved from the chat server'
      console.log data
     
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

