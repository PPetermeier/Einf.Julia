using Agents, DataFrames
include("spaceBuilder.jl")

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Int # position in the model
    destination::Int
    isTrain::Bool
    capacity::Int # capacity of passengers in the train
    activeRoute::Vector{Int64} # active Route of the train
    trackprogress::Float64 # 0 if in station 
    speed::Float64 # speed of the train, how many track length in one time unit can be traversed
    onBoard::Int # train id if the passenger boarded one
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
Passenger(id, pos, destination, groupsize, targettime) = Mover(id+5000, pos, destination, false, 0, Int64[], 0, 0, 0, groupsize, targettime) # Passenger IDs start on 5001 to avoid conflicts with train Agent Ids
Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, Int64[], 0, speed, 0, 0, 0)# max id is 5000
Train(id, pos, destination, capacity, activeRoute, speed) = Mover(id, pos, destination, true, capacity, activeRoute, 0, speed, 0, 0, 0)# max id is 5000

function initialize(file::String)
    # preparing additional properties
    properties = Dict(
        :stations => Dict{String, Integer}(), # id::String => capacity::Int
        :tracks => Dict{String, Track}(), # id::String => track::Track definition in spaceBuilder.jl
        :passengers => Dict{Integer, Vector{Int}}(), # TrainID::Int PassngerID::Int Array of PassengerIDs per train
        :lines => DataFrame()
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
    for nearbyagents in ids_in_position(passenger, model)
        agent = model[nearbyagents]
        println(agent)
        if agent.isTrain && agent.capacity >= passenger.groupsize && in(passenger.destination, agent.activeRoute)
            println()
            println(haskey(model.passengers, agent.id))
            println()
            if haskey(model.passengers, agent.id) # look if there is allready a passenger list for the train and if not make one
                push!(model.passengers[agent.id], passenger.id) # passenger added to the central passenger list of all trains in the model
                passenger.onBoard = agent.id # passenger saves on which train it is
                agent.capacity = agent.capacity - passenger.groupsize # capacity of train agent is updated
            else
                println("erstelle Vektor")
                passengers[int(agent.id)] = [passenger.id]
            end
            return true
        end
    end 
    return false
end

function moveTrain(train::Mover, model)

end

function optimizeTrains(model)
    # iterate over all trains, optimize their Timetable and store them in optimizedTrains property of the model TODO
    
end
