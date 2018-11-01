local input = io.read()

local component = require("component")

local compo = component.getPrimary(input)

for k,v in pairs(compo) do
	print(k,v)
end