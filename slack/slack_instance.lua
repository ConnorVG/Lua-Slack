--	--	--	--	--	--
--	Function Locals	--
--	--	--	--	--	--

local setmetatable, pairs, type = setmetatable, pairs, type
local encode, decode, url_encode = json.encode, json.decode, json.url_encode
local concat = table.concat

local find, sub, tostring = string.find, string.sub, tostring

local http = require("ssl.https")
local ltn12 = require("ltn12")



--	--	--	--	--	--	--	--
--	(Meta)tables and states	--
--	--	--	--	--	--	--	--

Slack = {}
Slack.__index = {}

local function New(apikey, verifiedOnly)
--	Safety
	apikey = apikey or ''
	verifiedOnly = verifiedOnly == nil and true or verifiedOnly

--	Define
	local self = {}

--	Defaults
	self.apikey = apikey
	self.verifiedOnly = verifiedOnly

--	Meta
	setmetatable(self, Slack)

--	Return
	return self
end



--	--	--	--	--	--
--	Static Locals	--
--	--	--	--	--	--

local commandMetadata = {
	['users'] = {
		['list'] = { false, {} }
	},
	['channels'] = {
		['history'] = { true, {} },
		['mark'] = { true, {} },
		['list'] = { true, {} }
	},
	['files'] = {
	--	['upload'] = { true, {} },
		['list'] = { true, {} }
	},
	['im'] = {
		['history'] = { true, {} },
		['list'] = { false, {} }
	},
	['groups'] = {
		['history'] = { true, {} },
		['list'] = { true, {} }
	},
	['search'] = {
		['all'] = { true, {} },
		['files'] = { true, {} },
		['messages'] = { true, {} }
	},
	['chat'] = {
		['postMessage'] = { true, {
				['username'] = 'ConnorBot',
				['icon_emoji'] = ':octocat:'
			}
		}
	},
	['auth'] = {
		['test'] = { false, {} }
	}
}

local instances = {}
local tokens = {}



--	--	--	--	--	--	--
--	Static Functions	--
--	--	--	--	--	--	--

function Slack.GetInstance(apikey, verifiedOnly)
	local instances = instances

	if instances[apikey] ~= nil then
		return instances[apikey]
	end

	local instance = New(apikey, verifiedOnly == nil and true or verifiedOnly)
	instances[apikey] = instance

	return instance
end

function Slack.GetTokenInstance(token)
	local tokens = tokens

	if tokens[token] ~= nil then
		return Slack.GetInstance(tokens[token])
	end

	for k, v in pairs(instances) do
		if v.verifiedOnly then
			return v
		end
	end
end

function Slack.InstallToken(token, apikey)
	tokens[token] = apikey
end

function Slack.HasError(response)
	return response == nil or type(response) ~= 'table' or response.ok ~= true
end



--	--	--	--	--	--	--
--	Utility Functions	--
--	--	--	--	--	--	--

local function split(txt, del, pattern)
	del = del or "\r*\n\r*"
	pattern = pattern == nil and true or false

	local pieces, cnt, a, b, c = {}, 1, 0, 1
	while a do
		a, c = find(txt, del, b, not pattern)

		if not a or not c then break end

		pieces[cnt] = sub(txt, b, a - 1)
		cnt = cnt + 1
		b = c + 1
	end

	pieces[cnt] = sub(txt, b)

	return pieces
end

local function commandify(command)
	return command, split(command, '.', false)
end

local function command_supported(command)
	local current, i = commandMetadata, 1
	while i <= #command do
		if current == nil or #current > 0 then return false end

		current = current[command[i]]
		i = i + 1
	end

	return current ~= nil and #current == 2
end

local function requires_payload(command)
	local current, i = commandMetadata, 1
	while i <= #command do
		current = current[command[i]]
		i = i + 1
	end

	return { current[1], current[2] }
end

local function prepare(self, command)
	local command, commandified = commandify(command)

	if not command_supported(commandified) then return end

	local data = {}

	local payload = requires_payload(commandified)
	if payload[1] then 
		data = payload[2]
	end

	return SlackPayload.New(self, command, data)
end

local function special_encode(data)
	local str, first = '', true

	for k, v in pairs(data) do
		if not first then
			str = str .. '&'
		end

		if type(v) == 'table' then
			str = str .. k .. '=' .. encode(v)
		else
			str = str .. k .. '=' .. url_encode(tostring(v))
		end
		
		first = false
	end

	return str
end

local function send(self, payload)
	local data = special_encode(payload.data)

	local result = {}
	local res, code, headers, status = http.request {
		url = 'https://slack.com/api/' .. payload.command .. '?token=' .. self.apikey .. '&' .. data,
		sink = ltn12.sink.table(result)
	}
	return decode(concat(result))
end



--	--	--	--	--	--	--
--	Instance Functions	--
--	--	--	--	--	--	--

function Slack.__index:Prepare(command)
	return prepare(self, command)
end

function Slack.__index:Send(payload)
	return send(self, payload)
end

function Slack.__index:Utilities()
	if self.utilities == nil then
		self.utilities = SlackUtilities.New(self)
	end

	return self.utilities
end

function Slack.__index:Message(message, channel, from, to, icon_emoji, icon_url)
	message = self:Prepare('chat.postMessage'):Message(message):Channel(channel)

	if from ~= nil then
		message:From(from)
	end

	if to ~= nil then
		message:To(to)
	end

	if icon_emoji ~= nil then
		message:Emoji(icon_emoji)
	elseif icon_url ~= nil then
		message:Icon(icon_url)
	end

	return message
end