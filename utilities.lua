--[[
	Copyright (c) 2013, Connor S. Parks and Alexandru Maftei
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	   * Redistributions of source code must retain the above copyright
	     notice, this list of conditions and the following disclaimer.
	   * Redistributions in binary form must reproduce the above copyright
	     notice, this list of conditions and the following disclaimer in the
	     documentation and/or other materials provided with the distribution.
	   * Neither the name of <addon name> nor the
	     names of its contributors may be used to endorse or promote products
	     derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

--	--	--	--
--	Locals	--
--	--	--	--

local sub, rep, format = string.sub, string.rep, string.format



--	--	--	--	--	--	--
--	Courtesy of Vercas	--
--	(github.com/Vercas)	--
--	--	--	--	--	--	--

function prettystring(data)
	if type(data) == "string" then
		return format("%q", data)
	else
		return tostring(data)
	end
end

local colkeys = { a = true, r = true, g = true, b = true}
local function isColor(tab)
	local hits = 0

	for k, _ in pairs(tab) do
		if colkeys[k] then
			hits = hits + 1
		else
			return false
		end
	end

	return hits == 4
end

function tabletostring(t, indent, done)
	done = done or {}
	indent = indent or 0
	local str, cnt = "", 0

	for key, value in pairs(t) do
		str = str .. rep ("    ", indent)

		if type(value) == "table" and not done[value] then
			done[value] = true

			local ts = tostring(value)

			if isColor(value) then
				str = str .. prettystring(key) .. " = " .. string.format("# %X %X %X %X", value.a, value.r, value.g, value.b) .. "\n"
			elseif ts:sub(1, 9) == "table: 0x" then
				local _str, _cnt = tabletostring(value, indent + 1, done)

				str = str .. prettystring(key) .. ":" .. ((_cnt > 0) and ("\n" .. _str) or " empty table\n")
			else
				str = str .. prettystring(key) .. " = " .. ts .. "\n"
			end
		else
			str = str .. prettystring(key) .. " = " .. prettystring(value) .. "\n"
		end

		cnt = cnt + 1
	end

	return str, cnt
end