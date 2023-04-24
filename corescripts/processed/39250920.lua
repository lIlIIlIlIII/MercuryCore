print("[Mercury]: Loaded corescript 39250920")
local New
New = function(className, name, props)
	if not (props ~= nil) then
		props = name
		name = nil
	end
	local obj = Instance.new(className)
	if name then
		obj.Name = name
	end
	local parent
	for k, v in pairs(props) do
		if type(k) == "string" then
			if k == "Parent" then
				parent = v
			else
				obj[k] = v
			end
		elseif type(k) == "number" and type(v) == "userdata" then
			v.Parent = obj
		end
	end
	obj.Parent = parent
	return obj
end
local waitForProperty
waitForProperty = function(instance, name)
	while not instance[name] do
		instance.Changed:wait()
	end
end
local waitForChild
waitForChild = function(instance, name)
	while not instance:FindFirstChild(name) do
		instance.ChildAdded:wait()
	end
end
local mainFrame
local choices = { }
local lastChoice
local choiceMap = { }
local currentConversationDialog
local currentConversationPartner
local currentAbortDialogScript
local tooFarAwayMessage = "You are too far away to chat!"
local tooFarAwaySize = 300
local characterWanderedOffMessage = "Chat ended because you walked away"
local characterWanderedOffSize = 350
local conversationTimedOut = "Chat ended because you didn't reply"
local conversationTimedOutSize = 350
local player
local chatNotificationGui
local messageDialog
local timeoutScript
local reenableDialogScript
local dialogMap = { }
local dialogConnections = { }
local gui
waitForChild(game, "CoreGui")
waitForChild(game.CoreGui, "RobloxGui")
if game.CoreGui.RobloxGui:FindFirstChild("ControlFrame") then
	gui = game.CoreGui.RobloxGui.ControlFrame
else
	gui = game.CoreGui.RobloxGui
end
local currentTone
currentTone = function()
	if currentConversationDialog then
		return currentConversationDialog.Tone
	else
		return Enum.DialogTone.Neutral
	end
end
local createChatNotificationGui
createChatNotificationGui = function()
	chatNotificationGui = New("BillboardGui", "ChatNotificationGui", {
		ExtentsOffset = Vector3.new(0, 1, 0),
		Size = UDim2.new(4, 0, 5.42857122, 0),
		SizeOffset = Vector2.new(0, 0),
		StudsOffset = Vector3.new(0.4, 4.3, 0),
		Enabled = true,
		RobloxLocked = true,
		Active = true,
		New("ImageLabel", "Image", {
			Active = false,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Image = "",
			RobloxLocked = true,
			New("ImageButton", "Button", {
				AutoButtonColor = false,
				Position = UDim2.new(0.088, 0, 0.053, 0),
				Size = UDim2.new(0.83, 0, 0.46, 0),
				Image = "",
				BackgroundTransparency = 1,
				RobloxLocked = true
			})
		})
	})
end
local getChatColor
getChatColor = function(tone)
	if tone == Enum.DialogTone.Neutral then
		return Enum.ChatColor.Blue
	elseif tone == Enum.DialogTone.Friendly then
		return Enum.ChatColor.Green
	elseif tone == Enum.DialogTone.Enemy then
		return Enum.ChatColor.Red
	end
end
local resetColor
resetColor = function(frame, tone)
	if tone == Enum.DialogTone.Neutral then
		frame.BackgroundColor3 = Color3.new(0, 0, 179 / 255)
		frame.Number.TextColor3 = Color3.new(45 / 255, 142 / 255, 245 / 255)
	elseif tone == Enum.DialogTone.Friendly then
		frame.BackgroundColor3 = Color3.new(0, 77 / 255, 0)
		frame.Number.TextColor3 = Color3.new(0, 190 / 255, 0)
	elseif tone == Enum.DialogTone.Enemy then
		frame.BackgroundColor3 = Color3.new(140 / 255, 0, 0)
		frame.Number.TextColor3 = Color3.new(255 / 255, 88 / 255, 79 / 255)
	end
end
local styleChoices
styleChoices = function(tone)
	for _, obj in pairs(choices) do
		resetColor(obj, tone)
	end
	return resetColor(lastChoice, tone)
end
local styleMainFrame
styleMainFrame = function(tone)
	if tone == Enum.DialogTone.Neutral then
		mainFrame.Style = Enum.FrameStyle.ChatBlue
		mainFrame.Tail.Image = "rbxasset://textures/chatBubble_botBlue_tailRight.png"
	elseif tone == Enum.DialogTone.Friendly then
		mainFrame.Style = Enum.FrameStyle.ChatGreen
		mainFrame.Tail.Image = "rbxasset://textures/chatBubble_botGreen_tailRight.png"
	elseif tone == Enum.DialogTone.Enemy then
		mainFrame.Style = Enum.FrameStyle.ChatRed
		mainFrame.Tail.Image = "rbxasset://textures/chatBubble_botRed_tailRight.png"
	end
	return styleChoices(tone)
