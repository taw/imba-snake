tag Fruit < svg:g
  def render
    <self>
      <svg:circle.fruit cx=(10+20*data:x) cy=(10+20*data:y) r="8">

tag SnakeBody < svg:g
  def render
    <self>
      <svg:rect.snake-body x=(20*data:x) y=(20*data:y) width="18" height="18">

tag SnakeHead < svg:g
  def render
    <self>
      <svg:rect.snake-head x=(20*data:x) y=(20*data:y) width="18" height="18">

tag SnakeDirection < svg:g
  prop x
  prop y
  prop dx
  prop dy

  def render
    let x0 = 20*x + 9
    let y0 = 20*y + 9
    <self>
      if dx == 1
        <svg:polygon.snake-direction points="{x0 - 5},{y0 - 5} {x0 + 5},{y0} {x0 - 5},{y0 + 5}">
      else if dx == -1
        <svg:polygon.snake-direction points="{x0 + 5},{y0 - 5} {x0 - 5},{y0} {x0 + 5},{y0 + 5}">
      else if dy == 1
        <svg:polygon.snake-direction points="{x0 - 5},{y0 - 5} {x0 + 5},{y0 - 5} {x0},{y0 + 5}">
      else
        <svg:polygon.snake-direction points="{x0 - 5},{y0 + 5} {x0 + 5},{y0 + 5} {x0},{y0 - 5}">

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
          <SnakeBody[item]>


tag SnakeGame
  def build
    startGame()

  def startGame
    @active = true
    @dx = 1
    @dy = 0
    @snake = [{x:15, y:15}, {x:14, y:15}, {x:13, y:15}]
    @fruit = [{x:5, y:5}]
    for i in Array.from({length: 10})
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
      let x = Math.floor(Math.random() * 31)
      let y = Math.floor(Math.random() * 31)
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
    let nextX = (snakeHead:x + @dx + 31) % 31
    let nextY = (snakeHead:y + @dy + 31) % 31

    if isSnakeAt(nextX, nextY)
      gameOver
    else if isFruitAt(nextX, nextY)
      removeFruitAt(nextX, nextY)
      @snake.unshift({x: nextX, y: nextY})
      addRandomFruit
    else
      @snake.unshift({x: nextX, y: nextY})
      @snake.pop()

  def goUp
    return if @dx == 0
    @dx = 0
    @dy = -1

  def goDown
    return if @dx == 0
    @dx = 0
    @dy = 1

  def goRight
    return if @dy == 0
    @dx = 1
    @dy = 0

  def goLeft
    return if @dy == 0
    @dx = -1
    @dy = 0

  def mount
    console.log("mounted")
    setInterval(&,100) do
      if @active
        moveSnake
      Imba.commit

  def render
    <self.snake-game>
      <h2>
        "Score: "
        @score
      <svg:svg autofocus tabindex="0" :keydown.up.goUp :keydown.down.goDown :keydown.left.goLeft :keydown.right.goRight>
        <Snake[@snake] dx=@dx dy=@dy>
        for item in @fruit
          <Fruit[item]>
      <div>
        "Click on game to start. Keys to change snake direction."

tag App
  def render
    <self>
      <header>
        "Snake"
      <SnakeGame>

Imba.mount <App>
