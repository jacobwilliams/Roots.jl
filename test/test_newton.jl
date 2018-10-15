using Compat.Test
import Roots.newton, Roots.halley

@test abs(newton(sin, cos, 0.5) - 0.0) <= 100*eps(1.0)
@test newton(cos, x -> -sin(x), 1.0)  ≈ pi/2
@test newton(x -> x^2 - 2x - 1, x -> 2x - 2, 3.0)  ≈ 2.414213562373095
@test abs(newton(x -> exp(x) - cos(x), x -> exp(x) + sin(x), 3.0) - 0.0) <= 1e-14
@test halley(x -> x^2 - 2x - 1,x -> 2x - 2,x -> 2, 3.0)  ≈ 2.414213562373095
a = halley(x -> exp(x) - cos(x),
           x -> exp(x) + sin(x),
           x -> exp(x) + cos(x), 3.0)
@test abs(a - 0.0) <= 1e-14



## test with Complex input

@test real(Roots.newton(x ->  x^3 - 1, x ->  3x^2, 1+im)) ≈ 1.0
@test real(Roots.newton(x ->  x^3 - 1, x ->  3x^2, 1+10im)) ≈ (-1/2)

## Issue #143 test with new interface
Roots.newton(sin, cos, 3.0) ≈ π # uses find_zero
Roots.newton((sin,cos), 3.0) ≈ π # uses simple

fdf = x -> (sin(x), sin(x)/cos(x))  # (f, f/f')
@test Roots.find_zero(fdf, 3.0, Roots.Newton())  ≈ π # uses find_zero
Roots.newton(fdf, 3.0)  ≈ π # uses simple

fdfdf = x -> (sin(x), sin(x)/cos(x), -cos(x)/sin(x))   # (f, f/f', f'/f'')
@test Roots.find_zero(fdfdf, 3.0, Roots.Halley()) ≈ π

# check that functions with multiple return values can work with other
# methods
for M in [Roots.Halley(), Roots.Newton(), Roots.Order1(), Roots.Order0()]
    @test Roots.find_zero(fdfdf, 3.0, M) ≈ π  # can pass function to others
end
for M in [Roots.Bisection(), Roots.A42(), Roots.AlefeldPotraShi()]
    @test Roots.find_zero(fdfdf, (3.0, 4.0), M) ≈ π  # can pass function to others
end
@test find_zero(x -> (x^2 -2, (x^2-2)/2x), 1.0, Roots.Newton(), Roots.Bisection()) ≈ sqrt(2)
