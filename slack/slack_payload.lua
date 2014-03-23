--	--	--	--	--	--
--	Function Locals	--
--	--	--	--	--	--

local setmetatable, pairs, type = setmetatable, pairs, type



--	--	--	--	--	--	--	--
--	(Meta)tables and states	--
--	--	--	--	--	--	--	--

SlackPayload = {}
SlackPayload.__index = {}

function SlackPayload.New(slack, command, data)
--	Define
	local self = {}

--	Defaults
	self.slack = slack
	self.command = command
	self.data = data

--	Meta
	setmetatable(self, SlackPayload)

--	Return
	return self
end



--	--	--	--	--	--
--	Static Locals	--
--	--	--	--	--	--

local attachmentKeys = {
	'fallback',
	'text',
	'pretext',
	'color',
	'fields'
}



--	--	--	--	--	--	--
--	Utility Functions	--
--	--	--	--	--	--	--

local function has_attachment_key(data)
	local attachmentKeys, i = attachmentKeys, 1

	while i <= #attachmentKeys do
		if data[attachmentKeys[i]] ~= nil then
			return true
		end

		i = i + 1
	end

	return false
end

local function format_attachments(data)
	if has_attachment_key(data) then
		return data
	end

	local formatted = {}

	for k, v in pairs(data) do
		formatted[#formatted + 1] = { ['text'] = v }
	end

	return formatted
end

local function send(self)
	if self.to ~= nil then
		local old = self.data['text'] ~= nil and self.data['text'] or nil
		self.data['text'] = self.to .. (old or '')

		local ret = self.slack:Send(self)

		self.data['text'] = old

		return ret
	else return self.slack:Send(self) end
end



--	--	--	--	--	--	--
--	Instance Functions	--
--	--	--	--	--	--	--

function SlackPayload.__index:Send()
	return send(self)
end

function SlackPayload.__index:Set(key, val)
	if type(key) ~= 'table' then
		key = { [key] = val }
	end

	local data = self.data
	for k, v in pairs(key) do
		data[k] = v
	end

	return self
end

function SlackPayload.__index:UnSet(keys)
	if type(keys) ~= 'table' then
		keys = { keys }
	end

	local data, i = self.data, 1
	while i <= #keys do
		data[keys[i]] = nil

		i = i + 1
	end

	return self
end

function SlackPayload.__index:Message(data)
	if type(data) == 'table' then
		self:Set{ attachments = format_attachments(data) }
	else
		self:Set{ text = data }
	end

	return self
end

function SlackPayload.__index:Channel(channel)
	return self:Set{ ['channel'] = channel }
end

function SlackPayload.__index:Username(username)
	return self:Set{ ['username'] = username }
end

function SlackPayload.__index:From(from)
	return self:Username(from)
end

function SlackPayload.__index:To(users)
	if type(users) ~= 'table' then
		users = { users }
	end

	local to, i = '', 1
	while i <= #users do
		if i ~= 1 then
			to = to .. ', '
		end

		to = to .. '<@' .. users[i] .. '>'

		i = i + 1
	end

	self.to = to .. ': '

	return self
end

function SlackPayload.__index:Emoji(emoji)
	return self:Set{ icon_emoji = emoji, icon_url = nil }
end

function SlackPayload.__index:Icon(url)
	return self:Set{ icon_emoji = nil, icon_url = url }
end