#= Main Test File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files
include("..//TrainTimetableOptimization//trainTimetable_ABM.jl")

# Now we write the test Project code
function test1()
    println()
    println("=========================================")
    m1 = initialize("InfomaticCup//test//simple//input.txt")
    
    for agent in allagents(m1)
        println(nextDestination!(agent, m1))
        end
end

function test2()
    println()
    println("=========================================")
    m1 = initialize("InfomaticCup//test//simple//input.txt")

    println(m1.stations)
    println(m1.lines)
    println(string("number of agents: ",nagents(m1)))
    println(m1.agents)
    println()
    step!(m1, 5)
    println(m1.stations)
    println(m1.lines)
end

test1()
test2()
