require 'helper'
require 'flt/float'
require 'flt/tolerance'

include Flt

class TestTVM < MiniTest::Unit::TestCase

  context "The TVM class" do

    context "using Float arithmetic" do

      setup do
        @context = Float.context
        @tolerance = Flt.Tolerance(2,:decimals)
        @delta = 5E-3
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

      should "solve correclty for :m" do
        sol = @tvm.solve(:t=>63, :m0=>0, :pmt=>-1000000, :i=>@context.Num('0.00000161')*12, :p=>12)
        assert_equal [:m], sol.keys
        assert_in_delta @context.Num('63000031.4433'), sol[:m],  @delta

        n = 31536000
        sol = @tvm.solve(:t=>n, :m0=>0, :pmt=>-@context.Num('0.01'), :i=>@context.Num(10)/n, :p=>1)
        assert_equal [:m], sol.keys
        assert_in_delta @context.Num('331667.006691'), sol[:m], @delta
      end

    end

  end

  context "using DecNum arithmetic" do

    setup do
      @context = Flt::DecNum.context
      @tolerance = Flt.Tolerance(3,:decimals)
      @delta = @context.Num('5E-4')
      @tvm = Flt::Solver::TVM.new(@tolerance, @context)
    end

    should "solve correclty for :pmt" do
      sol = @tvm.solve(:t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12)
      assert_equal [:pmt], sol.keys
      assert_in_delta @context.Num('-55.45975978539105'), sol[:pmt], @delta
    end

    should "solve correclty for :t" do
      sol = @tvm.solve(:pmt=>@context.Num('-55.45975978539105'), :m0=>10000, :m=>0, :i=>3, :p=>12)
      assert_equal [:t], sol.keys
      assert_in_delta 240, sol[:t], @delta
    end

    should "solve correclty for :m" do
      sol = @tvm.solve(:t=>63, :m0=>0, :pmt=>-1000000, :i=>@context.Num('0.00000161')*12, :p=>12)
      assert_equal [:m], sol.keys
      assert_in_delta @context.Num('63000031.4433'), sol[:m], @delta

      n = 31536000
      sol = @tvm.solve(:t=>n, :m0=>0, :pmt=>-@context.Num('0.01'), :i=>@context.Num(10)/n, :p=>1)
      assert_equal [:m], sol.keys
      assert_in_delta @context.Num('331667.006691'), sol[:m], @delta
    end

    context "and high precision" do
      setup do
        @context.precision = 28
        @tolerance = Tolerance(12, :sig_decimals)
        @tvm = Flt::Solver::TVM.new(@tolerance, @context)
      end

      should "solve correclty for :pmt" do
        sol = @tvm.solve(:t=>240, :m0=>10000, :m=>0, :i=>3, :p=>12)
        assert_equal [:pmt], sol.keys
        expected = @context.Num('-55.45975978539105')
        assert_in_delta expected, sol[:pmt], @tolerance.value(expected)
      end

      should "solve correclty for :t" do
        sol = @tvm.solve(:pmt=>@context.Num('-55.45975978539105'), :m0=>10000, :m=>0, :i=>3, :p=>12)
        assert_equal [:t], sol.keys
        expected = @context.Num('240')
        assert_in_delta expected, sol[:t], @tolerance.value(expected)
      end

      should "solve correclty for :m" do
        sol = @tvm.solve(:t=>63, :m0=>0, :pmt=>-1000000, :i=>@context.Num('0.00000161')*12, :p=>12)
        assert_equal [:m], sol.keys
        expected = @context.Num('63000031.4433')
        assert_in_delta expected, sol[:m], @tolerance.value(expected)

        n = 31536000
        sol = @tvm.solve(:t=>n, :m0=>0, :pmt=>-@context.Num('0.01'), :i=>@context.Num(10)/n, :p=>1)
        assert_equal [:m], sol.keys
        expected = @context.Num('331667.006691')
        assert_in_delta expected, sol[:m], @tolerance.value(expected)
      end

    end
  end
end