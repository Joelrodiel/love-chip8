require 'opcode'
require 'libs.bit'

function love.load()

	-- The current opcode
	opcode = ""
	
	font_memory = {
		"F0", "90", "90", "90", "F0",   -- 0
		"20", "60", "20", "20", "70",   -- 1
		"F0", "10", "F0", "80", "F0",   -- 2
		"F0", "10", "F0", "10", "F0",   -- 3
		"90", "90", "F0", "10", "10",   -- 4
		"F0", "80", "F0", "10", "F0",   -- 5
		"F0", "80", "F0", "90", "F0",   -- 6
		"F0", "10", "20", "40", "40",   -- 7
		"F0", "90", "F0", "90", "F0",   -- 8
		"F0", "90", "F0", "10", "F0",   -- 9
		"F0", "90", "F0", "90", "90",   -- A
		"E0", "90", "E0", "90", "E0",   -- B
		"F0", "80", "80", "80", "F0",   -- C
		"E0", "90", "90", "90", "E0",   -- D
		"F0", "80", "F0", "80", "F0",   -- E
		"F0", "80", "F0", "80", "80"    -- F
	}
	
	reset()
	
	pause = true
	
	debugMode = true
	
	fakeDebugMode = true
	
	instructions_per_cycle = 10
	
	keyMapping = {
		["1"] = 0x1,["2"] = 0x2,["3"] = 0x3,["4"] = 0xC,
		["q"] = 0x4,["w"] = 0x5,["e"] = 0x6,["r"] = 0xD,
		["a"] = 0x7,["s"] = 0x8,["d"] = 0x9,["f"] = 0xE,
		["z"] = 0xA,["x"] = 0x0,["c"] = 0xB,["v"] = 0xF
	}
	
	keysPressed = {
		[0x1] = false,[0x2] = false,[0x3] = false,[0xC] = false,
		[0x4] = false,[0x5] = false,[0x6] = false,[0xD] = false,
		[0x7] = false,[0x8] = false,[0x9] = false,[0xE] = false,
		[0xA] = false,[0x0] = false,[0xB] = false,[0xF] = false
	}
	
	currentKeyDown = 0
	
	scaling = 2
	
	pointSize = 5
	
	love.graphics.setPointSize(pointSize*scaling)
	
	screenX = 1
	screenY = 10
	
	SCREEN_HEIGTH = ((32 * 5) * 2) + 32
	SCREEN_HEIGTH_DEBUG = ((32 * 5) * 2) + 90
	
	SCREEN_WIDTH = ((64 * 5) * 2) + 14
	SCREEN_WIDTH_DEBUG = ((64 * 5) * 2) + 190
	
	maxW = SCREEN_WIDTH
	maxH = SCREEN_HEIGTH
	
	menuBar = {"File","Emulation","Tools","Palette","Credits"}
	
	menuBarOptions = {
		{"Load rom...","Exit"},
		{"Start","Pause","Reset","Configure..."},
		{"Show debug","Print debug"},
		{"Original","Green","Orange"},
		{"Made by Joel"},
	}
	
	UIfont1 = love.graphics.newFont()
	
	UIbarOffset = 0
	
	UIbarPadding = 8
	
	barSelected = 0
	
	barClicked = 0
	
	barOptionSelected = 0
	
	barOptionClicked = 0
	
	palette = {
		BG = {0,0.25,0},
		PIXEL = {0.7,1,0.7},
	}
	
	romLoaded = false
	
	romFile = "start"
	
	love.graphics.setBackgroundColor(0.9,0.9,0.9)
	
	configureMode = false
end

function reset()
	-- Memory array (0x50 fontset; 0x200 Program)
	memory = {}
	
	-- Fill memory with 0x50 (80) for the fontset
	for i=1, 0x200 do
		if font_memory[i] ~= nil then
			memory[i] = font_memory[i]
		else
			memory[i] = ""
		end
	end
	
	-- Registers array
	registers = {}
	
	-- Create all 16 registers with an empty string
	for i=0, 15 do
		registers[i] = 0
	end
	
	index_register = 0
	
	-- Position counter
	PC = 0x200 + 1
	
	delay_timer = 0
	sound_timer = 0
	
	stack = {}
	SP = 1
	
	display = {}
	
	for j=0, 32 do
		
		display[j] = {}
		
		for i=0, 64 do
			display[j][i] = 0
		end
	end
end

