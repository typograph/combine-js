# colors = ['#fff','#f00','#f63','#fc0','#3c0','#6cf','#00f','#90c','#000','#f0c']
animation_delay = 50
colors = ['transparent','#4be600','#f5c800','#dc7d19','#dc3232','#f050a0','#af3cb9','#3250ff','#0fc3eb','#000000','#cdcdcd']
reset_colors = [
    'transparent',
    ["#6feb33","#93f066","#b7f599","#dbfacc","#ffffff"],
    ["#f7d333","#f9de66","#fbe999","#fdf4cc","#ffffff"],
    ["#e39747","#eab175","#f1cba3","#f8e5d1","#ffffff"],
    ["#e35b5b","#ea8484","#f1adad","#f8d6d6","#ffffff"],
    ["#f373b3","#f696c6","#f9b9d9","#fcdcec","#ffffff"],
    ["#bf63c7","#cf8ad5","#dfb1e3","#efd8f1","#ffffff"],
    ["#5b73ff","#8496ff","#adb9ff","#d6dcff","#ffffff"],
    ["#3fcfef","#6fdbf3","#9fe7f7","#cff3fb","#ffffff"],
    ["#333333","#666666","#999999","#cccccc","#ffffff"],
    ["#d7d7d7","#e1e1e1","#ebebeb","#f5f5f5","#ffffff"]    
    ]
upgrade_colors = [
    'transparent',
    ["#6de000","#8fda00","#b1d400","#d3ce00"],
    ["#f0b905","#ebaa0a","#e69b0f","#e18c14"],
    ["#dc6e1e","#dc5f23","#dc5028","#dc412d"],
    ["#e03848","#e43e5e","#e84474","#ec4a8a"],
    ["#e34ca5","#d648aa","#c944af","#bc40b4"],
    ["#9640c7","#7d44d5","#6448e3","#4b4cf1"],
    ["#2b67fb","#247ef7","#1d95f3","#16acef"],
    ["#0c9cbc","#09758d","#064e5e","#03272f"],
    ["#292929","#525252","#7b7b7b","#a4a4a4"],
    ["#b3d2a4","#99d77b","#7fdc52","#65e129"]    
    ]

class Cell
    constructor: (@row,@column,@dom) -> @reset()

    reset: =>
        @tier = 0
        @cluster = 0
        @sync()
    
    upgrade: =>
        @tier += 1
        if @tier == colors.length 
            @tier = 1 # ring colors
        @sync()
        
    set: (@tier) => @sync()
    
    isEmpty: => return @tier == 0
        
    sync: => @dom.style.backgroundColor = colors[@tier]
    
    anim_reset: (step) => 
        if step > 3
            @reset()
        else
            @dom.style.backgroundColor = reset_colors[@tier][step]
            
    anim_upgrade: (step) =>
        if step > 3
            @upgrade()
        else
            @dom.style.backgroundColor = upgrade_colors[@tier][step]

class Figure
    constructor: (c1,c2,@width,@dom) ->
        # Clockwise
        @state = [0, c2, c1]
        @index = (@width-1)/2 | 0
        @sync()
    
    moveLeft: =>
        if @index > 0
            @index -= 1
        else if @state[2] == 0
            @index = -1
        @sync()
    
    moveRight: =>
        if @index < @width-2
            @index += 1
        @sync()
    
    rotate: =>
        if @state[0] == 0
            @state[0] = @state[2]
            @state[2] = 0
        else
            @state[2] = @state[1]
            @state[1] = @state[0]
            @state[0] = 0
            if @index == -1
                @index = 0
        @sync()

    clear: =>
        row1 = @dom.childNodes.item(1)
        row2 = @dom.childNodes.item(2)
        for cell in row1.childNodes
            cell.style.backgroundColor = colors[0]
        for cell in row2.childNodes
            cell.style.backgroundColor = colors[0]
        
    sync: =>
        @clear()
        row1 = @dom.childNodes.item(1)
        row2 = @dom.childNodes.item(2)

        if @state[0] != 0    
            row1.childNodes.item(@index+1).style.backgroundColor = colors[@state[0]]
        row2.childNodes.item(@index+1).style.backgroundColor = colors[@state[1]]
        if @state[2] != 0
            row2.childNodes.item(@index).style.backgroundColor = colors[@state[2]]