end
local setChatNotificationTone
setChatNotificationTone = function(gui, purpose, tone)
	if tone == Enum.DialogTone.Neutral then
		gui.Image.Image = "rbxasset://textures/chatBubble_botBlue_notify_bkg.png"
	elseif tone == Enum.DialogTone.Friendly then
		gui.Image.Image = "rbxasset://textures/chatBubble_botGreen_notify_bkg.png"
	elseif tone == Enum.DialogTone.Enemy then
		gui.Image.Image = "rbxasset://textures/chatBubble_botRed_notify_bkg.png"
	end
	if purpose == Enum.DialogPurpose.Quest then
		gui.Image.Button.Image = "rbxasset://textures/chatBubble_bot_notify_bang.png"
	elseif purpose == Enum.DialogPurpose.Help then
		gui.Image.Button.Image = "rbxasset://textures/chatBubble_bot_notify_question.png"
	elseif purpose == Enum.DialogPurpose.Shop then
		gui.Image.Button.Image = "rbxasset://textures/chatBubble_bot_notify_money.png"
	end
end
local createMessageDialog
createMessageDialog = function()
	messageDialog = New("Frame", "DialogScriptMessage", {
		Style = Enum.FrameStyle.RobloxRound,
		Visible = false,
		New("TextLabel", "Text", {
			Position = UDim2.new(0, 0, 0, -1),
			Size = UDim2.new(1, 0, 1, 0),
			FontSize = Enum.FontSize.Size14,
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			RobloxLocked = true
		})
	})
end
local showMessage
showMessage = function(msg, size)
	messageDialog.Text.Text = msg
	messageDialog.Size = UDim2.new(0, size, 0, 40)
	messageDialog.Position = UDim2.new(0.5, -size / 2, 0.5, -40)
	messageDialog.Visible = true
	wait(2)
	messageDialog.Visible = false
	return messageDialog
end
local variableDelay
variableDelay = function(str)
	local length = math.min(string.len(str), 100)
	return wait(0.75 + (length / 75) * 1.5)
end
local highlightColor
highlightColor = function(frame, tone)
	if tone == Enum.DialogTone.Neutral then
		frame.BackgroundColor3 = Color3.new(2 / 255, 108 / 255, 255 / 255)
		frame.Number.TextColor3 = Color3.new(1, 1, 1)
	elseif tone == Enum.DialogTone.Friendly then
		frame.BackgroundColor3 = Color3.new(0, 128 / 255, 0)
		frame.Number.TextColor3 = Color3.new(1, 1, 1)
	elseif tone == Enum.DialogTone.Enemy then
		frame.BackgroundColor3 = Color3.new(204 / 255, 0, 0)
		frame.Number.TextColor3 = Color3.new(1, 1, 1)
	end
end
local endDialog
endDialog = function()
	if currentAbortDialogScript then
		currentAbortDialogScript:Remove()
		currentAbortDialogScript = nil
	end
	local dialog = currentConversationDialog
	currentConversationDialog = nil
	if dialog and dialog.InUse then
		local reenableScript = reenableDialogScript:Clone()
		reenableScript.archivable = false
		reenableScript.Disabled = false
		reenableScript.Parent = dialog
	end
	for dialog, gui in pairs(dialogMap) do
		if dialog and gui then
			gui.Enabled = not dialog.InUse
		end
	end
	currentConversationPartner = nil
end
local wanderDialog
wanderDialog = function()
	print("Wander")
	mainFrame.Visible = false
	endDialog()
	return showMessage(characterWanderedOffMessage, characterWanderedOffSize)
end
local timeoutDialog
timeoutDialog = function()
	print("Timeout")
	mainFrame.Visible = false
	endDialog()
	return showMessage(conversationTimedOut, conversationTimedOutSize)
end
local normalEndDialog
normalEndDialog = function()
	print("Done")
	return endDialog()
end
local sanitizeMessage
sanitizeMessage = function(msg)
	if string.len(msg) == 0 then
		return "..."
	else
		return msg
	end
end
local renewKillswitch
renewKillswitch = function(dialog)
	if currentAbortDialogScript then
		currentAbortDialogScript:Remove()
		currentAbortDialogScript = nil
	end
	currentAbortDialogScript = timeoutScript:Clone()
	currentAbortDialogScript.archivable = false
	currentAbortDialogScript.Disabled = false
	currentAbortDialogScript.Parent = dialog
	return currentAbortDialogScript
