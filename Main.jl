module Efus
	module Parser
		include("parser.jl")
	end
	include("efus.jl")
end

using .Efus

println(@efus("test.efus"))