class Game        

    constructor: (@width, @height) ->
        document.addEventListener 'keydown', @keyDown, true
        @dropping = false
    
        @maxtier = 3
        
        @gtable = document.getElementById('field')
        @drawCells()

        @scale = document.getElementById('scale')
        @drawScale()

        ntable = document.getElementById('next')
        r = document.createElement('tr')
        ntable.appendChild(r)
        @next_1 = document.createElement('td')
        r.appendChild(@next_1)
        r = document.createElement('tr')
        ntable.appendChild(r)
        @next_2 = document.createElement('td')
        r.appendChild(@next_2)

        @createNext()        
        @newTurn()

    drawScale: =>
        @scale.innerHTML = ""
        r = document.createElement('tr')
        @scale.appendChild(r)
        c = document.createElement('td')
        r.appendChild(c)
        c.style.backgroundColor = colors[@maxtier]

        r = document.createElement('tr')
        @scale.appendChild(r)
        c = document.createElement('td')
        r.appendChild(c)
        c.style.textAlign = "center"
        c.innerHTML = "^"

        for i in [@maxtier-1 .. 1]
            r = document.createElement('tr')
            @scale.appendChild(r)
            c = document.createElement('td')
            r.appendChild(c)
            c.style.backgroundColor = colors[i]

    drawCells: =>
        @cells = []

        for i in [@height+1 .. 0]
            row = document.createElement('tr')
            @gtable.appendChild(row)
            
            @cells[i] = []
            for j in [0 .. @width-1]
                cell = document.createElement('td')
                row.appendChild(cell)
                
                @cells[i][j] = new Cell(i,j,cell)

        safetyRow = @gtable.childNodes.item(2)
        safetyRow.style.borderBottom = "1px solid red"
        
    keyDown: (e) =>
        KEY_DOWN    = 40
        KEY_UP      = 38
        KEY_LEFT    = 37
        KEY_RIGHT   = 39
        
        if @dropping
            return
        
        if (e.keyCode == KEY_LEFT) 
            @figure.moveLeft()        
        else if (e.keyCode == KEY_RIGHT) 
            @figure.moveRight()
        else if (e.keyCode == KEY_UP) 
            @figure.rotate()
        else if (e.keyCode == KEY_DOWN)
            @dropping = true
            @figure.clear()
            @bringDown()

    land: (c,i) =>
        j = @height+1
        while j > 0 and @cells[j-1][i].isEmpty()
            j -= 1
        @cells[j][i].set(c)
        @critical.push([j,i])
            
    bringDown: =>
        @critical = []
        if @figure.state[2]
            @land(@figure.state[2],@figure.index)
        @land(@figure.state[1],@figure.index+1)
        if @figure.state[0]
            @land(@figure.state[0],@figure.index+1)

        @finalizeTurn()

    finalizeTurn: =>
        @landAll()
        if @removeClusters()
            @animationStep = -1
            setTimeout(@animateCollapse,animation_delay)
        else if not @checkOverload()
            @newTurn()

    animateCollapse: =>
        @animationStep += 1
        if @animationStep == 4            
            setTimeout(@finalizeTurn,animation_delay)
        else
            setTimeout(@animateCollapse,animation_delay)
        for cs in @clusters
            @collapseCluster(cs, @animationStep)

    collapseCluster: (cs, step) ->
        rowmin = @height+1
        colmin = @width-1
        for [i,j] in cs
            if i < rowmin
                rowmin = i
                colmin = j
            else if i == rowmin and j < colmin
                colmin = j
        for [i,j] in cs
            if i == rowmin and j == colmin
                @cells[i][j].anim_upgrade(step)
                if @cells[i][j].tier > @maxtier
                    @maxtier += 1 # max raise is 1
                    @drawScale()
            else
                @cells[i][j].anim_reset(step)

    checkOverload: =>
        for i in [0 .. @width-1]
            if not @cells[@height][i].isEmpty()
                return true
        return false
        
    landAll: =>
        for i in [0 .. @width-1]
            jmin = 0
            
            jmin += 1 while jmin < @height+1 and not @cells[jmin][i].isEmpty()
            continue if jmin > @height # all full
            
            j = jmin + 1
            while j < @height + 2
                j += 1 while j < @height+2 and @cells[j][i].isEmpty()
                break if j > @height+1 # air above
                
                while j < @height+2 and not @cells[j][i].isEmpty()
                    @cells[jmin][i].set(@cells[j][i].tier)
                    jmin += 1
                    j += 1
                    
            for j in [jmin .. @height+1]
                @cells[j][i].reset()
       
    removeClusters: =>
        @clusters = []
        #bottom  w
        i = 0
        j = 0
        j += 1 while j < @width and @cells[i][j].isEmpty()
        if j == @width
            return
        maxc = 0
        @cells[i][j].cluster = maxc
        @clusters = [[[i,j]]]
        for jj in [j+1 .. @width-1]
            if not @cells[i][jj].isEmpty()
                if @cells[i][jj].tier == @cells[i][jj-1].tier
                    @cells[i][jj].cluster = @cells[i][jj-1].cluster
                    @clusters[@cells[i][jj].cluster].push([i,jj])
                else
                    maxc += 1
                    @cells[i][jj].cluster = maxc
                    @clusters.push([[i,jj]])
        # Other rows
        for i in [1 .. @height+1]
            # first column
            if not @cells[i][0].isEmpty()
                if @cells[i][0].tier == @cells[i-1][0].tier
                    @cells[i][0].cluster = @cells[i-1][0].cluster
                    @clusters[@cells[i][0].cluster].push([i,0])
                else
                    maxc += 1
                    @cells[i][0].cluster = maxc
                    @clusters.push([[i,0]])
            for jj in [1 .. @width-1]
                if not @cells[i][jj].isEmpty()
                    if @cells[i][jj].tier == @cells[i][jj-1].tier
                        @cells[i][jj].cluster = @cells[i][jj-1].cluster
                        @clusters[@cells[i][jj].cluster].push([i,jj])
                        if @cells[i][jj].tier == @cells[i-1][jj].tier
                            co = @cells[i-1][jj].cluster
                            cn = @cells[i][jj].cluster
                            if cn != co
                                for [ic,jc] in @clusters[co]
                                    @clusters[cn].push([ic,jc])
                                    @cells[ic][jc].cluster = cn
                                @clusters[co] = []
                    else if @cells[i][jj].tier == @cells[i-1][jj].tier
                        @cells[i][jj].cluster = @cells[i-1][jj].cluster
                        @clusters[@cells[i][jj].cluster].push([i,jj])
                    else
                        maxc += 1
                        @cells[i][jj].cluster = maxc
                        @clusters.push([[i,jj]])

        i = 0
        while i < @clusters.length
            if @clusters[i].length < 3
                @clusters.splice(i,1)
            else
                i += 1
        
        return @clusters.length >= 1
        
    createNext: =>
        @nextfigure = [@randomColor(),@randomColor()]
        @next_1.style.backgroundColor = colors[@nextfigure[0]]
        @next_2.style.backgroundColor = colors[@nextfigure[1]]    
    
    randomColor: =>
        return 1 + Math.floor(Math.random()*(@maxtier-1))
    
    newTurn: =>
        @figure = new Figure(@nextfigure[0],@nextfigure[1],@width,@gtable)
        @createNext()
        @dropping = false

window.game = new Game(10,10)