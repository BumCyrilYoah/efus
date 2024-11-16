using Base: +

abstract type EfuExpr end
@enum EfuValType int str expr



struct EfuVal
	annotation::Union{Symbol, Expr}
	reacy::Bool
	value::Any
	type::EfuValType
end

struct Efs
	instrs::EfuExpr
end

mutable struct State
	idx::UInt64
	text::String
	ended::Bool
	State(txt::String) = new(1, txt, false)
end

struct Tag <: EfuExpr
	name::String
	alias::Union{String, Nothing}
	attributes::Dict{String, EfuVal}
end
function next_name!(s::State)::Union{String, Nothing}
	m::Union{RegexMatch, Nothing} = match(r"[\w][\d\w\-]*", s.text, s.idx)
	m == nothing && return m
	s.idx += length(m.match)
	s.idx ≥ length(s.text) && (s.ended = true)
	return m.match
end
function next_indent!(s::State)::UInt8
	indent::UInt8 = zero(UInt8)
	while s.idx ≤ length(s) && s.text[s.idx] == ' '
		indent += 1
	end
	s.idx >= length(s.text) && (s.ended = true)
	s.idx += indent
	return indent
end
function Base.:+(s::State, n::Int)::State
	s.idx += n
	s.ended = has_ended(s)
	return s
end
function has_ended(s::State)::Bool
	for i ∈ s.idx:length(s)
		s[i] ∉ " \n" && return false
	end
	return true
end
Base.length(s::State)::UInt = length(s.text)



function parse_file(path::String)::Efs
	parse_code(
		open(path) do f
			read(f, String)
		end
	)
end

function parse_code(code::String)::Efs
	state::State = State(code)
	exprs::Vector{Tuple{UInt8, EfuExpr}} = Vector{Tuple{UInt8, EfuExpr}}()
	while !state.ended
		push!(exprs, parse_next_instr!(state))
	end
	return Efs(exprs[1][2])
end

function parse_next_instr!(s::State)::Tuple{UInt8, EfuExpr}
	ind::UInt8 = next_indent!(s)
	if (m = match(r"(\w[\w\d]*)(?:\:(\w[\w\d]*))?", s.text, s.idx)) != nothing
		s += length(m.match)
		return ind, Tag(m.captures[1], m.captures[2], Dict())
	end
end