end
local presentDialogChoices
presentDialogChoices = function(talkingPart, dialogChoices)
	if not currentConversationDialog then
		return
	end
	currentConversationPartner = talkingPart
	local sortedDialogChoices = { }
	for _, obj in pairs(dialogChoices) do
		if obj:IsA("DialogChoice") then
			table.insert(sortedDialogChoices, obj)
		end
	end
	table.sort(sortedDialogChoices, function(a, b)
		return a.Name < b.Name
	end)
	if #sortedDialogChoices == 0 then
		normalEndDialog()
		return
	end
	local pos = 1
	local yPosition = 0
	choiceMap = { }
	for _, obj in pairs(choices) do
		obj.Visible = false
	end
	for _, obj in pairs(sortedDialogChoices) do
		if pos <= #choices then
			choices[pos].Size = UDim2.new(1, 0, 0, 24 * 3)
			choices[pos].UserPrompt.Text = obj.UserDialog
			local height = math.ceil(choices[pos].UserPrompt.TextBounds.Y / 24) * 24
			choices[pos].Position = UDim2.new(0, 0, 0, yPosition)
			choices[pos].Size = UDim2.new(1, 0, 0, height)
			choices[pos].Visible = true
			choiceMap[choices[pos]] = obj
			yPosition = yPosition + height
			pos = pos + 1
		end
	end
	lastChoice.Position = UDim2.new(0, 0, 0, yPosition)
	lastChoice.Number.Text = pos .. ")"
	mainFrame.Size = UDim2.new(0, 350, 0, yPosition + 24 + 32)
	mainFrame.Position = UDim2.new(0, 20, 0, -mainFrame.Size.Y.Offset - 20)
	styleMainFrame(currentTone())
	mainFrame.Visible = true
end
local selectChoice
selectChoice = function(choice)
	renewKillswitch(currentConversationDialog)
	mainFrame.Visible = false
	if choice == lastChoice then
		game.Chat:Chat(game.Players.LocalPlayer.Character, "Goodbye!", getChatColor(currentTone()))
		return normalEndDialog()
	else
		local dialogChoice = choiceMap[choice]
		game.Chat:Chat(game.Players.LocalPlayer.Character, sanitizeMessage(dialogChoice.UserDialog), getChatColor(currentTone()))
		wait(1)
		currentConversationDialog:SignalDialogChoiceSelected(player, dialogChoice)
		game.Chat:Chat(currentConversationPartner, sanitizeMessage(dialogChoice.ResponseDialog), getChatColor(currentTone()))
		variableDelay(dialogChoice.ResponseDialog)
		return presentDialogChoices(currentConversationPartner, dialogChoice:GetChildren())
	end
end
local newChoice
newChoice = function(numberText)
	local frame = New("TextButton", {
		BackgroundColor3 = Color3.new(0, 0, 179 / 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		RobloxLocked = true,
		New("TextLabel", "Number", {
			TextColor3 = Color3.new(127 / 255, 212 / 255, 255 / 255),
			Text = numberText,
			FontSize = Enum.FontSize.Size14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 4, 0, 2),
			Size = UDim2.new(0, 20, 0, 24),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			RobloxLocked = true
		}),
		New("TextLabel", "UserPrompt", {
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			FontSize = Enum.FontSize.Size14,
			Position = UDim2.new(0, 28, 0, 2),
			Size = UDim2.new(1, -32, 1, -4),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrap = true,
			RobloxLocked = true
		})
	})
	frame.MouseEnter:connect(function()
		return highlightColor(frame, currentTone())
	end)
	frame.MouseLeave:connect(function()
		return resetColor(frame, currentTone())
	end)
	frame.MouseButton1Click:connect(function()
		return selectChoice(frame)
	end)
	return frame
end
local initialize
initialize = function(parent)
	choices[1] = newChoice("1)")
	choices[2] = newChoice("2)")
	choices[3] = newChoice("3)")
	choices[4] = newChoice("4)")
	lastChoice = newChoice("5)")
	lastChoice.UserPrompt.Text = "Goodbye!"
	lastChoice.Size = UDim2.new(1, 0, 0, 28)
	mainFrame = New("Frame", "UserDialogArea", {
		Size = UDim2.new(0, 350, 0, 200),
		Style = Enum.FrameStyle.ChatBlue,
		Visible = false,
		New("ImageLabel", "Tail", {
			Size = UDim2.new(0, 62, 0, 53),
			Position = UDim2.new(1, 8, 0.25),
			Image = "rbxasset://textures/chatBubble_botBlue_tailRight.png",
			BackgroundTransparency = 1,
			RobloxLocked = true
		})
	})
	for _, obj in pairs(choices) do
		obj.RobloxLocked = true
		obj.Parent = mainFrame
		lastChoice.RobloxLocked = true
	end
	lastChoice.Parent = mainFrame
	mainFrame.RobloxLocked = true
	mainFrame.Parent = parent
