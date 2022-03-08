using Agents
include("spaceBuilder.jl")

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Int # position in the model
    destination::Int
    isTrain::Bool
    capacity::Int
    speed::Float64
    groupsize::Int
    targettime::Int
end

# Definition of functions to create specific agents (trains and passengers)
Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0, groupsize, targettime)
Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, speed, 0, 0)

function initialize()
    # preparing additional properties
    properties = Dict(
        #=
        :bahnhoefe => Dict()
        :Strecken => Dict()
        # ... usw Daten werden in buildGraphspaceABM eingelesen
        =#
    )
    # parsing input textfile -> Graphspace with buildGraphspace()
    model = buildGraphspaceABM(Mover, properties)
    return model
end

function agent_step!(agent, model)
    # Moving each Agent One Step per One Time unit

end
