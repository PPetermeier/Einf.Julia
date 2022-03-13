include("Inputparser.jl")
#= obsolete text read function \o/
function read_txt(filename)
    file = open(filename,"r")
    data = readlines(file)
    println(data)
    return data
end=#
#MetaGraphs.set_prop!(model, edge, prop, val) = set_prop!(model.space.graph, edge, prop, val) # set property::Symbol and val::Any for edgeId::Int
#MetaGraphs.set_prop!(model, node, prop, val) = set_prop!(model.space.graph, node, prop, val) # set property::Symbol and val::Any for nodeId::Int

function buildGraphspaceABM(modelAgent, properties, file)
    # read in the Input.txt from filepath and build the GraphSpace
    
    model = ABM(modelAgent, GraphSpace(path_graph(0)); properties ) # first make a model to build on
    
    # Phase 1: read Stations -> Nodes in GraphSpace
    # Phase 2: read Lines -> Edges in GraphSpace
    # Phase 3: read Trains -> Train Agents
    # Phase 4: read Passngers -> Passenger Agents 
    stations, lines, trains, passengers = parseinput(file) # parsing text input into Dataframes

    # building the graphSpace model
    for _ in eachrow(stations)
        add_node!(model)
    end
    for r in eachrow(lines)
        add_edge!(model, r.Start, r.End)
    end
    model.properties[:stations] = stations # save the model meta data in the model properties for later
    model.properties[:lines] = lines

    # add agents:
    # stations = DataFrame(ID = Int64[], Capacity = Int64[])
    # lines = DataFrame(ID = Int64[], Start = Int64[], End = Int64[], Length = Float32[], Capacity = Int64[])
    # trains = DataFrame(ID = Int64[], StartingStation = Any[], Speed = Float32[], Capacity = Int64[])
    # passengers = DataFrame(ID = Int64[], StartingStation = Int64[], Destination = Int64[], Groupsize = Int64[], Targettime = Int64[])
    
    # Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0.0, 0.0, [], false, groupsize, targettime, 0, [])
    # Train(id, pos, capacity, speed) = Mover(id, pos, pos, true, capacity, 0.0, speed, [], false, 0, 0, 0, [])

    for r in eachrow( passengers )
        counttrains = nrow(trains) # count trains to eval passengerId
        add_agent_pos!( Passenger(r.ID+counttrains, r.StartingStation, r.Destination, r.Groupsize, r.Targettime), model )
        # Passenger IDs start on id+number of trains to avoid conflicts with train Agent Ids
    end
    for r in eachrow( trains )
        if ! isnothing( r.StartingStation ) # set to random Station if no starting station is set
            start = r.StartingStation
        else
            start = rand( 1:nrow(stations) ) # TODO pick random station with passengers
        end
        add_agent_pos!( Train(r.ID, start, r.Capacity, r.Speed), model ) # TODO check if station has capacity
    end

    # some hardcoded test data =)
    #=for i in 1:3
        add_node!(model)
        #set_prop!(model, i, :capacity, 2)
        model.stations[i] = Station(2, Dict())
    end
    for i in 1:2
        add_edge!(model, i, i+1)
        model.stations[i+1] = Track(i, i+1, 1, i+0.3)
        model.tracks[i] = newtrack
    end
    add_edge!(model, 3, 1)
    newtrack = Track(3, 1, 1, 4.0)
    model.tracks[3] = newtrack
    add_agent!(Train(1, 1, 2, 3, 1.0), 1, model)
    add_agent!(Passenger(2, 1, 2, 2, 3.6), 1, model)
    add_agent!(Passenger(3, 1, 2, 1, 3.0), 1, model)
    =#
    return model
end
