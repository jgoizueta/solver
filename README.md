# solver

This numeric solver is an example of the use of Flt.

## Examples

Solve equation `2*exp(x)-10=0` using Float, with a tolerance of 10 decimal places,
using the `SecantSolver` algorithm and with initial guesses of 0, 10:

```ruby
require 'solver'
equation = ->(x){ 2*exp(x)-10 }
algorithm = Flt::Solver::SecantSolver
tolerance = Flt::Tolerance(10, :decimals)
solver = algorithm.new(Float.context, tolerance, &equation)
puts solver.root(0, 10) # => 1.6094379124341003
```

Now, solve the same equation, with the same algorithm, but requiring greater
accuracy and using a higher precision numeric type:

```ruby
tolerance = Flt::Tolerance(25, :decimals)
solver = algorithm.new(Flt::DecNum.context(precision: 30), tolerance, &equation)
puts solver.root(0, 10) # => DecNum('1.609437912434100374600759333')
```

Let's compute the same using a different algorithm:

```ruby
algorithm = Flt::Solver::RFSecantSolver
solver = algorithm.new(Flt::DecNum.context(precision: 30), tolerance, &equation)
puts solver.root(0, 10) # => DecNum('1.609437912434100374600759333')
```

The `PSolver` class can be used to define an equation with multiple parameters, then
solve for any of them.

Let's define an equation to compute the *Time Value of Money* (i.e. compound interest):

```ruby
tvm_equation = ->(future_value, time, present_value, payment, interest, payments_per_year) {
  i = interest/100/payments_per_year
  n = -time
  k = (i + 1)**n # not the right way to compute it!
  present_value + payment*(1-k)/i + future_value*k
}
```

Note that computing `(i + 1)**n` as in this example is not a good idea, see the `TVM`
class for a better approach.

Now let's use `PSolver` to solve this equation for any of its paramters:

```ruby
tvm_solver = Flt::Solver::PSolver.new(
  Flt::DecNum.context,
  Flt.Tolerance(2,:decimals),
  &tvm_equation
)
```

For example, let's compute the monthly payment of a loan of $150,000, to be paid in twenty years
with a 7% interest rate:

```ruby
pmt = tvm_solver.root(
  :payment,
  present_value: 150000,
  future_value: 0,
  time: 20*12,
  interest: 7,
  payments_per_year: 12
)
puts s.round(2) # => -1162.95
```

A better (more accurate) financial solver is implemented by the `TVM` class:

```ruby
tvm = Flt::Solver::TVM.new(Flt.Tolerance(2,:decimals), Flt::DecNum.context)
solution = tvm.solve(t: 20*12, m0: 150000, m: 0, i: 7, p: 12)
puts solution[:pmt].round(2) # => -1162.95
```

# Licensing

Copyright (c) 2010 Javier Goizueta. See LICENSE for details.
