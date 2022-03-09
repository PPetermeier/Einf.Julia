#= Main Test File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files
include("..\\TrainTimetableOptimization\\trainTimetable_ABM.jl")

# Now we write the test Project code
m1 = initialize("InfomaticCup\\test\\simple\\input.txt")
println(m1.stations)
println(m1.tracks)
println(string("number of agents: ",nagents(m1)))
println(m1.agents)
optimizeTrains(m1)
println(m1.optimizedTrains)

for timeunit in 1:3
    for agent in allagents(m1)
        agent_step!(agent, m1)
    end
    println()
    println(m1.agents)
    println(m1.passengers)
end
