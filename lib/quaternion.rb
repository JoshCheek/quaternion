require 'matrix'
require "quaternion/version"

##
# Class for Quaternion calculation.
class Quaternion
  include Math
  extend Math

  ##
  # Returns an instance of Quaternion for rotateion aroud +axis+ with angle
  # +theta+.
  #   qrot = Quaternion.rotation([1.0, 1.0, 1.0], PI/2.0)
  def self.rotation axis, theta
    case axis
    when Array
      axis = Vector.elements(axis, true)
      axis = axis.normalize
    when Vector
      axis = axis.normalize
    else
      raise ArgumentError, "Invalid type"
    end

    return Quaternion.new(cos(theta/2.0), axis*sin(theta/2.0))
  end

  ##
  # Returns an instance of Quaternion.
  # The following code instanciate a quaternion of
  # q0 + q1 _i_ + q2 _j_ + q3 _k_, where q0 = 1, q1 = 2, q2 = 3 and q3 = 4.
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)         # => Quaternion(1.0; Vector[2.0, 3.0, 4.0])
  #   q = Quaternion.new(1.0, [2.0, 3.0, 4.0])       # => Quaternion(1.0; Vector[2.0, 3.0, 4.0])
  #   q = Quaternion.new(1.0, Vector[2.0, 3.0, 4.0]) # => Quaternion(1.0; Vector[2.0, 3.0, 4.0])
  def initialize *vars
    case vars.size
    when 2
      @w = vars[0]

      case vars[1]
      when Vector
        @v = vars[1].clone
      when Array
        @v = Vector.elements(vars[1], true)
      else
        raise ArgumentError, "Invalid type"
      end
    when 4
      @w = vars[0]
      @v = Vector.elements(vars[1..3], true)
    end
  end

  ##
  # Returns element +i+.
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q[0]  # => 1.0
  #   q[:w] # => 1.0
  #   q[:x] # => 2.0
  #   q[:y] # => 3.0
  #   q[:z] # => 4.0
  #   q[:v] # => Vector[2.0, 3.0, 4.0]
  def [] i
    case i
    when :w, 0
      return @w
    when :x, 1
      return @v[0]
    when :y, 2
      return @v[1]
    when :z, 3
      return @v[2]
    when :v
      return @v
    else
      raise ArgumentError, "Invalid index"
    end
  end

  ##
  # Sets +var+ to element +i+
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q[0] = 0.0
  #   q # => Quaternion(0.0; Vector[2.0, 3.0, 4.0])
  def []= i, var
    case i
    when :w, 0
      @w = var
    when :x, 1
      @v = Vector.elements([var, @v[1], @v[2]])
    when :y, 2
      @v = Vector.elements([@v[0], var, @v[2]])
    when :z, 3
      @v = Vector.elements([@v[0], @v[1], var])
    when :v
      if var.is_a?(Array)
        @v = Vector.elements(var, true)
      elsif var.is_a?(Vector)
        @v = var
      else
        raise ArgumentError, "Invalid type. Should be Array or Vector"
      end
    else
      raise ArgumentError, "Invalid index"
    end
  end

  ##
  # Compares with other Quaternion
  def == other
    if other.is_a?(self.class)
      if (@w == other[:w]) and (@v == other[:v])
        return true
      else
        return false
      end
    else
      return false
    end
  end

  ##
  # Returns result of addition.
  #   q1 = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q2 = Quaternion.new(5.0, 6.0, 7.0, 8.0)
  #   q1 + q2 # => Quaternion(6.0; Vector[8.0, 10.0, 12.0])
  def + other
    w = @w + other[:w]
    v = @v + other[:v]

    return Quaternion.new(w, v)
  end

  ##
  # Returns result of subtraction
  #   q1 = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q2 = Quaternion.new(5.0, 4.0, 3.0, 2.0)
  #   q1 - q2 # => Quaternion(-4.0; Vector[-2.0, 0.0, 2.0])
  def - other
    w = @w - other[:w]
    v = @v - other[:v]

    return Quaternion.new(w, v)
  end

  ##
  # Returns product with +other+.
  # +other+ can be Quaternion or Numeric.
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q*2 # => Quarternion(2.0; Vector[4.0, 6.0, 8.0])
  #
  #   q1 = Quaternion.new(1.0, 4.0, 5.0, 6.0)
  #   q*q1 # => Quaternion(-46.0, Vector[4.0, 12.0, 8.0])
  def * other
    case other
    when self.class
      w = @w*other[:w] - @v.inner_product(other[:v])
      v = @w*other[:v] + @v*other[:w] + @v.cross_product(other[:v])

      return self.class.new(w, v)
    when Numeric
      w = @w*other
      v = @v*other

      return self.class.new(w, v)
    else
      raise ArgumentError, "Invalide type"
    end
  end

  ##
  # Devision by a scalar +other+.
  # Returns Quaternion with each element is divided by +other+.
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q/2 # => Quaternion(0.5; Vector[1.0, 1.5, 2.0])
  def / other
    case other
    when Numeric
      w = @w/other
      v = @v/other

      return self.class.new(w, v)
    else
      raise ArgumentError, "Invalid type"
    end
  end

  ##
  # Returns conjugate of +self+
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q.conjugate # => Quaternion(1.0; Vector[-2.0, -3.0, -4.0])
  def conjugate
    return self.class.new(@w, -@v)
  end

  ##
  # Returns norm of +self+
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q.norm # => 5.477225575051661
  def norm
    return sqrt(@w**2 + @v.inner_product(@v))
  end
  alias magnitude norm

  ##
  # Returns inverse of +self+.
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q.inverse # => Quaternion(0.03333333333333333; Vector[-0.06666666666666667, -0.1, -0.13333333333333333])
  def inverse
    return (self.conjugate)/(self.norm**2)
  end

  ##
  # Returns normailzed Quaternion
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q.normalize # => Quaternion(0.18257418583505536; Vector[0.3651483716701107, 0.5477225575051661, 0.7302967433402214])
  def normalize
    return self/self.magnitude
  end

  ##
  # Destructive method of Quaternion#normalize
  def normalize!
    m = self.magnitude

    @w /= m
    @v /= m

    return self
  end

  ##
  # Returns string expression of self
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   q.inspect # => "Quaternion(1.0; Vector[2.0, 3.0, 4.0])"
  def inspect
    return "Quaternion(#{@w}; #{@v})"
  end
  alias to_s inspect

  ##
  # Rotates a point +v+. This method does not check if the quaternion's norm is
  # 1 or not.
  #   qrot = Quaternion.rotation([1.0, 1.0, 1.0], PI/2.0)
  #   qrot.rotate([1.0, 0.0, 0.0]) # =>[0.3333333333333334, 0.9106836025229592, -0.24401693585629253]
  def rotate v
    q_v = Quaternion.new(0.0, v)

    res = self*q_v*(self.conjugate)

    case v
    when Array
      return res[:v].to_a
    when Vector
      return res[:v]
    end
  end

  ##
  # Inverts order of multiplication, so our math methods
  # will be used for types that don't know how to deal Quaternions
  #   q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  #   2*q # => Quarternion(2.0; Vector[4.0, 6.0, 8.0])
  def coerce(n)
    [self, n]
  end

  private
  def to_vector v
    case v
    when Array
      Vector.elements(v, true)
    when Vector
      v.clone
    else
      raise ArgumentError, "Fail to convert to Vector"
    end
  end
end
