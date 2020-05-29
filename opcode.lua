function executeOPcode()

	opcode = memory[PC] .. memory[PC+1]
	
	if debugMode then
		print("\t\t"..opcode)
	end
	
	if opcode:sub(1,1) == "0" and opcode ~= "00e0" and opcode ~= "00ee" then
	
		if debugMode then
			print("Call RCA 1802")
		end
		
	elseif opcode == "00e0" then -- KINDA DONE?
		
		if debugMode then
			print("cls")
		end
		
		-- pause = true
		
		for j=1, 32 do			
			for i=1, 64 do
				if display[j][i] == 1 then
					display[j][i] = 0
				end
			end
		end
		
	elseif opcode == "00ee" then -- DONE
		
		if debugMode then
			print("return")
		end
		
		SP = SP - 1
		
		PC = stack[SP]
		
	elseif opcode:sub(1,1) == "1" then -- DONE
		
		if debugMode then
			print("goto "..tonumber("0x"..opcode:sub(2,4)))
		end
		
		PC = tonumber("0x"..opcode:sub(2,4)) - 1
		
	elseif opcode:sub(1,1) == "2" then -- DONE
		
		if debugMode then
			print("subroutine ".."0x"..opcode:sub(2,4).." ("..tonumber("0x"..opcode:sub(2,4))..")")
		end
		
		stack[SP] = PC
		
		SP = SP + 1
		
		PC = (tonumber("0x"..opcode:sub(2,4)) - 1)
		
	elseif opcode:sub(1,1) == "3" then -- DONE
		
		if debugMode then
			print("if (V"..tonumber("0x"..opcode:sub(2,2)).." == "..tonumber("0x"..opcode:sub(3,4))..")")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		if num1 == tonumber("0x"..opcode:sub(3,4)) then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "4" then -- DONE
		
		if debugMode then
			print("if (Vx != NN)")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		if num1 ~= tonumber("0x"..opcode:sub(3,4)) then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "5" then -- DONE
		
		if debugMode then
			print("if (Vx == Vy)")
		end
		
		if registers[tonumber("0x"..opcode:sub(2,2))] == registers[tonumber("0x"..opcode:sub(3,3))] then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "6" then -- DONE
		
		if debugMode then
			print("V["..(tonumber("0x"..opcode:sub(2,2))).."] = "..tonumber("0x"..opcode:sub(3,4)))
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = tonumber("0x"..opcode:sub(3,4))
		
	elseif opcode:sub(1,1) == "7" then -- DONE
		
		if debugMode then
			print("V"..tonumber("0x"..opcode:sub(2,2)).." += "..tonumber("0x"..opcode:sub(3,4)))
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (num1 + tonumber("0x"..opcode:sub(3,4))) % 0x100
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "0" then -- DONE
		
		if debugMode then
			print("Vx = Vy")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(3,3))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = num1
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "1" then -- DONE
		
		if debugMode then
			print("Vx = Vx | Vy")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		local num2 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num2) == "string" then
			num2 = tonumber("0x"..num2)
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = bit.bor(num1,num2)
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "2" then -- DONE
		
		if debugMode then
			print("Vx = Vx & Vy")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		local num2 = registers[tonumber("0x"..opcode:sub(3,3))]
		
		if type(num2) == "string" then
			num2 = tonumber("0x"..num2)
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = bit.band(num1,num2)
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "3" then -- DONE
		
		if debugMode then
			print("Vx = Vx ^ Vy")
		end
		
		local num1 = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num1) == "string" then
			num1 = tonumber("0x"..num1)
		end
		
		local num2 = registers[tonumber("0x"..opcode:sub(3,3))]
		
		if type(num2) == "string" then
			num2 = tonumber("0x"..num2)
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = bit.bxor(num1,num2)
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "4" then -- DONE
		
		if debugMode then
			print("Vx += Vy")
		end
		
		local sum = registers[tonumber("0x"..opcode:sub(2,2))] + registers[tonumber("0x"..opcode:sub(3,3))]
		
		if type(sum) == "string" then
			sum = tonumber("0x"..sum)
		end
		
		if sum > 0xFF then
			registers[0xF] = 1
		else
			registers[0xF] = 0
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (sum) % 0x100
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "5" then -- DONE
		
		if debugMode then
			print("Vx -= Vy")
		end
		
		if registers[tonumber("0x"..opcode:sub(2,2))] > registers[tonumber("0x"..opcode:sub(3,3))] then
			registers[0xF] = 1
		else
			registers[0xF] = 0
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (registers[tonumber("0x"..opcode:sub(2,2))] - registers[tonumber("0x"..opcode:sub(3,3))]) % 0x100
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "6" then -- DONE
		
		if debugMode then
			print("Vx >> = 1")
		end
		
		registers[0xF] = bit.band(registers[tonumber("0x"..opcode:sub(2,2))], 0x1)
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (bit.brshift(registers[tonumber("0x"..opcode:sub(2,2))],1)) % 0x100
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "7" then -- DONE
		
		if debugMode then
			print("Vx = Vy - Vx")
		end
		
		if registers[tonumber("0x"..opcode:sub(3,3))] > registers[tonumber("0x"..opcode:sub(2,2))] then
			registers[0xF] = 1
		else
			registers[0xF] = 0
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (registers[tonumber("0x"..opcode:sub(3,3))] - registers[tonumber("0x"..opcode:sub(2,2))]) % 0x100
		
	elseif opcode:sub(1,1) == "8" and opcode:sub(4,4) == "e" then -- DONE
		
		if debugMode then
			print("Vx << = 1")
		end
		
		registers[0xF] = (bit.band(registers[tonumber("0x"..opcode:sub(2,2))], 0x80) == 0x80) and 1 or 0
		
		registers[tonumber("0x"..opcode:sub(2,2))] = (bit.blshift(registers[tonumber("0x"..opcode:sub(2,2))],1)) % 0x100
		
	elseif opcode:sub(1,1) == "9" then -- DONE
		
		if debugMode then
			print("if (Vx != Vy)")
		end
		
		if registers[tonumber("0x"..opcode:sub(2,2))] ~= registers[tonumber("0x"..opcode:sub(3,3))] then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "a" then -- DONE
		
		index_register = tonumber("0x"..opcode:sub(2,4))
	
		if debugMode then
			print("I = "..index_register)
		end
		
	elseif opcode:sub(1,1) == "b" then -- DONE
		
		if debugMode then
			print("PC = V0 + NNN")
		end
		
		PC = (registers[0] + (tonumber("0x"..opcode:sub(2,4))-1)) % 0x100
		
	elseif opcode:sub(1,1) == "c" then -- DONE
		
		if debugMode then
			print("Vx = rand(0,255) & NNN")
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = bit.band(love.math.random(0, 255), tonumber("0x"..opcode:sub(3,4)))
		
	elseif opcode:sub(1,1) == "d" then -- IN PROGRESS
	
		local xPos = registers[tonumber("0x"..opcode:sub(2,2))]
		local yPos = registers[tonumber("0x"..opcode:sub(3,3))]
		local height = tonumber("0x"..opcode:sub(4,4))
		
		if height == 0 then
			height = 1
		end
		
		registers[0xF] = 0
		
		for y=1, height do
		
			local line = memory[index_register + y]
			
			local str = ""
	
			local bits = bit.tobits(tonumber("0x"..line))
			
			for i=1, #bits do
				str = str .. bits[i]
			end
			
			str = string.reverse(str)
			
			while string.len(str) < 8 do
				str = "0" .. str
			end
			
			for x=0, 7 do
				if str then
				
					local bitValue = tonumber(string.sub(str,x+1,x+1))
				
					if bitValue ~= 0 then
					
						local pX, pY = (xPos+x) % 64, (yPos+(y-1)) % 32
					
						if display[pY][pX] == 1 and bit.bxor(bitValue,display[pY][pX]) == 0 then
							registers[0xF] = 1
						end
					
						display[pY][pX] = bit.bxor(bitValue,display[pY][pX])
					end
				end
			end
		end
		
		if debugMode then
			print("draw(V"..tonumber("0x"..opcode:sub(2,2))..",V"..tonumber("0x"..opcode:sub(3,3))..","..height..")")
		end
		
	elseif opcode:sub(1,1) == "e" and opcode:sub(3,4) == "9e" then
		
		if debugMode then
			print("if (key() == Vx)")
		end
		
		if keysPressed[registers[tonumber("0x"..opcode:sub(2,2))]] then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "e" and opcode:sub(3,4) == "a1" then
		
		if debugMode then
			print("if (key() != Vx")
		end
		
		if not keysPressed[registers[tonumber("0x"..opcode:sub(2,2))]] then
			PC = PC + 2
		end
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "07" then -- DONE
		
		if debugMode then
			print("Vx = get_delay()")
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = delay_timer
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "0a" then
		
		if debugMode then
			print("Vx = get_key()")
		end
		
		registers[tonumber("0x"..opcode:sub(2,2))] = currentKeyDown
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "15" then -- DONE
		
		if debugMode then
			print("delay_timer(Vx)")
		end
		
		delay_timer = registers[tonumber("0x"..opcode:sub(2,2))]
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "18" then -- DONE
		
		if debugMode then
			print("sound_timer(Vx)")
		end
		
		sound_timer = registers[tonumber("0x"..opcode:sub(2,2))]
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "1e" then -- DONE
		
		if debugMode then
			print("I += V"..tonumber("0x"..opcode:sub(2,2)))
		end
		
		local num = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num) == "string" then
			num = tonumber("0x"..num)
		end
		
		index_register = index_register + num
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "29" then -- DONE
		
		if debugMode then
			print("I = sprite_addr[V"..tonumber("0x"..opcode:sub(2,2)).."]")
		end
		
		local num = registers[tonumber("0x"..opcode:sub(2,2))]
		
		if type(num) == "string" then
			num = tonumber("0x"..num)
		end
		
		index_register = (5*(num+1))-5
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "33" then -- DONE :)
		
		if debugMode then
			print("set_BCD(Vx)")
		end
		
		local var = registers[tonumber("0x"..opcode:sub(2,2))]
		
		local ones = var % 10
		var = math.floor(var / 10)
		
		local tens = var % 10
		var = math.floor(var / 10)
		
		local hundreds = var % 10
		
		memory[index_register+1] = hundreds
		memory[index_register+2] = tens
		memory[index_register+3] = ones
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "55" then -- DONE
		
		if debugMode then
			print("reg_dump(Vx,&I)")
		end
		
		for i=0, tonumber("0x"..opcode:sub(2,2)) do
			memory[(index_register+1)+i] = registers[i]
		end
		
	elseif opcode:sub(1,1) == "f" and opcode:sub(3,4) == "65" then -- DONE
		
		if debugMode then
			print("reg_load(Vx,&I)")
		end
		
		for i=0, tonumber("0x"..opcode:sub(2,2)) do
			registers[i] = memory[(index_register+1)+i]
		end
		
	else
		print("Uknown OPcode! ("..opcode..") PC: "..PC)
		
		pause = true
		
	end
	
	if memory[PC+2] ~= nil then
		PC = PC + 2
	end
end