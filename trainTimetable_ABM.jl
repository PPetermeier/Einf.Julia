using Agents

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Tuple{Int,Float64} # position in the model with progress to next stop in percent
    route::Vector{Int}
    destination::Int
    isTrain::Bool
    capacity::Int
end

# Definition of functions to create specific agents (trains and passengers)
Passenger(id, pos, route, destination) = Mover(id, pos, route, destination, false, 0)
Train(id, pos, route, destination, capacity) = Mover(id, pos, route, destination, true, capacity)

function initialize(; numagents = 12)
    # parsing input textfile -> Graphspace
    #space = GraphSpace()

end

function agent_step!(agent, model)
    # Moving each Agent One Step per One Time unit

end
