class window.Swarm
  constructor: ->
    this.$game          = $('#game')
    this.$stats         = $('#stats')
    this.$progress      = $('.progress')
    
    this.$board         = $('#board')
    this.board          = this.$board.get(0)
    this.board.width    = this.boardWidth()
    this.board.height   = window.innerHeight
    this.board_canvas   = this.board.getContext('2d')

    this.$overlay       = $('#overlay')
    this.overlay        = this.$overlay.get(0)
    this.overlay.width  = this.boardWidth()
    this.overlay.height = window.innerHeight
    this.overlay_canvas = this.overlay.getContext('2d')

    this.explosionImage = new Image
    this.explosionImage.src = '/assets/explosion.png'
    this.blueListyImage = new Image
    this.blueListyImage.src = '/assets/blue-listy-icon.png'
    this.redListyImage = new Image
    this.redListyImage.src = '/assets/red-listy-icon.png'
    this.pinkListyImage = new Image
    this.pinkListyImage.src = '/assets/pink-listy-icon.png'
    this.greenListyImage = new Image
    this.greenListyImage.src = '/assets/green-listy-icon.png'

    this.game           = {}
    this.data           = {}
    this.data.tick      = 0
    this.data.game_id   = $('#game-data').data('game-id')
    this.data.max_ticks = $('#game-data').data('max-ticks')

    this.cellWidth      = 17
    this.cellHeight     = 17
    this.cellSpacing    = 2
    this.tickInterval   = 0

    this.play           = true
    this.$playButton    = $('.play')
    this.$pauseButton   = $('.pause')
    this.$nextButton    = $('.next')
    this.$prevButton    = $('.prev')
    this.$replayButton  = $('.replay')

    this.attachEvents()

  run: ->
    this.nextTick()

  attachEvents: ->
    $('body').on 'click', '.pause', =>
      this.$pauseButton.hide()
      this.$playButton.show()
      this.play = false

    $('body').on 'click', '.play', =>
      this.$playButton.hide()
      this.$pauseButton.show()
      this.play = true
      this.nextTick()

    $('body').on 'click', '.next', =>
      this.nextTick()

    $('body').on 'click', '.prev', =>
      this.prevTick()

    $('body').on 'click', '.replay', =>
      this.data.tick = 0
      this.nextTick()

  boardWidth: ->
    window.innerWidth - this.$stats.innerWidth() - 45

  drawBoard: (response)=>
    this.parseGameFile(response)
    this.updateStats()

    board = this.board_canvas
    cw = this.cellWidth
    ch = this.cellHeight
    sp = this.cellSpacing

    board.restore
    board.save

    _(this.data.board).each (row, rindex)=>
      _(row.split('')).each (col, cindex)=>
        x = cw * cindex + (sp * cindex)
        y = ch * rindex + (sp * rindex)
        this.drawCell(col, x, y, cw, ch)

    if this.play
      setTimeout (=> this.nextTick()), this.tickInterval

  parseGameFile: (file)->
    board   = file.split("\n")
    summary = JSON.parse(board.shift())

    this.data.summary = summary
    this.data.tick    = summary.tick
    this.data.board   = board
    this.data.players = []

    colors = ['red', 'blue', 'pink', 'green']
    _(['x','o','s','w']).each (object)=>
      if summary[object]
        player =
          char:  object
          color: colors.shift()
          swarm: summary[object].swarm
          score: summary[object].score
          agent: this.agentName(summary[object].agent)
        
        this.data.players.push(player)

  agentName: (name)->
    name.split('::')[1]

  drawCell: (object, x, y, cw, ch)->
    board   = this.board_canvas
    overlay = this.overlay_canvas

    switch object
      when 'x', 'X' #red
        #board.fillStyle = "rgb(200, 0, 0)"
        #board.fillRect(x, y, cw, ch)
        board.drawImage(this.redListyImage, x, y)
      when 'o', 'O' #blue
        #board.fillStyle = "rgb(0, 0, 200)"
        #board.fillRect(x, y, cw, ch)
        board.drawImage(this.blueListyImage, x, y)
      when 's', 'S' #pink
        #board.fillStyle = "rgb(255, 128, 170)"
        #board.fillRect(x, y, cw, ch)
        board.drawImage(this.pinkListyImage, x, y)
      when 'w', 'W' #green
        #board.fillStyle = "rgb(0, 200, 0)"
        #board.fillRect(x, y, cw, ch)
        board.drawImage(this.greenListyImage, x, y)
      when '1', '2', '3', '4' #yellow
        board.fillStyle = "rgb(255, 255, 0)"
        board.fillRect(x, y, cw, ch)
      when '*'
        overlay.drawImage(this.explosionImage, x-10, y-10)
        setTimeout (=>overlay.clearRect(x-10, y-10, 30, 30)), 500
      else
        board.clearRect(x, y, cw, ch)


    if _(['X', 'O', 'S', 'W', 'b']).contains(object)
      board.strokeStyle = "#ccc"
      board.lineWidth = 2
      board.strokeRect(x+1, y+1, cw-2, ch-2)

  updateStats: ->
    progress = (this.data.tick / this.data.max_ticks)
    progress = Math.ceil(progress * 100)
    this.$progress.css('width', "#{progress}%")

    _(this.data.players).each (player)->
      $player = $(".players .player-#{ player.char }")
      $player.find('.score .value').text(player.score)
      $player.find('.swarm .value').text(player.swarm)
      #$player.find('.agent').text(player.agent)

  nextTick: ->
    if this.data.tick < this.data.max_ticks-1
      this.data.tick += 1
      $.get("/game/#{ this.data.game_id }/tick/#{ this.data.tick }", this.drawBoard)

  prevTick: ->
    if this.data.tick > 1
      this.data.tick -= 1
      $.get("/game/#{ this.data.game_id }/tick/#{ this.data.tick }", this.drawBoard)