function love.draw()
	
	love.graphics.setColor(1,1,1)
	
	if romLoaded then
	
		love.graphics.scale(scaling,scaling)
		
		love.graphics.translate(screenX,screenY)
		
		love.graphics.setColor(palette.BG)
		
		love.graphics.rectangle("fill",0,0,65*pointSize,33*pointSize)
		
		love.graphics.setColor(palette.PIXEL)
		
		for y=0, #display do
			for x=0, #display[y] do
				if display[y][x] ~= 0 then
					love.graphics.points((x+1)*pointSize,(y+1)*pointSize)
				end
			end
		end
		
		love.graphics.setColor(1,1,1)
		
		love.graphics.rectangle("line",0,0,65*pointSize,33*pointSize)
	
	end
	
	love.graphics.origin()
	
	love.graphics.setColor(0,0,0)
	
	if fakeDebugMode then
	
		love.graphics.print("Registers:",5,352)
	
		local n1 = 0
		local x2 = 10
	
		for i=0, #registers do
			
			local y2 = 370
			
			n1 = n1 + 1
			
			if n1 == 2 then
				y2 = y2 + 20
			elseif n1 > 2 then
				x2 = x2 + 80
				y2 = 370
				n1 = 1
			end
		
			love.graphics.print("V["..i.."] = "..registers[i],x2,y2)
		end
		
		love.graphics.print("Index = "..index_register,662,20)
		love.graphics.print("PC = "..PC,748,20)
		love.graphics.print("Delay = "..delay_timer,662,50)
		love.graphics.print("Sound = "..sound_timer,748,50)
		love.graphics.print("OP code = "..opcode,662,80)
		
		love.graphics.rectangle("line",662,110,158,290)
		
		local memStr = ""
		local n2 = 0
		
		for i = 511, #memory do
			memStr = memStr .. memory[i]
			n2 = n2 + 1
			if n2 == 2 then
				n2 = 0
				memStr = memStr .. " "
			end
		end
		
		love.graphics.printf(memStr,670,118,148)
	end
	
	love.graphics.setColor(1,1,1)
	
	love.graphics.rectangle("fill",0,0,maxW,9*scaling)
	
	love.graphics.setColor(0.75,0.75,0.75)
	
	love.graphics.line(0,(9*scaling)-1,maxW,(9*scaling)-1)
	
	for i, v in ipairs(menuBar) do
	
		local x = 0
		local w = (UIfont1:getWidth(menuBar[i]) + UIbarPadding)
	
		if i > 1 then
			x = (UIfont1:getWidth(menuBar[i-1]) + UIbarPadding) + UIbarOffset
			UIbarOffset = x
		else
			UIbarOffset = 0
		end
		
		if i == barSelected then
			love.graphics.setColor(0.4,0.4,1,0.25)
			
			love.graphics.rectangle("fill",x,0,w,8*scaling)
		end
		
		love.graphics.setColor(0,0,0)
		
		love.graphics.printf(v,x,1,w,"center")
		
		if i == barClicked then
			for k=1, #menuBarOptions do
				if menuBarOptions[i] then
					love.graphics.setColor(0.85,0.85,0.85)
					
					love.graphics.rectangle("fill",x,9*scaling,90,(#menuBarOptions[i]*(9*scaling))+2)
					
					love.graphics.setColor(0,0,0,0.05)
					
					love.graphics.rectangle("fill",x+2,9*scaling,90,(#menuBarOptions[i]*(9*scaling))+4)
					
					love.graphics.setColor(0,0,0)
					
					for j, b in ipairs(menuBarOptions[i]) do
					
						if j == barOptionSelected then
							love.graphics.setColor(0.4,0.4,1,0.5)
							
							love.graphics.rectangle("fill",x+2,((9*scaling)*j)+1,86,(9*scaling)-1)
						end
						
						love.graphics.setColor(0,0,0)
					
						love.graphics.print(b,x+10,((9*scaling)*j)+1)
					end
				end
			end
		end
	end
	
	love.graphics.setColor(0,0,0,0.5)
	
	if romFile == "start" then
		love.graphics.printf("Drop a Chip-8 ROM...",0,(SCREEN_HEIGTH/2),SCREEN_WIDTH,"center")
	end
	
	if pause and romLoaded then
		love.graphics.print("paused",300,175)
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	if not pause then
		for i=1, instructions_per_cycle do
			executeOPcode()
		end
		
		if delay_timer > 0 then
			delay_timer = delay_timer - 1
		end

		if sound_timer > 0 then
			sound_timer = sound_timer - 1
		end
	end
	
	if barOptionClicked > 0 then
		if barClicked == 1 then
			if barOptionClicked == 1 then
				pause = true
				romLoaded = false
				romFile = "start"
			else
				love.event.quit()
			end
		elseif barClicked == 2 then
			if romLoaded then
				if barOptionClicked == 1 then
					pause = false
				elseif barOptionClicked == 2 then
					pause = true
				else
					pause = true
				
					reset()
					
					loadGame()
					
					pause = false
				end
			end
		elseif barClicked == 3 then
			if barOptionClicked == 1 then
				if fakeDebugMode then
					fakeDebugMode = false
					
					menuBarOptions[3][1] = "Show debug"
					
					if maxH ~= SCREEN_HEIGTH then
						maxH = SCREEN_HEIGTH
						maxW = SCREEN_WIDTH
					
						love.window.setMode(maxW,maxH)
					end
				else
					fakeDebugMode = true
					
					menuBarOptions[3][1] = "Hide debug"
				end
			elseif barOptionClicked == 2 then
				if debugMode then
					debugMode = false
					
					menuBarOptions[3][2] = "Print debug"
				else
					debugMode = true
					
					menuBarOptions[3][2] = "No print"
				end
			end
		elseif barClicked == 4 then
			if barOptionClicked == 1 then
				palette.BG = {0,0,0}
				palette.PIXEL = {1,1,1}
			elseif barOptionClicked == 2 then
				palette.BG = {0,0.25,0}
				palette.PIXEL = {0.7,1,0.7}
			elseif barOptionClicked == 3 then
				palette.BG = {0.3,0.2,0}
				palette.PIXEL = {0.8,0.5,0}
			end
		end
		
		barClicked = 0
		barOptionClicked = 0
	end
	
	if fakeDebugMode then
		if maxH ~= SCREEN_HEIGTH_DEBUG then
			maxH = SCREEN_HEIGTH_DEBUG
			maxW = SCREEN_WIDTH_DEBUG
			
			love.window.setMode(maxW,maxH)
		end
	end
	
	local mx, my = love.mouse.getPosition()
	
	barSelected = 0
	barOptionSelected = 0
	
	for i, v in ipairs(menuBar) do
	
		local x = 0
		local w = (UIfont1:getWidth(menuBar[i]) + UIbarPadding)
	
		if i > 1 then
			x = (UIfont1:getWidth(menuBar[i-1]) + UIbarPadding) + UIbarOffset
			UIbarOffset = x
		else
			UIbarOffset = 0
		end
		
		if mx > x and mx < x + w and my > 0 and my < 8*scaling then
			barSelected = i
			
			if barClicked > 0 then
				barClicked = barSelected
			end
		end
		
		if barClicked > 0 then
			if i == barClicked then
				for k=1, #menuBarOptions do
					if menuBarOptions[i] then
						for j, b in ipairs(menuBarOptions[i]) do
							if mx > x and mx < x + 90 and my > ((9*scaling)*j)+1 and my < (((9*scaling)*j)+1) + (9*scaling)+1 then
								barOptionSelected = j
							end
						end
					end
				end
			end
		end
	end
end

function loadGame()

	romFile:open("r")

	local romData = romFile:read()
	
	romFile:close()
	
	for i=1, #romData do
	
		local lineString = string.format("%x", romData:byte(i) * 256)
	
		if string.len(lineString) < 4 then
			lineString = "0" .. lineString
		end
		
		lineString = string.sub(lineString,1,2)
		
		table.insert(memory,lineString)
	end
end

function love.filedropped(file)
	if not romLoaded then
	
		romFile = file
		
		reset()
		
		loadGame()
		
		romLoaded = true
		
		pause = false
		
		love.window.requestAttention()
	end
end

function love.keypressed(key)
	if key == "return" then
		if pause then
			pause = false
		else
			pause = true
		end
	end
	
	if keyMapping[key] then
		keysPressed[keyMapping[key]] = true
		currentKeyDown = keyMapping[key]
	end
end

function love.keyreleased(key)
	if keyMapping[key] then
		keysPressed[keyMapping[key]] = false
		if currentKeyDown == keyMapping[key] then
			currentKeyDown = 0
		end
	end
end

function love.mousepressed(x,y)

	if barClicked > 0 then
		for i, v in ipairs(menuBar) do
		
			local x1 = 0
		
			if i > 1 then
				x1 = (UIfont1:getWidth(menuBar[i-1]) + UIbarPadding) + UIbarOffset
				UIbarOffset = x1
			else
				UIbarOffset = 0
			end
			
			for k=1, #menuBarOptions do
				if menuBarOptions[barClicked] then
				
					love.graphics.rectangle("fill",x,9*scaling,90,(#menuBarOptions[barClicked]*(9*scaling))+1)
					
					if x > x1 and x < x1 + 90 and y > 9 * scaling and y < (9*scaling) + (#menuBarOptions[barClicked]*(9*scaling))+1 then
						if i == barClicked then
							for k=1, #menuBarOptions do
								if menuBarOptions[i] then
									for j, b in ipairs(menuBarOptions[i]) do
										if x > x1 and x < x1 + 90 and y > ((9*scaling)*j)+1 and y < (((9*scaling)*j)+1) + (9*scaling)+1 then
											barOptionClicked = j
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		if barOptionSelected == 0 then
			barClicked = 0
			barSelected = 0
		end
	end

	if barSelected > 0 then
		barClicked = barSelected
	end
end