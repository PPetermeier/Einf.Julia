# Benötigt Julia 1.7!
using DataFrames
function parseinput()
    #----------------- Die Dataframes initialisieren um dann einfach reinschreiben zu können.       #
    #----------------- Besonderheit bei Trains: Startation muss Any und genutzte Methode tryparse,  #
    #----------------- damit NaN eingetragen werden kann für die frei setzbaren Züge                #
    stations = DataFrame(ID = Int64[], Capacity = Int64[])
    lines = DataFrame(ID = Int64[], Start = Int64[], End = Int64[], Length = Float32[], Capacity = Int64[])
    trains = DataFrame(ID = Int64[], StartingStation = Any[], Speed = Float32[], Capacity = Int64[])
    passengers = DataFrame(ID = Int64[], StartingStation = Int64[], Destination = Int64[], Groupsize = Int64[], Targettime = Int64[])
    #----------------- Die Schleife für custom parsing. Im Effekt auch ein selbst gebautes SwitchCase, mit continues für Effizienz.                     #
    #-----------------Phasenvariabel kontrolliert an welcher Stelle des Dokumentes gerade gelesen wird die entsprechenden Anweisungen werden ausgeführt.#
    open("C:\\Users\\Philipp\\Desktop\\Einf.Julia\\InfomaticCup\\test\\simple\\input.txt") do file 
        phase=0
        for ln in eachline(file)
            if length(ln) == 0 || startswith(ln, "#")
                continue
            end
            if ln == "[Stations]" || ln == "[Lines]" || ln == "[Trains]" || ln == "[Passengers]"
                phase += 1
                continue
            end
            if phase == 1
                push!(stations,parse.(Int,split(strip(ln,['S']))))
                continue
            end
            if phase == 2
                push!(lines, parse.(Float64, split(replace(ln,"L" => "", "S" => "" ))))
                continue
            end
            if phase == 3 
                push!(trains, tryparse.(Float64, split(replace(ln, "T"=>"", "S"=>""))))
                continue
            end
            if phase == 4
                push!(passengers, parse.(Int, split(replace(ln, "P"=>"", "S"=>""))))
                continue
            end 
        end
    end
end
    return(stations, lines, trains, passengers)
    #--------------------------------------------------------------------#   
    println(stations)
    println("|---------------------------------------------------------|")
    println(lines)
    println("|---------------------------------------------------------|")
    println(trains)
    println("|---------------------------------------------------------|")
    println(passengers)