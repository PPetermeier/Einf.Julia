#= obsolete text read function \o/
function read_txt(filename)
    file = open(filename,"r")
    data = readlines(file)
    println(data)
    return data
end=#
MetaGraphs.set_prop!(model, edge, prop, val) = set_prop!(model.space.graph, edge, prop, val) # set property::Symbol and val::Any for edgeId::Int
MetaGraphs.set_prop!(model, node, prop, val) = set_prop!(model.space.graph, node, prop, val) # set property::Symbol and val::Any for nodeId::Int

function buildGraphspaceABM(modelAgent, properties, file)
    # read in the Input.txt from filepath of file param and build the Graph space step by step line per line
    g = path_graph(0)
    #mg = MetaGraph(0)
    model = ABM(modelAgent, GraphSpace(g); properties ) # first make a model to build on
    #mg.graph = model.space.graph
    # model.properties["mgraph"] = mg
    # Phase 1: read in the Station -> Nodes in Graph space id = stationname TODO
    # Phase 2: read in the tracks -> Edges TODO
    # Phase 3: read in the trains -> Train Agents TODO
    # Phase 4: read in the passengers -> Passenger Agents TODO
    
    # some hardcoded test data =)
    for i in 1:3
        add_node!(model)
        #set_prop!(model, i, :capacity, 2)
        model.stations[i] = 2
    end
    for i in 1:2
        add_edge!(model, i, i+1)
        newtrack = Track(i, i+1, 1, i+0.3)
        model.tracks[i] = newtrack
    end
    add_edge!(model, 3, 1)
    newtrack = Track(3, 1, 1, 4.0)
    model.tracks[3] = newtrack

    # add agents:
    Passenger(id, pos, destination, groupsize, targettime) = Mover(id, pos, destination, false, 0, 0, 0, 0, groupsize, targettime) # Passenger IDs start on 5001 to avoid conflicts with train Agent Ids
    Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, 0, speed, 0, 0, 0)# max id is 5000
    # Passenger(id, pos, destination, groupsize, targettime) = Mover(id+5000, pos, destination, false, 0, Int[], 0, 0, 0, groupsize, targettime) # Passenger IDs start on 5001 to avoid conflicts with train Agent Ids
    # Train(id, pos, destination, capacity, speed) = Mover(id, pos, destination, true, capacity, 0, speed, 0, 0, 0)# max id is 5000
    add_agent!(Train(1, 1, 2, 3, 1.0), 1, model)
    add_agent!(Passenger(2, 1, 2, 2, 3.6), 1, model)
    add_agent!(Passenger(3, 1, 2, 1, 3.0), 1, model)
    
    return model
end
