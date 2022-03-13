using Agents, DataFrames, MetaGraphs, LightGraphs
include("spaceBuilder.jl")

mutable struct Mover <: AbstractAgent
    id::Int
    pos::Int # position in the model
    destination::Int
    isTrain::Bool
    capacity::Int # capacity of passengers in the train
    trackprogress::Float64 # 0 if in station 
    speed::Float64 # speed of the train, how many track length in one time unit can be traversed
    onBoard::Int # train id if the passenger boarded one
    groupsize::Int # size of the passenger group
    targettime::Int # the time the passenger wants to reach its destination
end

# mutable struct Station
#     capacity::Int # max number of trains
#     tracks::Dict{Int, Track} # Tracks starting in theis station per endstationId
# end

# mutable struct Track
#     trackstart::Int # start station/node
#     trackend::Int # end station/node
#     capacity::Int # max number of trains
#     length::Float64
# end

# TODO implement struct Station and MetaGraphs as alternative to LightGraphs so we can use edge properties for length or for stations(nodes) capacity

# Definition of functions to create specific agents (trains and passengers)
Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0, 0, 0, groupsize, targettime) # Passenger IDs start on 5001 to avoid conflicts with train Agent Ids
Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, 0, speed, 0, 0, 0)# max id is 5000

function initialize(file::String)
    # preparing additional properties
    properties = Dict(
        #:stations => Dataframe(), # Stationid::Int => station::Station
        #:passengers => Dict{Integer, Vector{Int}}(), # TrainID::Int PassngerID::Int Array of PassengerIDs per train
        #:lines => DataFrame()
        # Daten werden in buildGraphspaceABM eingelesen
    )
    # parsing input textfile -> Graphspace with buildGraphspace()
    model = buildGraphspaceABM(Mover, properties, file)
    return model
end

function agent_step!(agent::Mover, model)
    # Moving each Agent One Step per One Time unit
    # Phase 1: Passengers try to board trains to their destination when train is in there station which has space for their group
    if agent.isTrain
        moveTrain(agent, model)
    else
        if agent.onBoard < 1
            tryBoard(agent, model)
        end
    end
    # Phase 2: Trains travel their speed on their optimized train track route check if track has capacity for them and go on
end

function tryBoard(passenger::Mover, model)::Bool # passenger macht liste von zeügen wählt random einen aus
    for nearbyagents in nearby_ids(passenger, model, 0) # iterate over agents at same position(r=0) excluding passenger
        agent = model[nearbyagents]
        print(string("Passenger: ",passenger))
        println(string(" found Agent at the platform: ",agent))
        if agent.isTrain && agent.capacity >= passenger.groupsize
            passenger.onBoard = agent.id # passenger saves on which train it is
            agent.capacity = agent.capacity - passenger.groupsize # capacity of train agent is updated
            return true
        end
    end 
    return false
end

function nextDestination(agent::Mover, model)
    #println(first(model.lines[in.(model.lines.Start, Ref(agent.pos)), :].End))
    #agent.destination = first(nearby_positions(agent.pos, model, 1)) # placeholder TODO better way picking next stop based on lines
end

function moveTrain(train::Mover, model)
    if train.trackprogress == 0 # check if train is still parked in a station ( if trackprogress > 0 == false)
        stationempty = true
        for nearbyagents in nearby_ids(train, model, 0) # iterate over agents at same position(r=0) excluding passenger
            if ! model[nearbyagents].isTrain # check if all agents remaining in station are trains if not wait for passengers to board
                stationempty = false
                break
            end
        end
        if stationempty
            nextDestination(train, model)
            if in(train.destination, nearby_positions(train.pos, model, 1)) # if all passenger boarded and the next stop is reachable
                #move_agent!(train, train.destination,  model)# ToDo check if track or station have the capacity
            end
        end
    end
end

function optimizeTrains(model)
    # iterate over all trains, optimize their Timetable and store them in optimizedTrains property of the model TODO
    
end
