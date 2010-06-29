require 'helper'
require 'flt/float'
require 'flt/tolerance'

include Flt

class TestTVM < Test::Unit::TestCase
  
  context "The TVM class" do
    
    context "using Float arithmetic" do
    
      setup do
        @context = Float.context
        @tolerance = Flt.Tolerance(3,:decimals)
        @delta = 5E-4        
        @tvm = Flt::Solver::TVM.new(@tolerance, @context)
      end
      
      should "solve correclty for :pmt" do
        sol = @tvm.solve(:t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12)
        assert_equal [:pmt], sol.keys
        assert_in_delta -55.45975978539105, sol[:pmt], @delta
      end

      should "solve correclty for :t" do
        sol = @tvm.solve(:pmt=>-55.45975978539105, :m0=>10000, :m=>0, :i=>3, :p=>12)
        assert_equal [:t], sol.keys
        assert_in_delta 240, sol[:t], @delta
      end
  
    end
    
  end

  context "using DecNum arithmetic" do
  
    setup do
      @context = Float.context
      @tolerance = Flt.Tolerance(3,:decimals)
      @delta = 5E-4        
      @tvm = Flt::Solver::TVM.new(@tolerance, @context)
    end

    should "solve correclty for :pmt" do
      sol = @tvm.solve(:t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12)
      assert_equal [:pmt], sol.keys
      assert_in_delta @context.Num('-55.45975978539105'), sol[:pmt], @delta
    end

    should "solve correclty for :t" do
      sol = @tvm.solve(:pmt=>-55.45975978539105, :m0=>10000, :m=>0, :i=>3, :p=>12)
      assert_equal [:t], sol.keys
      assert_in_delta 240, sol[:t], @delta
    end
  
  end
end