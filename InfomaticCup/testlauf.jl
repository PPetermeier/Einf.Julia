#= Main Test File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files
include("..//TrainTimetableOptimization//trainTimetable_ABM.jl")

# Now we write the test Project code
function main()
    println()
    println("=========================================")
    m1 = initialize("InfomaticCup//test//simple//input.txt")
    
    for agent in allagents(m1)
        nextDestination!(agent, m1)
        end
    end
#     println(m1.stations)
#     println(m1.lines)
#     println(string("number of agents: ",nagents(m1)))
#     println(m1.agents)
#     println()
#     optimizeTrains!(m1)
#     for timeunit in 1:3
#         for agent in allagents(m1)
#             agent_step!(agent, m1)
#         end
#         println()
#         println(string("End of Timeunit: ", timeunit))
#         println(string("modelagents: ",m1.agents))
#     end

main()

