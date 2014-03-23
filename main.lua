--	--	--	--	--
--	Requires	--
--	--	--	--	--

require('slack')



--	--	--	--	--	--
--	Slack Examples	--
--	--	--	--	--	--

--	You get an instance of Slack for a specific API key like this

--	The ALLOW_ANY_TOKEN variable will define whether or not SlackIncoming is
--	allowed even if it's token isn't installed for the API key

--	If the instance doesn't already exist, it will be created using the
--	ALLOW_ANY_TOKEN param
local slack = Slack.GetInstance('APIKEY', ALLOW_ANY_TOKEN)

--	Getting the correct Slack instance for a specified token

--	If this returns null then there is no instance allowed for this token
local slack = Slack.GetTokenInstance('TOKEN')

--	To check if a :Send() response has an error, you do this
local hasError = Slack.HasError(response)

--	To prepare a SlackPayload object, simply do

--	The commands available are:
	--[[
		users.list
		channels.history, channels.mark, channels.list
		files.list
		im.history, im.list
		groups.history, groups.list
		search.all, search.files, search.messages
		chat.postMessage
		auth.test
	--]]
local payload = slack:Prepare('COMMAND')

--	To set the variables on a payload object, simply do
payload:Set('KEY', 'VARIABLE')

--	You can also do
payload:Set{ key1 = value1, key2 = value2 }

--	To manually unset keys, do
payload:UnSet('KEY')

--	You can also do
payload:Unset{ 'KEY1', 'KEY2', 'KEY3' }

--	:Send() returns the response of the object as a Lua table

--	When sending a payload object, you have two options
slack:Send(payload)

--	Or
payload:Send()

--	You can send messages easily by using a helper function, like so

--	Note that from, to, icon_emoji and icon_url aren't required and can also
--	be passed as nil if you wish to set a variable past it

--	Passing an array to the message or to param will make it act differently
--	A message array sends the message as an attachment (multiple lines, see api.slack.com)
--	A to array makes it notify multiple users, E.G: '@connorvg, @yourmom: '
slack:Message('MESSAGE', 'CHANNEL', 'FROM', 'TO', 'ICON_EMOJI', 'ICON_URL')

--	Or
slack:Message({ 'Line One', 'Line Two' }, 'CHANNEL', 'FROM', { 'TO1', 'TO2', 'TO3' }, nil, 'ICON_URL')



--	--	--	--	--	--	--
--	Payload Examples	--
--	--	--	--	--	--	--

--	The payload has some helper functions, just like Slack's :Message()

--	To set a message on the payload whilst being ambiguous as to it being
--	an array (Slack attachment) or string (Slack text)
payload:Message('TEXT')

--	Or
payload:Message{ 'Line One', 'Line Two', 'Line Three' }

--	This sets the channel to interact with
payload:Channel('CHANNEL')

--	This sets the chat.postMessage's from username
payload:Username('USERNAME')

--	Or
payload:From('USERNAME')

--	This is a helper function for mentioning people in a chat.postMessage
payload:To('USER')

--	Or
payload:To{ 'USER1', 'USER2', 'USER3' }

--	The output of this, in Slack it's self, would be as so
	--[[
		USER1, USER2, USER3: REAL_TEXT
	--]]
--	Or
	--[[
		USER1, USER2, USER3:
			REAL_LINE_ONE
			REAL_LINE_TWO
			REAL_LINE_THREE
	--]]

--	To set the Emoji icon of a chat.postMessage
payload:Emoji(':EMOJI:')

--	Or to set the URL icon of a chat.postMessage
payload:Icon('www.example.com/icon.png')



--	--	--	--	--	--	--
--	Utility Examples	--
--	--	--	--	--	--	--

--	To get the SlackUtilities instance, you simply do
local utilities = slack:Utilities()

--	There are a lot of *simple* API calls that are implemented

--	These responses are cached in the instance until you manually do it

--	The supported keys are:
	--[[
		users.list
		channels.list
		files.list
		im.list
		groups.list
		auth.test
	--]]

--	This will clear the full cache
utilities:Clear()

--	This will clear a single key's cache
utilities:Clear('KEY')

--	This will clear many key's caches
utilities:Clear{ 'KEY1', 'KEY2', 'KEY3' }

--	The keys will only be cached after they have been requested

--	Requests are done simply as
utilities:Users()

-- Or
utilities:User('NAME', 'ID')

--	Each one is accessable in a sensible way
utilities:Users()
utilities:Channels()
utilities:Files()
utilities:IMs()
utilities:Groups()

--	ETC

--	The filters, such as :User(NAME, KEY) are supported on a per call basis

--	Both values don't need to be passed, you may pass just one. The supported
--	parameters on a per function basis are:
	--[[
		User(NAME, ID)
		Channel(NAME, ID)
		File(NAME, ID)
		IM(USER_NAME, ID)
		Group(NAME, ID)
	--]]

--	There are a few auth.test specific functions that allow for both testing auth
--	and for accessing certain data exposed by auth.test

--	All of the commands are:

--	The full auth.test response
utilities:Auth()

--	The team specific URL
utilities:AuthURL()

--	The team's name
utilities:AuthTeam()

--	The team's ID
utilities:AuthTeamID()

--	The API key owner's user name
utilities:AuthUser()

--	The API key owner's user ID
utilities:AuthUserID()



--	--	--	--	--	--	--
--	Incoming Examples	--
--	--	--	--	--	--	--

--	Instantiating the instance

--	This matches the 'Outgoing Webhook' layout
local incoming = SlackIncoming.New {
		['token'] = 'TOKEN',

		['team_id'] = 'T1',

		['channel_id'] = 'C1',
		['channel_name'] = 'luaslack',

		['timestamp'] = 1,

		['user_id'] = 'U1',
		['user_name'] = 'connorvg',

		['text'] = '!test :D',

		['trigger_word'] = '!'
}

--	Returns true if there is an error in the object
local hasError = incoming:HasError()

--	Get's the incoming's instance of Slack

--	If this returns null then there is no intance of Slack allowed for this token
local slack = incoming:Slack()