class window.Swarm
  constructor: ->
    this.$game          = $('#game')
    this.$stats         = $('#stats')
    this.$progress      = $('.progress')
    this.$canvas        = $('#board')
    this.canvas         = this.$canvas.get(0)
    this.canvas.width   = this.boardWidth()
    this.canvas.height  = window.innerHeight

    this.game           = {}
    this.data           = {}
    this.data.tick      = 0
    this.data.game_id   = $('#game-data').data('game-id')
    this.data.max_ticks = $('#game-data').data('max-ticks')
    this.ctx            = this.canvas.getContext('2d')

    this.cellWidth      = 8
    this.cellHeight     = 8
    this.cellSpacing    = 2
    this.tickInterval   = 0

  run: ->
    this.nextTick()

  boardWidth: ->
    window.innerWidth - this.$stats.innerWidth() - 25


  drawBoard: (response)=>
    this.parseGameFile(response)
    this.updateStats()

    this.ctx.restore
    this.ctx.save

    cw = this.cellWidth
    ch = this.cellHeight
    sp = this.cellSpacing

    _(this.data.board).each (row, rindex)=>
      _(row.split('')).each (col, cindex)=>
        x = cw * cindex + (sp * cindex)
        y = ch * rindex + (sp * rindex)
        this.drawCell(col, x, y, cw, ch)

    setTimeout (=> this.nextTick()), this.tickInterval

  parseGameFile: (file)->
    board   = file.split("\n")
    summary = JSON.parse(board.shift())

    this.data.summary = summary
    this.data.tick    = summary.tick
    this.data.board   = board
    this.data.players   = []

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
    switch object
      when 'x', 'X' #red
        this.ctx.fillStyle = "rgb(200, 0, 0)"
        this.ctx.fillRect(x, y, cw, ch)
      when 'o', 'O' #blue
        this.ctx.fillStyle = "rgb(0, 0, 200)"
        this.ctx.fillRect(x, y, cw, ch)
      when 's', 'S' #pink
        this.ctx.fillStyle = "rgb(255, 128, 170)"
        this.ctx.fillRect(x, y, cw, ch)
      when 'w', 'W' #green
        this.ctx.fillStyle = "rgb(0, 200, 0)"
        this.ctx.fillRect(x, y, cw, ch)
      when '1', '2', '3', '4' #yellow
        this.ctx.fillStyle = "rgb(255, 255, 0)"
        this.ctx.fillRect(x, y, cw, ch)
      else
        this.ctx.clearRect(x, y, cw, ch)


    if _(['X', 'O', 'S', 'W', 'b']).contains(object)
      this.ctx.strokeStyle = "#ccc"
      this.ctx.lineWidth = 2
      this.ctx.strokeRect(x+1, y+1, cw-2, ch-2)

  updateStats: ->
    progress = (this.data.tick / this.data.max_ticks)
    progress = Math.ceil(progress * 100)
    this.$progress.css('width', "#{progress}%")

    _(this.data.players).each (player)->
      $player = $(".players .player-#{ player.char }")
      $player.show()
      #$player.find('.agent').text(player.agent)
      $player.find('.score .value').text(player.score)
      $player.find('.swarm .value').text(player.swarm)
      $player.find('.agent').text(player.agent)

  nextTick: ->
    if this.data.tick < this.data.max_ticks
      $.get("/game/#{ this.data.game_id }/tick/#{ this.data.tick }", this.drawBoard)
