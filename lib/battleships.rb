require 'terminal-table'
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

table = Terminal::Table.new :rows => rows


class Game
  def initialize(rows)
    @playerBoard = rows
    @opBoard = rows
  end

  def placeShips
    ships = []
    columnConverter = {"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7}
    ships << Ship.new(4)
    ships << Ship.new(3)
    ships << Ship.new(2)
    ships << Ship.new(2)
    row = 0
    column = ""
    direction = ""
    ships.each do |ship|
      puts "Please place your ship of size: #{ship.size}"
      puts "Enter a row to start your ship on (1-7)."
      row = gets.chomp.to_i
      puts "Enter a column to start your ship on (A-G)"
      column = gets.chomp
      #Loop to get direction until valid
      while true
        puts "Enter direction for your ship to face (up, down, left, right)"
        direction = gets.chomp
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
      end
    end

    puts Terminal::Table.new :rows => @playerBoard
  end

  #Unfinished
  def runGame
    while true
      puts "Your board:"
      puts @playerBoard
      puts "Opponent board:"
      puts @opBoard
    end
  end

end

class Ship
  attr_accessor :size

  def initialize(size)
    @size = size
    @hp = size
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

game = Game.new(rows)
game.placeShips