end
local doDialog
doDialog = function(dialog)
	while not Instance.Lock(dialog, player) do
		wait()
	end
	if dialog.InUse then
		Instance.Unlock(dialog)
		return
	else
		dialog.InUse = true
		Instance.Unlock(dialog)
	end
	currentConversationDialog = dialog
	game.Chat:Chat(dialog.Parent, dialog.InitialPrompt, getChatColor(dialog.Tone))
	variableDelay(dialog.InitialPrompt)
	return presentDialogChoices(dialog.Parent, dialog:GetChildren())
end
local checkForLeaveArea
checkForLeaveArea = function()
	while currentConversationDialog do
		if currentConversationDialog.Parent and (player:DistanceFromCharacter(currentConversationDialog.Parent.Position >= currentConversationDialog.ConversationDistance)) then
			wanderDialog()
		end
		wait(1)
	end
end
local startDialog
startDialog = function(dialog)
	if dialog.Parent and dialog.Parent:IsA("BasePart") then
		if player:DistanceFromCharacter(dialog.Parent.Position) >= dialog.ConversationDistance then
			showMessage(tooFarAwayMessage, tooFarAwaySize)
			return
		end
		for dialog, gui in pairs(dialogMap) do
			if dialog and gui then
				gui.Enabled = false
			end
		end
		renewKillswitch(dialog)
		delay(1, checkForLeaveArea)
		return doDialog(dialog)
	end
end
local removeDialog
removeDialog = function(dialog)
	if dialogMap[dialog] then
		dialogMap[dialog]:Remove()
		dialogMap[dialog] = nil
	end
	if dialogConnections[dialog] then
		dialogConnections[dialog]:disconnect()
		dialogConnections[dialog] = nil
	end
end
local addDialog
addDialog = function(dialog)
	if dialog.Parent then
		if dialog.Parent:IsA("BasePart") then
			local chatGui = chatNotificationGui:clone()
			chatGui.Enabled = not dialog.InUse
			chatGui.Adornee = dialog.Parent
			chatGui.RobloxLocked = true
			chatGui.Parent = game.CoreGui
			chatGui.Image.Button.MouseButton1Click:connect(function()
				return startDialog(dialog)
			end)
			setChatNotificationTone(chatGui, dialog.Purpose, dialog.Tone)
			dialogMap[dialog] = chatGui
			dialogConnections[dialog] = dialog.Changed:connect(function(prop)
				if prop == "Parent" and dialog.Parent then
					removeDialog(dialog)
					return addDialog(dialog)
				elseif prop == "InUse" then
					chatGui.Enabled = not currentConversationDialog and not dialog.InUse
					if dialog == currentConversationDialog then
						return timeoutDialog()
					end
				elseif prop == "Tone" or prop == "Purpose" then
					return setChatNotificationTone(chatGui, dialog.Purpose, dialog.Tone)
				end
			end)
		else
			dialogConnections[dialog] = dialog.Changed:connect(function(prop)
				if prop == "Parent" and dialog.Parent then
					removeDialog(dialog)
					return addDialog(dialog)
				end
			end)
		end
	end
end
local fetchScripts
fetchScripts = function()
	local model = game:GetService("InsertService"):LoadAsset(39226062)
	if type(model) == "string" then
		wait(0.1)
		model = game:GetService("InsertService"):LoadAsset(39226062)
	end
	if type(model) == "string" then
		return
	end
	waitForChild(model, "TimeoutScript")
	timeoutScript = model.TimeoutScript
	waitForChild(model, "ReenableDialogScript")
	reenableDialogScript = model.ReenableDialogScript
end
local onLoad
onLoad = function()
	waitForProperty(game.Players, "LocalPlayer")
	player = game.Players.LocalPlayer
	waitForProperty(player, "Character")
	fetchScripts()
	createChatNotificationGui()
	createMessageDialog()
	messageDialog.RobloxLocked = true
	messageDialog.Parent = gui
	waitForChild(gui, "BottomLeftControl")
	local frame = New("Frame", "DialogFrame", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		RobloxLocked = true,
		Parent = gui.BottomLeftControl
	})
	initialize(frame)
	game.CollectionService.ItemAdded:connect(function(obj)
		if obj:IsA("Dialog") then
			return addDialog(obj)
		end
	end)
	game.CollectionService.ItemRemoved:connect(function(obj)
		if obj:IsA("Dialog") then
			return removeDialog(obj)
		end
	end)
	for _, obj in pairs(game.CollectionService:GetCollection("Dialog")) do
		if obj:IsA("Dialog") then
			addDialog(obj)
		end
	end
end
return onLoad()