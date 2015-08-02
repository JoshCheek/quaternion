require_relative "minitest_helper"

class TestQuaternion < Minitest::Test
  include MinitestHelper
  include Math

  def setup
    @q = Quaternion.new(1.0, 2.0, 3.0, 4.0)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Quaternion::VERSION
  end

  def test_rotation
    actual = Quaternion.rotation([1.0, 1.0, 1.0], PI/2.0)

    w = cos(PI/4.0)
    x = sin(PI/4.0)/sqrt(3.0)
    y = sin(PI/4.0)/sqrt(3.0)
    z = sin(PI/4.0)/sqrt(3.0)
    expected = Quaternion.new(w, x, y, z)
    quaternion_assert_in_delta(expected, actual)
  end

  def test_getter
    assert_equal(1.0, @q[0])
    assert_equal(1.0, @q[:w])

    assert_equal(2.0, @q[1])
    assert_equal(2.0, @q[:x])

    assert_equal(3.0, @q[2])
    assert_equal(3.0, @q[:y])

    assert_equal(4.0, @q[3])
    assert_equal(4.0, @q[:z])

    assert_equal(Vector[2.0, 3.0, 4.0], @q[:v])

    assert_raises(ArgumentError) {
      @q[4]
    }
  end

  def test_setter
    @q[0] = -1.0
    expected = Quaternion.new(-1.0, 2.0, 3.0, 4.0)
    quaternion_assert_in_delta(expected, @q)

    @q[1] = -2.0
    expected = Quaternion.new(-1.0, -2.0, 3.0, 4.0)
    quaternion_assert_in_delta(expected, @q)

    @q[2] = -3.0
    expected = Quaternion.new(-1.0, -2.0, -3.0, 4.0)
    quaternion_assert_in_delta(expected, @q)

    @q[3] = -4.0
    expected = Quaternion.new(-1.0, -2.0, -3.0, -4.0)
    quaternion_assert_in_delta(expected, @q)

    @q[:v] = Vector[5.0, 6.0, 7.0]
    expected = Quaternion.new(-1.0, 5.0, 6.0, 7.0)
    quaternion_assert_in_delta(expected, @q)
  end

  def test_compare
    assert(@q == Quaternion.new(1.0, 2.0, 3.0, 4.0))
  end

  def test_add
    expected = Quaternion.new(6.0, 8.0, 10.0, 12.0)
    quaternion_assert_in_delta(expected, @q + Quaternion.new(5, 6, 7, 8))
  end

  def test_sub
    expected = Quaternion.new(-4.0, -2.0, 0.0, 2.0)
    quaternion_assert_in_delta(expected, @q - Quaternion.new(5, 4, 3, 2))
  end

  def test_multiply
    expected = Quaternion.new(2.0, 4.0, 6.0, 8.0)
    quaternion_assert_in_delta(expected, @q*2)
    quaternion_assert_in_delta(expected, 2*@q)
    quaternion_assert_in_delta(expected, 2.0*@q)

    q        = Quaternion.new(1.0, 4.0, 5.0, 6.0)
    expected = Quaternion.new(-46.0, 4.0, 12.0, 8.0)
    quaternion_assert_in_delta(expected, @q*q)
  end

  def test_divide
    expected = Quaternion.new(0.5, 1.0, 1.5, 2.0)
    quaternion_assert_in_delta(expected, @q/2.0)
  end

  def test_conjugate
    expected = Quaternion.new(1.0, -2.0, -3.0, -4.0)
    quaternion_assert_in_delta(expected, @q.conjugate)
  end

  def test_norm
    expected = Math.sqrt(30.0)

    assert_in_delta(expected, @q.norm)
  end

  def test_inverse
    expected = Quaternion.new(1.0/30.0, -2.0/30.0, -3.0/30.0, -4.0/30.0)

    quaternion_assert_in_delta(expected, @q.inverse)

    quaternion_assert_in_delta(Quaternion.new(1.0, 0.0, 0.0, 0.0), @q*(@q.inverse))
  end

  def test_normalize
    m = Math.sqrt(30.0)
    expected = Quaternion.new(1.0/m, 2.0/m, 3.0/m, 4.0/m)

    quaternion_assert_in_delta(expected, @q.normalize)
  end

  def test_normalize!
    m = Math.sqrt(30.0)
    expected = Quaternion.new(1.0/m, 2.0/m, 3.0/m, 4.0/m)
    @q.normalize!

    quaternion_assert_in_delta(expected, @q)
  end

  def test_rotate
    qrot = Quaternion.rotation([1.0, 1.0, 1.0], PI/2.0)

    v = [1.0, 0.0, 0.0]

    expected = [0.3333333333333334, 0.9106836025229592, -0.24401693585629253]
    actual   = qrot.rotate(v)

    expected.zip(actual) {|e, a| assert_in_delta(e, a)}
  end
end

