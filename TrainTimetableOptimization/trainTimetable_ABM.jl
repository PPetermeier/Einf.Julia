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
        :stations => Dict{String, Integer}(), # id::String => capacity::Int
        :tracks => Dict{String, Track}(), # id::String => track::Track definition in spaceBuilder.jl
        :optimizedTrains => Dict{String, Vector{Int}}(), # StationID::String Array of trains stores Ids of trains per Station which are optimized to reach that station
        :passengers => Dict{Integer, Vector{Int}}() # TrainID::Int PassngerID::Int Array of PassengerIDs per train
        # Daten werden in buildGraphspaceABM eingelesen
    )
    # parsing input textfile -> Graphspace with buildGraphspace()
    model = buildGraphspaceABM(Mover, properties, file)
    return model
end

function agent_step!(agent::Mover, model)
    # Moving each Agent One Step per One Time unit
    # Phase 1: Passengers try to board trains to their destination when train is in there station which has space for their group
    # Phase 2: Trains travel their speed on their optimized train track route check if track has capacity for them and go on
    if ! agent.isTrain
        tryBoard(agent, model)
    end
end

function tryBoard(passenger::Mover, model)::Bool
    for nearbytrains in ids_in_position(passenger, model)
        train = model[nearbytrains]
        if train.isTrain && train.capacity >= passenger.groupsize
            if haskey(model.passengers, train.id)
                push!(model.passengers[train.id], passenger.id)
            else
                model.passengers[train.id] = Int[passenger.id]
            end    
            train.capacity = train.capacity - passenger.groupsize
            return true
        end
    end 
    return false
end

function moveTrain(train::Mover, model)

end

function optimizeTrains(model)
    # iterate over all trains, optimize their Timetable and store them in optimizedTrains property of the model TODO
    
    # hardcoded test Data
    model.optimizedTrains["S2"] = Int[1]
end
