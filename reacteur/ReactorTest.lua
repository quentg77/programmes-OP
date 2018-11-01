-- package

local component = require("component")

local term = require("term")

local affichage = require("affichage")

local event = require("event")

-- variable local

local br = component.list("br_reactor")

local core = component.getPrimary("draconic_rf_storage")

local tauxReactor = {0,0,0,0}

local lastOperation = {1,1,1,1}

local loopCount = 0

-- fonction local

function EnergyLvl(objet)
	if objet.type == "br_reactor" then
		local pctEnergie = (objet.getEnergyStored() * 100 / objet.getEnergyCapacity())
		return pctEnergie
	elseif objet.type == "draconic_rf_storage" then
		local pctEnergie = (objet.getEnergyStored() * 100 / objet.getMaxEnergyStored())
		return pctEnergie
	end
end

function Taux(objet)
	local leTaux = math.floor(objet.getEnergyProducedLastTick() / (objet.getFuelConsumedLastTick() * 1000))
	return leTaux
end

function CalculTime(valeur,objectif,increment)
	local time = {0,0,0,0,0}
	local total = ((objectif - valeur) / increment) / 20
	time[4] = math.floor(total / 60 / 60 / 24)
	time[3] = math.floor((total / 60 / 60) - (time[4] * 24))
	time[2] = math.floor((total / 60) - (time[3] * 60 + time[4] * 60 * 24))
	time[1] = math.floor(total - (time[2] * 60 + time[3] * 60 * 60 + time[4] * 60 * 60 * 24))

	time[5] = math.floor(total)
	return time
end

-- programme principal

local function RodAjustement()

	local i = 0

	for AdrReactor in pairs(br) do
		i = i+1

		local reactor = component.proxy(AdrReactor)

		print(Taux(reactor))
		print(tauxReactor[i])

		if EnergyLvl(core) < 10 then
			reactor.setAllControlRodLevels(0)
		else
			if Taux(reactor) < tauxReactor[i] then

				print("ok")
				if lastOperation[i] == 0 and reactor.getControlRodLevel(1) > 0 then
					reactor.setAllControlRodLevels(reactor.getControlRodLevel(1) - 10)
					lastOperation[i] = 0
				elseif lastOperation[i] == 1 and reactor.getControlRodLevel(1) < 100 then
					reactor.setAllControlRodLevels(reactor.getControlRodLevel(1) + 10)
					lastOperation[i] = 1
				end

				tauxReactor[i] = Taux(reactor)

			elseif Taux(reactor) > tauxReactor[i] then

				if lastOperation[i] == 0 then
					lastOperation[i] = 1
				elseif lastOperation[i] == 1 then
					lastOperation[i] = 0
				end

				if lastOperation[i] == 0 and reactor.getControlRodLevel(1) > 0 then
					reactor.setAllControlRodLevels(reactor.getControlRodLevel(1) - 10)
					lastOperation[i] = 0
				elseif lastOperation[i] == 1 and reactor.getControlRodLevel(1) < 100 then
					reactor.setAllControlRodLevels(reactor.getControlRodLevel(1) + 10)
					lastOperation[i] = 1
				end
			end
		end

		reactor.setAllControlRodLevels(100) -- provisoiration
	end
end

while true do

	loopCount = loopCount + 1

	term.clear()

	if loopCount >=30 then
		-- RodAjustement()
		loopCount = 0
	end

	affichage.bloc{x = 1, y = 1, l = 60, h = 40, blocColor = 0x000000, title = "Reacteurs nucleaire"}

	local i = -1

	for AdrReactor in pairs(br) do
		i = i+1

		local reactor = component.proxy(AdrReactor)

		-- start and stop

		if EnergyLvl(reactor) >= 30 and reactor.getActive() == true then
			reactor.setActive(false)
		elseif EnergyLvl(reactor) < 5 and reactor.getActive() == false then
			reactor.setActive(true)
		end

		-- affichage des bloc

		local textArg = 
		{
			string.format("Adresse : %s", AdrReactor),
			string.format("Niveau d'energie : %.2f%%" , EnergyLvl(reactor)),
			string.format("Production : %.2f kRf/t", reactor.getEnergyProducedLastTick() / 1000),
			string.format("Control Rod level : %i%%", reactor.getControlRodLevel(1))
		}

		affichage.bloc{x = 3, y = 3 + (i*10), l = 50, h = 8, blocColor = 0x6666dd, title = "N° " + tostring(i), content = textArg}
	end

	local timeRemp = CalculTime(core.getEnergyStored(), core.getMaxEnergyStored(), core.getTransferPerTick())

	local timeVid = CalculTime(0, core.getEnergyStored(), core.getTransferPerTick() * -1)

	if timeRemp[5] > 0 and timeRemp[5] < 1000000000000 then
		timeVid = {0,0,0,0,0}
	elseif timeVid[5] > 0 and timeVid[5] < 1000000000000 then
		timeRemp = {0,0,0,0,0}
	else
		timeRemp = {0,0,0,0,0}
		timeVid = {0,0,0,0,0}
	end

	local textCore = 
	{
		string.format("Energie stocker : %.2f kRf", core.getEnergyStored() / 1000),
		string.format("Niveau d'energie : %.4f%%", EnergyLvl(core)),
		string.format("Flux d'energie : %.2f kRf/t", core.getTransferPerTick() / 1000),
		string.format("Temps remplissage restant : %id %ih %im %is", timeRemp[4], timeRemp[3], timeRemp[2], timeRemp[1]),
		string.format("Temps Vidage restant : %id %ih %im %is", timeVid[4], timeVid[3], timeVid[2], timeVid[1])
	}

	affichage.bloc{x = 70, y = 1, l = 60, h = 40, blocColor = 0x000000, title = "Coeur d'Energie", content = textCore}

	os.sleep(1)
end

-- event.timer(1,loop,math.huge)
-- event.pull("quit")