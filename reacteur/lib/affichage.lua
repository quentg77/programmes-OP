-- nom de la classe

local affichage = {}

-- package

local component = require("component")

-- variable local

local gpu = component.gpu

local bkColor = 0x000000 --couleur de fond par defaut

local blColor = 0x888888 --couleur du bloc par defaut

local fColor = 0xffffff --couleur du texte par defaut

local brColor = 0x444444 --couleur du border par defaut

local pad = 1 --padding par defaut

local mar = 1 --marge par defaut

local bor = 2 --border par defaut

-- methods privée

local function _bloc(bloc)
	gpu.setForeground(bloc.foreColor)

	gpu.setBackground(brColor)
	gpu.fill(bloc.x + mar, bloc.y + mar, bloc.l, bloc.h, " ")
	gpu.setBackground(bloc.blocColor)
	gpu.fill(bloc.x + mar + bor, bloc.y + mar + bor, bloc.l - (bor * 2), bloc.h - (bor * 2), " ")

	if bloc.content ~= nil then
		for i,line in ipairs(bloc.content) do
			gpu.set(bloc.x + mar + bor + pad, bloc.y + mar + bor + pad + (i-1), line)
		end
	end

	gpu.setBackground(bkColor)
	gpu.setForeground(fColor)
end

-- methods public

function affichage.setDefaultBackgroundColor(color)
	bkColor = color
end

function affichage.setDefaultBlocColor(color)
	blColor = color
end

function affichage.setDefaultForeColor(color)
	fColor = color
end

function affichage.bloc(arg)	--x,y,l,h : number; [blocColor,foreColor] : number; [arg] : table;

	if type(arg.x) ~= "number" then
		error("'x' incorrect, -5 point pour Nitendor")
	elseif type(arg.y) ~= "number" then
		error("'y' incorrect, -5 point pour Nitendor")
	elseif type(arg.l) ~= "number" then
		error("'l' incorrect, -5 point pour Nitendor")
	elseif type(arg.h) ~= "number" then
		error("'h' incorrect, -5 point pour Nitendor")
	elseif type(arg.blocColor) ~= "number" and arg.blocColor ~= nil then
		error("'blocColor' incorrect variable de type '"..type(arg.blocColor).."', -5 point pour Nitendor")
	elseif type(arg.foreColor) ~= "number" and arg.foreColor ~= nil then
		error("'foreColor' incorrect variable de type '"..type(arg.foreColor).."', -5 point pour Nitendor")
	elseif type(arg.content) ~= "table" and arg.content ~= nil then
		error("'arg' incorrect variable de type '"..type(arg.content).."', -5 point pour Nitendor")
	elseif type(arg.bloc) ~= "table" and arg.bloc ~= nil then
		error("'arg' incorrect variable de type '"..type(arg.bloc).."', -5 point pour Nitendor")
	end

	_bloc{
		x = arg.x, 
		y = arg.y, 
		l = arg.l, 
		h = arg.h, 
		blocColor = arg.blocColor or blColor, 
		foreColor = arg.foreColor or fColor, 
		content = arg.content or nil, 
		bloc = arg.bloc or nil}
end

-- retourn la classe

return affichage