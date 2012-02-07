runningInPcBrowser = navigator.userAgent.indexOf('Firefox') >= 0 || navigator.userAgent.indexOf('Chrome') >= 0

PIECE_IMG_WIDTH = 67

boardWidth  = null
boardHeight = null

cellWidth  = null
cellHeight = null

pieceWidth = null
pieces = null
selectedPiece = null

#-------------------------------------------------------------------------------

rc2xy = (r, c) ->
    x = c * cellWidth  + cellWidth  / 2
    y = r * cellHeight + cellHeight / 2
    [x, y]

xy2rc = (x, y) ->
    c = (x - cellWidth  / 2) / cellWidth
    r = (y - cellHeight / 2) / cellHeight
    [Math.round(r), Math.round(c)]

class Piece
    constructor: (@pieceName, @row, @col) ->
        @normalCanvas   = this.makeCanvas(false)
        @selectedCanvas = this.makeCanvas(true)
        this.moveTo(@row, @col)
        this.unselect()

    makeCanvas: (selected) ->
        canvas = document.createElement('canvas')
        canvas.width  = pieceWidth
        canvas.height = pieceWidth
        canvas.style.position = 'absolute'
        canvas.style.zIndex   = 1
        document.body.appendChild(canvas)

        img = new Image()
        img.src = 'img/' + @pieceName + '.png'
        img.onload = ->
            ctx = canvas.getContext('2d')
            ctx.globalAlpha = 0.3 if selected
            ctx.drawImage(img, 0, 0, PIECE_IMG_WIDTH, PIECE_IMG_WIDTH, 0, 0, pieceWidth, pieceWidth)

        if runningInPcBrowser
            canvas.onclick = this.onclick
        else
            canvas.ontouchstart = this.onclick

        canvas

    moveTo: (row, col) =>
        @row = row
        @col = col
        [x, y] = rc2xy(@row, @col)
        x -= pieceWidth / 2
        y -= pieceWidth / 2
        @normalCanvas.style.left = @selectedCanvas.style.left = "#{x}px"
        @normalCanvas.style.top  = @selectedCanvas.style.top  = "#{y}px"

    select: =>
        @normalCanvas.style.visibility   = 'hidden'
        @selectedCanvas.style.visibility = 'visible'

    unselect: =>
        @normalCanvas.style.visibility   = 'visible'
        @selectedCanvas.style.visibility = 'hidden'

    onclick: =>
        selectedPiece.unselect() if selectedPiece
        selectedPiece = this
        this.select()

class Board
    constructor: ->
        canvas  = document.getElementById('boardLayer')
        canvas.width   = boardWidth
        canvas.height  = boardHeight
        if runningInPcBrowser
            canvas.onclick = this.onclick
        else
            canvas.ontouchstart = this.onclick
        @ctx = canvas.getContext('2d')

    drawGrid: =>
        @ctx.lineWidth = 1

        for r in [0..9]
            [x1, y] = rc2xy(r, 0)
            [x2, y] = rc2xy(r, 8)
            @ctx.moveTo(x1, y)
            @ctx.lineTo(x2, y)

        for c in [0..8]
            [x, y1] = rc2xy(0, c)
            [x, y4] = rc2xy(9, c)
            if c == 0 || c == 8
                @ctx.moveTo(x, y1)
                @ctx.lineTo(x, y4)
            else
                [x, y2] = rc2xy(4, c)
                [x, y3] = rc2xy(5, c)
                @ctx.moveTo(x, y1)
                @ctx.lineTo(x, y2)
                @ctx.moveTo(x, y3)
                @ctx.lineTo(x, y4)

        # Black general area
        [x1, y1] = rc2xy(0, 3)
        [x2, y2] = rc2xy(2, 5)
        @ctx.moveTo(x1, y1)
        @ctx.lineTo(x2, y2)
        @ctx.moveTo(x2, y1)
        @ctx.lineTo(x1, y2)

        # Red general area
        [x1, y1] = rc2xy(7, 3)
        [x2, y2] = rc2xy(9, 5)
        @ctx.moveTo(x1, y1)
        @ctx.lineTo(x2, y2)
        @ctx.moveTo(x2, y1)
        @ctx.lineTo(x1, y2)

        @ctx.stroke()

    drawBoard: =>
        img = new Image()
        img.src = 'img/board.png'
        img.onload = =>
            @ctx.drawImage(img, 0, 0, boardWidth, boardHeight)
            this.drawGrid()

    onclick: (e) ->
        x = e.pageX - this.offsetLeft
        y = e.pageY - this.offsetTop
        [r, c] = xy2rc(x, y)
        selectedPiece.moveTo(r, c) if selectedPiece

initPieces = ->
    pieces = [
        new Piece('bgeneral',  0, 4)
        new Piece('badvisor',  0, 3)
        new Piece('badvisor',  0, 5)
        new Piece('belephant', 0, 2)
        new Piece('belephant', 0, 6)
        new Piece('bchariot',  0, 0)
        new Piece('bchariot',  0, 8)
        new Piece('bcannon',   2, 1)
        new Piece('bcannon',   2, 7)
        new Piece('bhorse',    0, 1)
        new Piece('bhorse',    0, 7)
        new Piece('bsoldier',  3, 0)
        new Piece('bsoldier',  3, 2)
        new Piece('bsoldier',  3, 4)
        new Piece('bsoldier',  3, 6)
        new Piece('bsoldier',  3, 8)

        new Piece('rgeneral',  9, 4)
        new Piece('radvisor',  9, 3)
        new Piece('radvisor',  9, 5)
        new Piece('relephant', 9, 2)
        new Piece('relephant', 9, 6)
        new Piece('rchariot',  9, 0)
        new Piece('rchariot',  9, 8)
        new Piece('rcannon',   7, 1)
        new Piece('rcannon',   7, 7)
        new Piece('rhorse',    9, 1)
        new Piece('rhorse',    9, 7)
        new Piece('rsoldier',  6, 0)
        new Piece('rsoldier',  6, 2)
        new Piece('rsoldier',  6, 4)
        new Piece('rsoldier',  6, 6)
        new Piece('rsoldier',  6, 8)
    ]

onDeviceReady = ->
    boardWidth  = $(window).width()
    boardHeight = $(window).height()

    cellWidth  = boardWidth  / 9
    cellHeight = boardHeight / 10

    pieceWidth = Math.min(PIECE_IMG_WIDTH, cellWidth, cellHeight)

    board = new Board()
    board.drawBoard()
    initPieces()

#-------------------------------------------------------------------------------

# If you want to prevent dragging, uncomment this section
preventBehavior = (e) ->
    e.preventDefault()
document.addEventListener('touchmove', preventBehavior, false)

if runningInPcBrowser
    $(onDeviceReady)
else
    document.addEventListener('deviceready', onDeviceReady, false)
