using DataFrames #pkg. add Datafrmae
stationnames = ["ID", "Capacity"]

stations = DataFrame(ID = Int64[], Capacity = Int64[])
lines = DataFrame(ID = Int64[], Start = Int64[], End = Int64[], Length = Float32[], Capacity = Int64[])
trains = DataFrame(ID = Int64[], StartingStation = Any[], Speed = Float32[], Capacity = Int64[])
passengers = DataFrame(ID = Int64[], StartingStation = Int64[], Destination = Int64[], Groupsize = Int64[], Targettime = Int64[])

open("C:\\Users\\Philipp\\Desktop\\Einf.Julia\\InfomaticCup\\test\\simple\\input.txt") do file 
    phase=0
    for ln in eachline(file)
        #println("$(ln)")
        if length(ln) == 0 || startswith(ln, "#")
            #println("emptyspacebreak")
            continue
        end
        if ln == "[Stations]" || ln == "[Lines]" || ln == "[Trains]" || ln == "[Passengers]"
            phase += 1
            #println("phasechangebreak")
            continue
        end
        if phase == 1
            content = split(strip(ln, ['S']))
            content = parse.(Int, content)
            push!(stations,content)
            #print(stations)
            continue
        end
        if phase == 2
            content = replace(ln, 'L'=>"")
            content = replace(content,'S'=>"")
            content = split(content)
            content = parse.(Float64, content)
            push!(lines,content)
            #print(lines)
            continue
        end
        if phase == 3 
            content = replace(ln, 'T'=>"")
            content = replace(content, 'S'=>"")
            content = split(content)
            content = tryparse.(Float64, content)
            push!(trains,content)
            #push!(trains,parse.(Float64, split(strip(ln,['T', ,'S']))))
            continue
        end
        if phase == 4
            content = replace(ln, 'P'=>"")
            content = replace(content, 'S'=>"")
            content = split(content)
            content = parse.(Int, content)
            push!(passengers,content)
            #push!(passengers,parse.(Int, split(strip(ln,['P', 'T', 'L','S']))))
            continue
        end 
    end
    #println(phase)
end


println(stations)
println("|---------------------------------------------------------|")
println(lines)
println("|---------------------------------------------------------|")
println(trains)
println("|---------------------------------------------------------|")
println(passengers)


#TODO: Prints entfernen, Datenpipelines in einfache Funktionscalls umwandeln von Einzelschritten, relative Pfadangabe ans Laufen bekommen