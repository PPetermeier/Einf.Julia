#= Main Test File of our little TrainTimetable Optimizatzion Project based on the DB Informatic Cup Project
# Project #5 of the Julia course
# 
=#
# First we include all the needed functions of used files
include("..\\TrainTimetableOptimization\\trainTimetable_ABM.jl")
#include("..\\TrainTimetableOptimization\\spaceBuilder.jl")

# Now we write the test Project code
#read_txt("InfomaticCup\\test\\simple\\input.txt")
m1 = initialize("InfomaticCup\\test\\simple\\input.txt")
println(m1.stations)
println(m1.tracks)
println(string("number of agents: ",nagents(m1)))
println(m1.agents)
 