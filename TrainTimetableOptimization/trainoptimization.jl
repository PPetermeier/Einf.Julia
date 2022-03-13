using BlackBoxOptim
include("trainTimetable_ABM.jl")
include("potentialstations.jl")


function cost(potentialstations)
    model = initialize("InfomaticCup//test//simple//input.txt", potentialstations)

    efficiency(model) =
        sum(for agent in allagents(model)
        agent.targettime - agent.arrivaltime
    end)

    _, data =run!(
        model,
        agent_step!,
        40;
        mdata = [efficiency],
        when_model = [40],
        replicates = 10,
    )

    return mean(data.efficiency)
end

flexibeltrains01 = potentialstations(8)
result = bboptimize(
    cost,
    SearchRange = [
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
        flexibeltrains01,
    ],
    NumDimensions = 8,
    MaxTime = 40
)
println(best_fitness(result))
println(best_candidate(result))