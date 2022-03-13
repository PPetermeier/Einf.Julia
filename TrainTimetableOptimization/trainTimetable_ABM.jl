using Agents, DataFrames, MetaGraphs, LightGraphs
include("spaceBuilder.jl")

mutable struct Mover <: AbstractAgent
    # shared agent variables
    id::Int
    pos::Int # position in the model
    destination::Int #  final destination of the passenger or next destionation of train

    # train specific variables
    isTrain::Bool
    capacity::Int # capacity of passengers in the train
    trackprogress::Float64 # 0 if in station 
    speed::Float64 # speed of the train, how many track length in one time unit can be traversed
    passengerlist::Array # passengerlist of the train with passengerIDs

    # passenger specific variables
    groupsize::Int # size of the passenger group
    targettime::Int # the time the passenger wants to reach its destination
    arrivialtime::Int # on which Timeunit the passenger reached its destination

    # round specific shared variables
    logbook::Vector{String} # holds output specific Strings to later save their actions as text output
    # logbook format for trains string(zeit:int start/depart stationid/lineid) format for passenger string(zeit:int board/detrain zug/" ")
    hasmoved::Bool # if the train allready moved this timeunit or if passenger has boarded
end

# Definition of functions to create specific agents (trains and passengers)
Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0.0, 0.0, [], groupsize, targettime, 0, [], false)
Train(id, pos, capacity, speed) = Mover(id, pos, pos, true, capacity, 0.0, speed, [], 0, 0, 0, [], false)

function initialize(file::String)
    # preparing additional properties
    properties = Dict(
        #:stations => Dataframe(),
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
        moveTrain!(agent, model)
    else
        if ! agent.hasmoved
            agent.hasmoved = tryBoard!(agent, model)
        end
    end
    # Phase 2: Trains travel their speed on their optimized train track route check if track has capacity for them and go on
end

function tryBoard!(passenger::Mover, model)::Bool # passenger macht liste von zeügen wählt random einen aus
    for nearbyagents in nearby_ids(passenger, model, 0) # iterate over agents at same position(r=0) excluding passenger
        agent = model[nearbyagents]
        print(string("Passenger: ",passenger))
        println(string(" found Agent at the platform: ",agent))
        if agent.isTrain && agent.capacity >= passenger.groupsize
            push!(agent.passengerlist, passenger.id) # train saves passenger on passengerlist
            agent.capacity = agent.capacity - passenger.groupsize # capacity of train agent is updated
            return true
        end
    end 
    return false
end

function nextDestination!(train::Mover, model)
    if !train.isTrain
        neighborlist = DataFrame(NextStation = Int[], weigth = Int[])

        for agent in nearby_agents(train.pos, model, 0) # Placeholderfunktion, die Passenger sollten sich selbst bereits beim Boarden eingecheckt haben
                push!(train.passengerlist, agent)  
        end

        for passenger in train.passengerlist
            preference = a_star(model.space.graph, passenger.pos, passenger.destination )
            preference = preference[1].dst

            if in(preference, neighborlist[:, 2])
                neighborlist[2] += passenger.Groupsize
            else 
                push!(neighborlist, (preference, passenger.groupsize))       
            end

        sort!(neighborlist, 2, rev=true)
        nextdestinationID = neighborlist[1, 1]
        return nextdestinationID
        end
    end
end

function enter!(train::Mover, model, what) # checks if line or station has capacity enter if true model needs to be model.lines or model.stations
    if what == :line # infrastructure is line
        line = model.lines[ in([train.pos]).(model.lines.Start), :][in([train.destination]).(model.lines.End), :]
        laststation = model.stations[ in([train.pos]).(model.stations.ID), :]
        if line[1, :Capacity] >= 1
            model.lines[line[1, :ID], :Capacity] -= 1
            model.stations[laststation[1, :ID], :Capacity] += 1
            return true
        end
    else # infrastructure is station what == :station
        station = model.stations[ in([train.pos]).(model.stations.ID), :]
        lastline = model.lines[ in([train.pos]).(model.lines.Start), :][in([train.destination]).(model.lines.End), :]
        if station[1, :Capacity] >= 1
            model.stations[station[1, :ID], :Capacity] -= 1
            model.lines[lastline[1, :ID], :Capacity] += 1
            return true
        end
    end
    return false
end

function moveTrain!(train::Mover, model)
    if train.trackprogress == 0 # check if train is still parked in a station ( if trackprogress > 0 == false)
        #nextDestination!(train, model)
        train.destination = 3
        if in(train.destination, nearby_positions(train.pos, model, 1)) && enter!(train, model, :line) # if the next stop is reachable and line has capacity
            line = model.lines[ in([train.pos]).(model.lines.Start), :][in([train.destination]).(model.lines.End), :] # get active line of the train
            if train.speed >= model.lines[line[1, :ID], :Length] # if train is fast enough to reach the station in the same timeunit
                println()
                println("=================================[   ]=[   ]=[   ]=[   ]==")
                println(string(string(string("train ",train.id), " reaches station: "), train.destination))
                move_agent!(train, train.destination,  model)
                println("============================")
            else
                println()
                println(string(string("train ", train.id)," moves a bit from: ", train.trackprogress))
                train.trackprogress += train.speed
                println(train.trackprogress)
                println()
            end
        end
    else
        # line = model.lines[ in([train.pos]).(model.lines.Start), :][in([train.destination]).(model.lines.End), :] # get active line of the train
        # if train.trackprogress + train.speed >= model.lines[line[1, :ID], :Length] # if train is fast enough to reach the station in the same timeunit
        #     println("==============================================[   ]=[   ]==")
        #     println(string(string(string("train ",train.id), " reaches station: "), train.destination))
        #     move_agent!(train, train.destination,  model)
        #     println("============================")
        # else
        #     println()
        #     println(string(string("train ", train.id)," moves a bit from: ", train.trackprogress))
        #     train.trackprogress += train.speed
        #     println(string("to: ", train.trackprogress))
        #     println()
        # end
    end
end
