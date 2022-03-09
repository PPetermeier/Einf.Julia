using Agents
include("spaceBuilder.jl")

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Int # position in the model
    destination::Int
    isTrain::Bool
    capacity::Int # capacity of passengers in the train
    speed::Float64 # speed of the train, how many track length in one time unit can be traversed
    groupsize::Int # size of the passenger group
    targettime::Float64 # the time the passenger wants to reach its destination
end

struct Track
    trackstart::String # start station/node
    trackend::String # end station/node
    capacity::Int # max number of trains
    length::Float64
end

# Definition of functions to create specific agents (trains and passengers)
Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0, groupsize, targettime)
Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, speed, 0, 0) # problem id is not unique for train with same number as passenger

function initialize(file::String)
    # preparing additional properties
    properties = Dict(
        :stations => Dict{String, Integer}(), # id:String => capacity:Int
        :tracks => Dict{String, Track}() # id:String => track:Track definition in spaceBuilder.jl
        # Daten werden in buildGraphspaceABM eingelesen
    )
    # parsing input textfile -> Graphspace with buildGraphspace()
    model = buildGraphspaceABM(Mover, properties, file)
    return model
end

function agent_step!(agent, model)
    # Moving each Agent One Step per One Time unit

end
