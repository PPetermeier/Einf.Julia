using Agents, LightGraphs
#= obsolete text read function
function read_txt(filename)
    file = open(filename,"r")
    data = readlines(file)
    println(data)
    return data
end=#

function buildGraphspaceABM(modelAgent, properties)
    # read in the Input.txt and build the Graph space step by step line per line
    model = ABM(modelAgent, GraphSpace(complete_graph(0)); properties )    
    # Phase 1: read in the Station -> Nodes in Graph space id = stationname TODO
    # Phase 2: read in the tracks -> Edges TODO
    # Phase 3: read in the trains -> Train Agents TODO
    # Phase 4: read in the passengers -> Passenger Agents TODO
    
    # some hardcoded test data
    for i in 1:3
        add_node!(model)
    end
    for i in 1:2
        add_edge!(model, i, i+1)
    end

    return model # simple unidirect Graph for now as placeholder 
end
