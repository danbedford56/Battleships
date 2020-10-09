require 'terminal-table/import'

WATER = "\u{1F30A}"
BOAT = "\u{1F6A2}"
EXPLOSION = "\u{1F4A5}"
MISS = "\u{274C}"

rows = []
rows << [" ","A", "B", "C", "D", "E", "F", "G"]
rows << ["1", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["2", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["3", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["4", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["5", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["6", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows << ["7", WATER, WATER, WATER, WATER, WATER, WATER, WATER]

rows2 = []
rows2 << [" ","A", "B", "C", "D", "E", "F", "G"]
rows2 << ["1", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["2", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["3", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["4", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["5", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["6", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
rows2 << ["7", WATER, WATER, WATER, WATER, WATER, WATER, WATER]

columnConverter = {"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7}

class Game
  def initialize(rows1, rows2)
    @playerBoard = rows1
    @opBoard = rows2
    @playerShips = []
    @aiShips = []
  end

  def validateCell(row, column)
    if column == nil
      return false
    elsif column >= 1 && column <= 7 && row >= 1 && row <= 7
      return true
    else
      return false
    end
  end

  def placeShips(converter, boat)
    @playerShips << Ship.new(4)
    @playerShips << Ship.new(3)
    @playerShips << Ship.new(2)
    @playerShips << Ship.new(2)
    direction = ""
    @playerShips.each do |ship|
      shipPlaced = false
      system "clear"
      while shipPlaced == false
        puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
        puts "Please place your ship of size: #{ship.size}"
        cellValid = false
        while !cellValid
          puts "Enter a cell to start your ship (letter first)"
          cell = gets.chomp.split("")
          row = cell[1].to_i
          column = converter[cell[0].upcase]
          cellValid = validateCell(row, column)
          if !cellValid
            puts "Invalid cell!"
          end
        end

        directionValid = false
        #Loop to get direction until valid
        while directionValid == false
          # Input validation
          while true
            directions = ["up", "down", "left", "right"]
            puts "Enter direction for your ship to face (up, down, left, right)"
            direction = gets.chomp
            if !directions.include?(direction)
              puts "Invalid direction."
            else
              break
            end
          end
          if direction == "up" && (row - (ship.size - 1) < 1)
            puts "Ship does not fit."
          elsif direction == "down" && (row + (ship.size - 1) > 7)
            puts "Ship does not fit."
          elsif direction == "left" && (column - (ship.size - 1) < 1)
            puts "Ship does not fit."
          elsif direction == "right" && (column + (ship.size - 1) > 7)
            puts "Ship does not fit."
          else
            directionValid = true
          end
        end

        #Set ship coords
        shipCoords = []
        shipCoords << [row, column]
        case direction
        when "up"
          for i in 1..(ship.size - 1) do
            shipCoords << [row - i, column]
          end
        when "down"
          for i in 1..(ship.size - 1) do
            shipCoords << [row + i, column]
          end
        when "left"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column - i]
          end
        when "right"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column + i]
          end
        end

        # Checks if ship clashes with previously placed ships
        clashing = false
        shipCoords.each do |coord|
          @playerShips.each do |pShip|
            pShip.coords.each do |coord2|
              if coord == coord2
                clashing = true
              end
            end
          end
        end

        # Places ship if not clashing
        if !clashing
          # Place ships on board
          shipCoords.each do |coord|
            @playerBoard[coord[0]][coord[1]] = boat
            ship.coords << [coord[0],coord[1]]
          end
          shipPlaced = true
        end

        if !shipPlaced
          system "clear"
          puts "This clashes with another ship! Please re-enter"
        end
      end
    end
  end

  def aiPlaceShips(boat)
    directions = ["right", "left", "up", "down"]
    @aiShips << Ship.new(4)
    @aiShips << Ship.new(3)
    @aiShips << Ship.new(2)
    @aiShips << Ship.new(2)
    @aiShips.each do |ship|
      # while true to re-place if ship clashes
      shipPlaced = false
      while !shipPlaced
        row = rand(1..7)
        column = rand(1..7)
        direction = ""
        # Sets random direction until valid
        while true
          direction = directions[rand(0..4)]
          if direction == "up" && (row - ship.size >= 0)
            break
          elsif direction == "down" && (row + ship.size <= 7)
            break
          elsif direction == "left" && (column - ship.size >= 0)
            break
          elsif direction == "right" && (column + ship.size <= 7)
            break
          end
        end

        # Pushes ship coordinates
        shipCoords = []
        shipCoords << [row, column]
        case direction
        when "up"
          for i in 1..(ship.size - 1) do
            shipCoords << [row - i, column]
          end
        when "down"
          for i in 1..(ship.size - 1) do
            shipCoords << [row + i, column]
          end
        when "left"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column - i]
          end
        when "right"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column + i]
          end
        end

        # Checks if ship clashes with previously placed ships
        clashing = false
        shipCoords.each do |coord|
          @aiShips.each do |aiShip|
            aiShip.coords.each do |coord2|
              if coord == coord2
                clashing = true
              end
            end
          end
        end

        # Places ship if not clashing
        if !clashing
          shipCoords.each do |coord|
            # For testing AI placement: @opBoard[coord[0]][coord[1]] = boat
            ship.coords << [coord[0],coord[1]]
          end
          shipPlaced = true
        end
      end
    end
  end

  def aiMove(playerBoard, miss, explosion, ai)
    strike = ai.calculateStrike(playerBoard, miss, explosion)
    hit = false
    destroyed = false
    # Checks if strike is true
    @playerShips.each do |ship|
      ship.coords.each do |coord|
        if strike == coord
          hit = true
          ai.previousStrikeHit = true
          ship.damage
          if ship.isDead
            destroyed = true
            @playerShips.delete(ship)
          end
          break
        else
          ai.previousStrikeHit = false
        end
      end
      if hit
        break
      end
    end
    if destroyed
      puts "Your opponent destroyed a ship!"
      @playerBoard[strike[0]][strike[1]] = explosion
      ai.previousStrikeHit = false
    elsif hit
      puts "Your opponent hit!"
      @playerBoard[strike[0]][strike[1]] = explosion
    else
      puts "Your opponent missed!"
      @playerBoard[strike[0]][strike[1]] = miss
    end
  end

  def playerMove(converter, explosion, miss)
    cellValid = false
    while !cellValid
      puts "Enter cell to strike (Letter First):"
      cell = gets.chomp.split("")
      column = converter[cell[0].upcase]
      row = cell[1].to_i
      cellValid = validateCell(row, column)
      if @opBoard[row][column] == miss || @opBoard[row][column] == explosion
        cellValid = false
      end
      if !cellValid
        puts "Invalid cell!"
      end
    end
    strike = [row, column]
    hit = false
    destroyed = false

    # Checks if strike is true
    @aiShips.each do |aiShip|
      aiShip.coords.each do |coord|
        if strike == coord
          hit = true
          aiShip.damage
          if aiShip.isDead
            destroyed = true
            @aiShips.delete(aiShip)
          end
          break
        end
      end
      if hit
        break
      end
    end

    system "clear"
    # displays hit or miss message and damages hit ship
    if destroyed
      puts "You destroyed a ship!"
      @opBoard[strike[0]][strike[1]] = explosion
    elsif hit
      puts "You hit!"
      @opBoard[strike[0]][strike[1]] = explosion
    else
      puts "You missed!"
      @opBoard[strike[0]][strike[1]] = miss
    end
  end

  def runGame(converter, water, boat, explosion, miss)
    gameRunning = true
    ai = AI.new
    # Ship placement
    aiPlaceShips(boat)
    placeShips(converter, boat)
    system "clear"
    puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
    puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard

    # Main game loop
    while gameRunning == true
      playerMove(converter, explosion, miss)
      aiMove(@playerBoard, miss, explosion, ai)
      puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
      puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard
      # Win/loss check
      if @playerShips.length == 0
        puts "You lose!"
        gameRunning = false
      elsif @aiShips.length == 0
        puts "You win!"
        gameRunning = false
      end
    end
  end
end

class Ship
  attr_accessor :size
  attr_accessor :coords

  def initialize(size)
    @size = size
    @hp = size
    @coords = []
  end

  def damage
    @hp -= 1
  end

  def isDead
    if @hp == 0
      return true
    else
      return false
    end
  end
end

# UNFINISHED AND NOT IN-GAME

class AI
  attr_accessor :previousStrikeHit

  def initialize
    @previousStrikeHit = false
    @previousStrike = []
  end

  def calculateStrike(playerBoard, miss, explosion)
    if !@previousStrikeHit
      # Find random cell to strike
      @previousStrike = getRandomStrike(playerBoard, miss, explosion)
      return @previousStrike
    else
      # check above
      if @previousStrike[0] == 1 || playerBoard[@previousStrike[0] - 1][@previousStrike[1]] == miss || playerBoard[@previousStrike[0] - 1][@previousStrike[1]] == explosion
        # check below
        if @previousStrike[0] == 7 || playerBoard[@previousStrike[0] + 1][@previousStrike[1]] == miss || playerBoard[@previousStrike[0] + 1][@previousStrike[1]] == explosion
          # check left
          if @previousStrike[1] == 1 || playerBoard[@previousStrike[0]][@previousStrike[1] - 1] == miss || playerBoard[@previousStrike[0]][@previousStrike[1] - 1] == explosion
            # check right
            if @previousStrike[1] == 7 || playerBoard[@previousStrike[0]][@previousStrike[1] + 1] == miss || playerBoard[@previousStrike[0]][@previousStrike[1] + 1] == explosion
              @previousStrike = getRandomStrike(playerBoard, miss, explosion)
              return @previousStrike
            else
              # return cell to the right
              @previousStrike[1] += 1
              return @previousStrike
            end
          else
            # return cell to the left
            @previousStrike[1] -= 1
            return @previousStrike
          end
        else
          # return cell below
          @previousStrike[0] += 1
          return @previousStrike
        end
      else
        # return cell above
        @previousStrike[0] -= 1
        return @previousStrike
      end
    end
  end

  def getRandomStrike(playerBoard, miss, explosion)
    while true
      row = rand(1..7)
      column = rand(1..7)
      strike = [row, column]
      if playerBoard[strike[0]][strike[1]] != miss && playerBoard[strike[0]][strike[1]] != explosion
        break
      end
    end
    return strike
  end
end

game = Game.new(rows, rows2)
game.runGame(columnConverter,WATER, BOAT, EXPLOSION, MISS)
