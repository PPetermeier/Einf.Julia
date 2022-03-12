#= Main File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files eventuell TODO:  
include("trainTimetable_ABM.jl")

# Now we write the main Project code
function main()
    m1 = initialize("InfomaticCup//test//simple//input.txt")
    optimizeTrains(m1)

    for timeunit in 1:3
        for agent in allagents(m1)
            agent_step!(agent, m1)
        end
    end
end

main()