require 'helper'

class TestFunction < MiniTest::Unit::TestCase

  should "convert function to use a hash for parameters" do
    f = Flt::Solver::Function.with_named_parameters(){|x,y,z| "x=#{x} y=#{y} z=#{z}"}
    assert_equal "x=100 y=200 z=300", f[:x=>100, :y=>200, :z=>300]
    assert_equal "x=1 y=2 z=3", f[:x=>1, :y=>2, :z=>3]

    f = lambda{|x,y,z| "x=#{x} y=#{y} z=#{z}"}
    g = Flt::Solver::Function[f]
    assert_equal "x=100 y=200 z=300", g[:x=>100, :y=>200, :z=>300]
  end

  should "bind some of a function's parameters" do
    f = Flt::Solver::Function.bind(:x=>1000,:z=>2000){|x,y,z| "x=#{x} y=#{y} z=#{z}"}
    assert_equal "x=1000 y=5000 z=2000", f[5000]
    assert_equal "x=1000 y=6000 z=2000", f[6000]

    f = lambda{|x,y,z| "x=#{x} y=#{y} z=#{z}"}
    f = Flt::Solver::Function[f, :x=>1000, :z=>2000]
    assert_equal "x=1000 y=5000 z=2000", f[5000]
    assert_equal "x=1000 y=6000 z=2000", f[6000]
  end

end
