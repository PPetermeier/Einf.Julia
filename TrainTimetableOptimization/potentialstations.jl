using DataFrames
include("parser_test.jl")



function potentialstations(Amount)
    stations, lines, trains, passengers = parseinput("C:\\Users\\Philipp\\Desktop\\Einf.Julia\\InfomaticCup\\test\\large\\input.txt")
    aggregated = insertcols!(deepcopy(stations), :Startingpassengers => 0)
    for passenger in eachrow(passengers)
        aggregated[passenger.StartingStation, 3] += passenger.Groupsize
    end
    sort!(aggregated, 3, rev = true)
    aggregated = first(aggregated, Amount)
    return aggregated
end

println(potentialstations(10))