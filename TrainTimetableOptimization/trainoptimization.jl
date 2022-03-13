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
        100;
        mdata = [efficiency],
        when_model = [100],
        replicates = 10,
    )

    return mean(data.efficiency)
end

flexibeltrains01 = potentialstations(8)
trainrange = (first(flexibeltrains01), last(flexibeltrains01))
result = bboptimize(
    cost,
    SearchRange = [
        trainrange,
        trainrange,
        trainrange,
        trainrange,
        trainrange,
        trainrange,
        trainrange,
        trainrange,
    ],
    NumDimensions = 8,
    MaxTime = 40
)
best_fitness(result)
best_candidate(result)