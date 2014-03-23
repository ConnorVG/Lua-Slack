--	--	--	--	--	--
--	Function Locals	--
--	--	--	--	--	--

local setmetatable, pairs, type = setmetatable, pairs, type

local sub = string.sub

local NULL = {}
NULL.__null = true



--	--	--	--	--	--	--	--
--	(Meta)tables and states	--
--	--	--	--	--	--	--	--

SlackIncoming = {}
SlackIncoming.__index = {}

function SlackIncoming.New(data)
--	Define
	local self = {}

--	Defaults
	data = data or {
		['token'] = NULL,

		['team_id'] = NULL,

		['channel_id'] = NULL,
		['channel_name'] = NULL,

		['timestamp'] = NULL,

		['user_id'] = NULL,
		['user_name'] = NULL,

		['text'] = NULL,
		['source_text'] = NULL,

		['trigger_word'] = NULL
	}

	if data.text ~= nil and data.text ~= NULL then
		local source_text = data.text
		data.text = sub(source_text, #data.trigger_word + 1)
	else data.source_text = data.text end

	self.data = data

--	Meta
	setmetatable(self, SlackIncoming)

--	Return
	return self
end



--	--	--	--	--	--	--
--	Instance Functions	--
--	--	--	--	--	--	--

function SlackIncoming.__index:HasError()
	local data = self.data
	for k, v in data do
		if v == nil or v == NULL then
			return true
		end
	end

	return false
end

function SlackIncoming.__index:Slack()
	return Slack.GetTokenInstance(self.data.token)
end