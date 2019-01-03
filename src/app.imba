tag Fruit < svg:g
  def render
    <self>
      <svg:circle cx=(15+30*data:x) cy=(15+30*data:y) r="12">

tag SnakeBody < svg:g
  prop index
  prop length

  def render
    let color = "hsl(120, 100%, {(0.2 + 0.6*index/length)*100}%)"
    <self>
      <svg:rect x=(30*data:x) y=(30*data:y) width="28" height="28" css:fill=color>

tag SnakeHead < svg:g
  def render
    <self>
      <svg:rect x=(30*data:x) y=(30*data:y) width="28" height="28">

tag SnakeDirection < svg:g
  prop x
  prop y
  prop dx
  prop dy

  def render
    let x0 = 30*x + 14
    let y0 = 30*y + 14
    let rot = 0
    rot = 180 if dx == -1
    rot = 90 if dy == 1
    rot = 270 if dy == -1

    <self>
      <svg:polygon points="-8,-8 8,0 -8,8" transform="translate({x0},{y0}) rotate({rot})">

tag Snake < svg:g
  prop dx
  prop dy

  def render
    <self>
      for item, index in data
        if index == 0
          <SnakeHead[item]>
          <SnakeDirection x=item:x y=item:y dx=dx dy=dy>
        else
          <SnakeBody[item] index=index length=data:length>

tag SnakeGame
  def build
    startGame()

  def startGame
    @active = true
    @dx = 1
    @dy = 0
    @snake = [{x:10, y:10}, {x:9, y:10}, {x:8, y:10}]
    @fruit = []
    for i in Array.from({length: 30})
      addRandomFruit
    @score = 0

  def isFruitAt(x, y)
    @fruit.some do |item|
      (item:x == x && item:y == y)

  def isSnakeAt(x, y)
    @snake.some do |item|
      (item:x == x && item:y == y)

  def addRandomFruit
    while true
      let x = Math.floor(Math.random() * 21)
      let y = Math.floor(Math.random() * 21)
      if isSnakeAt(x, y) || isFruitAt(x, y)
        continue
      @fruit.push({x: x, y: y})
      break

  def removeFruitAt(x, y)
    @fruit = @fruit.filter do |f|
      !(f:x == x && f:y == y)

  def gameOver
    @active = false

  def moveSnake
    let snakeHead = @snake[0]
    let nextX = (snakeHead:x + @dx + 21) % 21
    let nextY = (snakeHead:y + @dy + 21) % 21

    if isSnakeAt(nextX, nextY)
      gameOver
    else if isFruitAt(nextX, nextY)
      removeFruitAt(nextX, nextY)
      @snake.unshift({x: nextX, y: nextY})
      @score += 1
      addRandomFruit
    else
      @snake.unshift({x: nextX, y: nextY})
      @snake.pop

  def mount
    document.add-event-listener("keydown") do |event|
      handle_key(event)
      Imba.commit
    setInterval(&,100) do
      if @active
        moveSnake
      Imba.commit

  def handle_key(event)
    return startGame unless @active
    if event:key == "ArrowLeft"
      return if @dy == 0
      @dx = -1
      @dy = 0
    else if event:key == "ArrowRight"
      return if @dy == 0
      @dx = 1
      @dy = 0
    else if event:key == "ArrowUp"
      return if @dx == 0
      @dx = 0
      @dy = -1
    else if event:key == "ArrowDown"
      return if @dx == 0
      @dx = 0
      @dy = 1

  def render
    <self.snake-game>
      <h2>
        "Score: { @score }"
      <svg:svg>
        <Snake[@snake] dx=@dx dy=@dy>
        for item in @fruit
          <Fruit[item]>
      <.help>
        "Keys to change snake direction."

tag App
  def render
    <self>
      <header>
        "Snake"
      <SnakeGame>

Imba.mount <App>
