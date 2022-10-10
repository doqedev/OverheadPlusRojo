local op = {}
--/ Define services
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local Overhead = script.Overhead
local BadgeService = game:GetService("BadgeService")
local customTags = {}
--/ Define types
export type GroupRankSettings = {
	StaffRank: number?,
	DeveloperRank: number?,
	--// owner rank is automatically 255
}

export type OverheadSettings = {
	HideFromExploiters: boolean,
	Icon: number?,
	GroupId: number?,
	GroupRanks: GroupRankSettings?,
	BetaBadgeId: number?,
	CustomTags: { string },
}

function makeRankTag(plr: Player, settings: OverheadSettings)
	local clone = Overhead:Clone()
	clone.Base.Username.Username.Text = plr.Name
	local rankText = "Guest"
	local tag = "" --/ only one tag can be visible without a bug

	if plr.MembershipType == Enum.MembershipType.Premium then
		tag = "RobloxPremium"
	end
	if plr.UserId == game.CreatorId then
		rankText = "Owner"
		tag = "Developer"
		clone.Base.Tags.Beta.Visible = true
	elseif settings.GroupId and typeof(settings.GroupId) == "number" and settings.GroupId > 0 then
		local rank = plr:GetRankInGroup(settings.GroupId)
		local rankT = plr:GetRoleInGroup(settings.GroupId)
		if settings.GroupRanks.DeveloperRank > 0 and rank >= settings.GroupRanks.DeveloperRank then
			tag = "Developer"
		elseif settings.GroupRanks.StaffRank > 0 and rank >= settings.GroupRanks.StaffRank then
			tag = "Staff"
		end
		rankText = rankT
	end
	if
		settings.BetaBadgeId
		and typeof(settings.BetaBadgeId) == "number"
		and settings.BetaBadgeId > 0
		and BadgeService:UserHasBadgeAsync(plr.UserId, settings.BetaBadgeId)
	then
		clone.Base.Tags.Beta.Visible = true
	end

	clone.Base.Rank.Rank.Text = customTags[plr.UserId] or rankText
	clone.Parent = plr.Character.Head
	if tag ~= "" then
		clone.Base.Rank[tag].Visible = true
	end

	return clone
end

function op:Initiate(initfolder: Folder)
	StarterPlayer.NameDisplayDistance = 0
	StarterPlayer.HealthDisplayDistance = 0

	local settings: OverheadSettings = require(initfolder.Settings)

	for i, v in pairs(settings.CustomTags) do
		customTags[i] = v
	end

	if settings.HideFromExploiters == true then
		initfolder.Parent = game:GetService("ServerStorage")
	end

	if settings.Icon ~= nil and typeof(settings.Icon) == "number" and settings.Icon > 0 then
		Overhead.Base.Rank.Staff.Image = settings.Icon
	end

	Players.PlayerAdded:Connect(function(plr: Player)
		if plr.Character then
			pcall(makeRankTag, plr, settings)
		end

		plr.CharacterAdded:Connect(function(char)
			repeat
				wait()
			until char:FindFirstChild("Head") ~= nil
			wait(0.01)
			pcall(makeRankTag, plr, settings)
		end)
	end)
end

return op
