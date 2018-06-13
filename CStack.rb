require './MatrixUtils.rb'
require './Matrix.rb'

class CStack
  # Wrapper class CStack makes it easy to work with co-ord systems in a stacky way

  def initialize()
    @data = []
    @data.push(MatrixUtils.identity(4))
  end

  def pop()
    @data.pop()
  end

  # Parser push, not stack push
      # Places a copy of the current top on the top
  def push()
    @data.push(@data[-1].copy())
  end

  def peek()
    @data[-1]
  end

  def modify_top(transformation)
    @data.push(MatrixUtils.multiply(@data.pop(), transformation, modify_second: false))
  end

  def to_str to_s; end
  def to_s
    ret = "\nSTACK IS OF LENGTH #{@data.length}\nBOTTOM OF STACK\n"
    for i in (0...@data.length)
      ret+= "ELEMENT #{i}\n #{@data[i]}"
    end
    ret += "TOP OF STACK\n"
  end
end
