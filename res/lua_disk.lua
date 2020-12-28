-- lua disk


term.clear ()
term.set_cursor (0, 0)
term.set_blink (true)
term.set_colors (term.colors.silver, term.colors.black)
print ("%d: %s\n", os.computer_id (), os.get_name ())
print ("Booting %s...\n\n%s\n\n", _VERSION, os.date ("%a %d %b %Y %I:%M:%S %p"))


local lastcmd = ""
local cmdline = ""
local curline = ""
term.set_colors (term.colors.yellow, term.colors.black)
print (">")
term.set_colors (term.colors.silver, term.colors.black)

while true do
	local event = { os.get_event () }

	if event[1] == "key" then
		if event[2] == keys.KEY_UP then
			curline = curline..lastcmd
			print ("%s", lastcmd)
		end

	elseif event[1] == "char" then
		if event[3] == keys.KEY_ENTER then
			if curline:sub (-1) == "\\" then
				cmdline = cmdline..curline:sub (1, -2).." \n"
				curline = ""
				term.set_colors (term.colors.yellow, term.colors.black)
				print ("\n>")
				term.set_colors (term.colors.silver, term.colors.black)

			else
				local exec = cmdline..curline

				print ("\n")

				if exec:len () > 0 then
					local fxn, msg = loadstring (exec, "cmdline")

					lastcmd = exec

					if not fxn then
						term.set_colors (term.colors.red, term.colors.black)
						print ("%s\n", msg)
						term.set_colors (term.colors.silver, term.colors.black)

					else
						local result = { pcall (fxn) }

						if not result[1] then
							term.set_colors (term.colors.red, term.colors.black)
							print ("%s\n", result[2])
							term.set_colors (term.colors.silver, term.colors.black)

						else
							term.set_colors (term.colors.silver, term.colors.black)
							print ("\n")
							term.set_colors (term.colors.blue, term.colors.black)
							print ("ok:")

							for p = 2, #result do
								print (" %s", tostring (result[p] or "nil"))
							end

							print ("\n")

							term.set_colors (term.colors.silver, term.colors.black)

						end
					end
				end

				cmdline = ""
				curline = ""
				term.set_colors (term.colors.yellow, term.colors.black)
				print (">")
				term.set_colors (term.colors.silver, term.colors.black)

			end

		elseif event[3] == keys.KEY_ESC then
			if cmdline:len () < 1 or curline:len () < 1 then
				cmdline = ""
				curline = ""
				term.set_colors (term.colors.orange, term.colors.black)
				print (" ABORT")
				term.set_colors (term.colors.yellow, term.colors.black)
				print ("\n>")
				term.set_colors (term.colors.silver, term.colors.black)
			else
				curline = ""
				term.set_colors (term.colors.orange, term.colors.black)
				print (" ESC")
				term.set_colors (term.colors.yellow, term.colors.black)
				print ("\n>")
				term.set_colors (term.colors.silver, term.colors.black)
			end

		elseif event[3] == keys.KEY_BACKSPACE then
			if curline:len () > 0 then
				curline = curline:sub (1, -2)
				local x, y = term.get_cursor ()

				if x == 0 then
					if y > 0 then
						local w, h = term.get_resolution ()
						x = w - 1
						y = y - 1

						term.set_cursor (x - 1, y)
						print (" ")
						term.set_cursor (x - 1, y)
					end

				else
					term.set_cursor (x - 1, y)
					print (" ")
					term.set_cursor (x - 1, y)

				end
			end

		elseif event[3] >= keys.KEY_SPACE and event[3] <= keys.KEY_TILDE then
			curline = curline..event[2]
			print ("%s", event[2])

		end

	elseif event[1] == "clipboard" then
		curline = curline..event[2]
		print ("%s", event[2])

	end
end
