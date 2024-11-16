using .Parser

struct Efu
	file::String
	commands::Parser.Efs
	Efu(file::String) = new(file, Parser.parse_file(file))
end

macro efus(path::String)
	return quote 
		Efu($path)
end	end

export @efus, Efu