function read_txt(filename)
    file = open(filename,"r")
    data = readlines(file)
    println(data)
    return data
end
