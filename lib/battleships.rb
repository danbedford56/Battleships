require 'terminal-table/import'
require 'colorize'

rows = []
rows << [" ","A", "B", "C", "D", "E", "F", "G"]
rows << ["1", "o", "o", "o", "o", "o", "o", "o"]
rows << ["2", "o", "o", "o", "o", "o", "o", "o"]
rows << ["3", "o", "o", "o", "o", "o", "o", "o"]
rows << ["4", "o", "o", "o", "o", "o", "o", "o"]
rows << ["5", "o", "o", "o", "o", "o", "o", "o"]
rows << ["6", "o", "o", "o", "o", "o", "o", "o"]
rows << ["7", "o", "o", "o", "o", "o", "o", "o"]

rows2 = []
rows2 << [" ","A", "B", "C", "D", "E", "F", "G"]
rows2 << ["1", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["2", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["3", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["4", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["5", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["6", "o", "o", "o", "o", "o", "o", "o"]
rows2 << ["7", "o", "o", "o", "o", "o", "o", "o"]

table = Terminal::Table.new :rows => rows
columnConverter = {"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7}

class Game
  def initialize(rows1, rows2)
    @playerBoard = rows1
    @opBoard = rows2
    @playerShips = []
    @aiShips = []
  end

  def placeShips(converter)
    columnConverter = converter
    @playerShips << Ship.new(4)
    @playerShips << Ship.new(3)
    @playerShips << Ship.new(2)
    @playerShips << Ship.new(2)
    row = 0
    column = ""
    direction = ""
    @playerShips.each do |ship|
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
        @playerBoard[coord[0]][coord[1]] = "S".green
        ship.coords << [coord[0],coord[1]]
      end
    end
  end

  def aiPlaceShips
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
        puts row
        puts column
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
            @opBoard[coord[0]][coord[1]] = "S".red
            ship.coords << [coord[0],coord[1]]
          end
          shipPlaced = true
        end
      end
    end
  end

  def playerMove(converter)
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

    # displays hit or miss message and damages hit ship
    if destroyed
      puts "You destroyed a ship!"
      @opBoard[strike[0]][strike[1]] = "X".red
    elsif hit
      puts "You hit!"
      @opBoard[strike[0]][strike[1]] = "X".red
    else
      puts "You missed!"
      @opBoard[strike[0]][strike[1]] = "O".blue
    end
  end

  def aiMove
    while true
      row = rand(1..7)
      column = rand(1..7)
      strike = [row, column]
      if @playerBoard[strike[0]][strike[1]] == "o"
        break
      end
    end
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

    # displays hit or miss message and damages hit ship
    if destroyed
      puts "You destroyed a ship!"
      @opBoard[strike[0]][strike[1]] = "X".red
    elsif hit
      puts "You hit!"
      @opBoard[strike[0]][strike[1]] = "X".red
    else
      puts "You missed!"
      @opBoard[strike[0]][strike[1]] = "O".blue
    end
  end

  #Unfinished
  def runGame(columnConverter)
      puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
      puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard
      playerMove(columnConverter)
      puts Terminal::Table.new :title => "Your Board:", :rows => @playerBoard
      puts Terminal::Table.new :title => "Opponent's Board:", :rows => @opBoard
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
game.aiPlaceShips
game.placeShips(columnConverter)
game.runGame(columnConverter)
