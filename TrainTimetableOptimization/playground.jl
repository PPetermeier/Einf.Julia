using Graphs, MetaGraphs

g = path_graph(0)

println(g)

mg = MetaGraph(g)
set_prop!(mg, :type, "TrainTimeTableOptimizerSpace")
set_prop!(mg, :Metagraphspace, true)
println(mg)
println(mg.gprops)

for i in 1:5
    add_vertex!(mg)
    set_prop!(mg, i, :Capacity, rand(1:10))
end


for vertex in 
    println(vertex)
    println(props(mg, vertex))
end

add_edge!(mg, 1, 3)
add_edge!(mg, 2, 5)
println(mg.eprops)

for edge in mg.eprops
    set_prop!(mg, edge, :Capacity, rand(1:10))
    println(edge)
end    

println(mg.vprops)

