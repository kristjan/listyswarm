class window.Swarm
  constructor: ->
    this.$canvas       = $('#game')
    this.canvas        = this.$canvas.get(0)
    this.canvas.width  = window.innerWidth
    this.canvas.height = window.innerHeight

    this.game          = {}
    this.data          = {}
    this.data.tick     = 0
    this.ctx           = this.canvas.getContext('2d')

    this.cellWidth     = 8
    this.cellHeight    = 8
    this.cellSpacing   = 2
    this.tickInterval  = 0

  run: ->
    this.nextTick()

  drawBoard: (response)=>
    this.data.board = response

    this.ctx.restore
    this.ctx.save

    cw = this.cellWidth
    ch = this.cellHeight
    sp = this.cellSpacing

    _(this.data.board.split("\n")).each (row, rindex)=>
      _(row.split('')).each (col, cindex)=>
        x = cw * cindex + (sp * cindex)
        y = ch * rindex + (sp * rindex)
        this.drawCell(col, x, y, cw, ch)

    this.updateStats()
    this.updateGameData()

    setTimeout (=> this.nextTick()), this.tickInterval

  drawCell: (object, x, y, cw, ch)->
    switch object
      when 'x', 'X'
        this.ctx.fillStyle = "rgb(200, 0, 0)"
      when 'o', 'O'
        this.ctx.fillStyle = "rgb(0, 0, 200)"
      when 's', 'S'
        this.ctx.fillStyle = "rgb(255, 128, 170)"
      when 'w', 'W'
        this.ctx.fillStyle = "rgb(0, 255, 0)"
      when '1', '2', '3', '4'
        this.ctx.fillStyle = "rgb(255, 255, 0)"
      else
        this.ctx.fillStyle = "rgb(0, 0, 0)"

    this.ctx.fillRect(x, y, cw, ch)

    if _(['X', 'O', 'S', 'W', 'b']).contains(object)
      this.ctx.strokeStyle = "#ccc"
      this.ctx.lineWidth = 2
      this.ctx.strokeRect(x+1, y+1, cw-2, ch-2)

  updateStats: ->
    $('#controls .tick').text(this.data.tick)

  updateGameData: ->
    this.data.tick += 1

  nextTick: ->
    if this.data.tick < 500
      $.get("tick/#{ this.data.tick }", this.drawBoard)
