#= Main File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files  
include("trainTimetable_ABM.jl")

# Now we write the main Project code
function main()
    
    m1 = initialize("InfomaticCup//test//simple//input.txt")
    step!(m1, 5)
    
end

main()