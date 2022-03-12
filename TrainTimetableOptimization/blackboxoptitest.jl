using BlackBoxOptim

function rosenbrock2d(x)
  return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

res = bboptimize(rosenbrock2d; SearchRange = (-5.0, 5.0), NumDimensions = 2)

best_fitness(res) < 0.001        # Fitness is typically very close to zero here...
length(best_candidate(res)) == 2 # We get back a Float64 vector of dimension 2


