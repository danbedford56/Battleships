require 'terminal-table/import'
require 'colorize'
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

  def placeShips(converter, boat)
    columnConverter = converter
    @playerShips << Ship.new(4)
    @playerShips << Ship.new(3)
    @playerShips << Ship.new(2)
    @playerShips << Ship.new(2)
    row = 0
    column = ""
    direction = ""
    @playerShips.each do |ship|
      system "clear"
      puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
      puts "Please place your ship of size: #{ship.size}"
      puts "Enter a row to start your ship on (1-7)."
      row = gets.chomp.to_i
      puts "Enter a column to start your ship on (A-G)"
      column = gets.chomp

      #Loop to get direction until valid
      while true
        # Input validation
        while true
          puts "Enter direction for your ship to face (up, down, left, right)"
          direction = gets.chomp
          if direction != "up" && direction != "down" && direction != "left" && direction != "right"
            puts "Invalid direction."
          else
            break
          end
        end
        if direction == "up" && (row - (ship.size - 1) < 0)
          puts "Ship does not fit."
        elsif direction == "down" && (row + (ship.size - 1) > 7)
          puts "Ship does not fit."
        elsif direction == "left" && (columnConverter[column.upcase] - (ship.size - 1) < 0)
          puts "Ship does not fit."
        elsif direction == "right" && (columnConverter[column.upcase] + (ship.size - 1) > 7)
          puts "Ship does not fit."
        else
          break
        end
      end

      #Set ship coords
      shipCoords = []
      shipCoords << [row, columnConverter[column.upcase]]
      case direction
      when "up"
        for i in 1..(ship.size - 1) do
          shipCoords << [row - i, columnConverter[column.upcase]]
        end
      when "down"
        for i in 1..(ship.size - 1) do
          shipCoords << [row + i, columnConverter[column.upcase]]
        end
      when "left"
        for i in 1..(ship.size - 1) do
          shipCoords << [row, columnConverter[column.upcase] - i]
        end
      when "right"
        for i in 1..(ship.size - 1) do
          shipCoords << [row, columnConverter[column.upcase] + i]
        end
      end

      # Place ships on board
      shipCoords.each do |coord|
        @playerBoard[coord[0]][coord[1]] = boat
        ship.coords << [coord[0],coord[1]]
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
      while shipPlaced == false
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
            # For testing AI placement:@opBoard[coord[0]][coord[1]] = boat
            ship.coords << [coord[0],coord[1]]
          end
          shipPlaced = true
        end
      end
    end
  end

  def playerMove(converter, explosion, miss)
    puts "Enter row to strike:"
    row = gets.chomp.to_i
    puts "Enter column to strike:"
    column = converter[gets.chomp.upcase]
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

  def aiMove(miss, explosion)
    while true
      row = rand(1..7)
      column = rand(1..7)
      strike = [row, column]
      if @playerBoard[strike[0]][strike[1]] != miss
        break
      end
    end

    hit = false
    destroyed = false
    # Checks if strike is true
    @playerShips.each do |ship|
      ship.coords.each do |coord|
        if strike == coord
          hit = true
          ship.damage
          if ship.isDead
            destroyed = true
            @playerShips.delete(ship)
          end
          break
        end
      end
      if hit
        break
      end
    end
    if destroyed
      puts "Your opponent destroyed a ship!"
      @playerBoard[strike[0]][strike[1]] = explosion
    elsif hit
      puts "Your opponent hit!"
      @playerBoard[strike[0]][strike[1]] = explosion
    else
      puts "Your opponent missed!"
      @playerBoard[strike[0]][strike[1]] = miss
    end
  end

  #Unfinished
  def runGame(columnConverter, water, boat, explosion, miss)
    gameRunning = true
    aiPlaceShips(boat)
    placeShips(columnConverter, boat)
    system "clear"
    puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
    puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard
    while gameRunning == true
      playerMove(columnConverter, explosion, miss)
      aiMove(miss, explosion)
      puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
      puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard
      if @playerShips.length == 0
        puts "You lose!"
        break
      elsif @aiShips.length == 0
        puts "You win!"
        break
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

game = Game.new(rows, rows2)
game.runGame(columnConverter,WATER, BOAT, EXPLOSION, MISS)
