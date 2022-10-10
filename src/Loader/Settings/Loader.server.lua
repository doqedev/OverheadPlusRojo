local InRojoEnvironment = (
	game:GetService("ServerStorage"):FindFirstChild("OverheadPlusSource") ~= nil
	and game:GetService("ServerStorage"):FindFirstChild("OverheadPlusSource"):FindFirstChild("MainModule") ~= nil
)

local module = nil

if InRojoEnvironment then
	module = require(game:GetService("ServerStorage").OverheadPlusSource.MainModule)
else
	module = require(11217125583)
end

module:Initiate(script.Parent.Parent)
