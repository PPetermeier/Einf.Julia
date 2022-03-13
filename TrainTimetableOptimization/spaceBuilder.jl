include("Inputparser.jl")

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
    for r in eachrow( passengers )
        counttrains = nrow(trains) # count trains to eval passengerId
        add_agent_pos!( Passenger(r.ID+counttrains, r.StartingStation, r.Destination, r.Groupsize, r.Targettime), model )
        # Passenger IDs start on id+number of trains to avoid conflicts with train Agent Ids
    end
    for r in eachrow( trains )
        if ! isnothing( r.StartingStation ) # set to random Station if no starting station is set
            start = r.StartingStation
        else
            start = rand( 1:nrow(stations) ) # pick random station to start
        end
        add_agent_pos!( Train(r.ID, start, r.Capacity, r.Speed), model ) # TODO check if station has capacity
    end

    return model
end
