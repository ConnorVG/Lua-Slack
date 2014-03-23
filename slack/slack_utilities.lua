--	--	--	--	--	--
--	Function Locals	--
--	--	--	--	--	--

local setmetatable, pairs, type = setmetatable, pairs, type

local NULL = {}
NULL.__null = true



--	--	--	--	--	--	--	--
--	(Meta)tables and states	--
--	--	--	--	--	--	--	--

SlackUtilities = {}
SlackUtilities.__index = {}

function SlackUtilities.New(slack)
--	Define
	local self = {}

--	Defaults
	self.slack = slack

	self.cache = {
		['users.list'] = NULL,
		['channels.list'] = NULL,
		['files.list'] = NULL,
		['im.list'] = NULL,
		['groups.list'] = NULL,
		['auth.test'] = NULL
	}

--	Meta
	setmetatable(self, SlackUtilities)

--	Return
	return self
end



--	--	--	--	--	--	--
--	Utility Functions	--
--	--	--	--	--	--	--

local function cachable(self, command)
	return self.cache[command] ~= nil
end

local function precache(self, command)
	local response = self.slack:Prepare(command):Send()
	self.cache[command] = response

	return response
end

local function cached(self, command)
	local cached = self.cache[command]

	return cached.__null and precache(self, command) or cached
end

local function filter(array, filters)
	local i = 1
	while i <= #array do
		local data = array[i]

		for ak, av in pairs(data) do
			for fk, fv in pairs(filters) do
				if data[fk] == fv then
					return data
				end
			end
		end

		i = i + 1
	end
end



--	--	--	--	--	--	--
--	Instance Functions	--
--	--	--	--	--	--	--

function SlackUtilities.__index.Clear(keys)
	if keys == nil then
		local cache = self.cache		

		for k, v in pairs(cache) do
			cache[k] = NULL
		end
	return end

	if type(keys) == 'table' then
		local cache, i = self.cache, 1

		while i <= #keys do
			cache[keys[i]] = NULL

			i = i + 1
		end
	return end

	self.cache[keys] = NULL
end

function SlackUtilities.__index:Users()
	return cached(self, 'users.list').members
end

function SlackUtilities.__index:User(name, id)
	return filter(self:Users(), { ['name'] = name, ['id'] = id })
end

function SlackUtilities.__index:Channels()
	return cached(self, 'channels.list').channels
end

function SlackUtilities.__index:Channel(name, id)
	return filter(self:Channel(), { ['name'] = name, ['id'] = id })
end

function SlackUtilities.__index:Files()
	return cached(self, 'files.list').files
end

function SlackUtilities.__index:File(name, id)
	return filter(self:Files(), { ['name'] = name, ['id'] = id })
end

function SlackUtilities.__index:IMs()
	return cached(self, 'ims.list').ims
end

function SlackUtilities.__index:IM(user, id)
	return filter(self:IMs(), { ['user'] = user, ['id'] = id })
end

function SlackUtilities.__index:Groups()
	return cached(self, 'groups.list').groups
end

function SlackUtilities.__index:Group(name, id)
	return filter(self:Groups(), { ['name'] = name, ['id'] = id })
end

function SlackUtilities.__index:Auth()
	return cached(self, 'auth.test')
end

function SlackUtilities.__index:AuthURL()
	return cached(self, 'auth.test').url
end

function SlackUtilities.__index:AuthTeam()
	return cached(self, 'auth.test').team
end

function SlackUtilities.__index:AuthTeamID()
	return cached(self, 'auth.test').team_id
end

function SlackUtilities.__index:AuthUser()
	return cached(self, 'auth.test').user
end

function SlackUtilities.__index:AuthUserID()
	return cached(self, 'auth.test').user_id
end