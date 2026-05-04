-- =====================================================
-- ORION LIBRARY - VERSÃO CORRIGIDA & MELHORADA
-- Correções: Clique/Touch em todos elementos
-- Novo: Tab Executor + Tab Remote Spy
-- Interface redimensionada para compatibilidade
-- =====================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false,
	Transparency = 0.95,
	BackgroundImage = nil,
	CustomColors = {
		Text = nil,
		Stroke = nil
	}
}

local Icons = {}
local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error: " .. tostring(Response) .. "\n")
end

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	end
	return nil
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionFixed"
Orion.ResetOnSpawn = false
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteção de GUI
pcall(function()
	if syn then
		syn.protect_gui(Orion)
		Orion.Parent = game.CoreGui
	elseif gethui then
		Orion.Parent = gethui()
	else
		Orion.Parent = game.CoreGui
	end
end)

-- Limpar instâncias antigas
pcall(function()
	local parent = gethui and gethui() or game.CoreGui
	for _, v in ipairs(parent:GetChildren()) do
		if v.Name == Orion.Name and v ~= Orion then
			v:Destroy()
		end
	end
end)

function OrionLib:IsRunning()
	return Orion and Orion.Parent ~= nil
end

local function AddConnection(Signal, Function)
	if not OrionLib:IsRunning() then return end
	local ok, conn = pcall(function() return Signal:Connect(Function) end)
	if ok and conn then
		table.insert(OrionLib.Connections, conn)
		return conn
	end
end

task.spawn(function()
	while OrionLib:IsRunning() do task.wait() end
	for _, c in next, OrionLib.Connections do
		pcall(function() c:Disconnect() end)
	end
end)

-- =====================================================
-- SISTEMA DE ARRASTO CORRIGIDO (Mouse + Touch)
-- =====================================================
local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging = false
		local StartMousePos = nil
		local StartFramePos = nil

		local function BeginDrag(pos)
			Dragging = true
			StartMousePos = pos
			StartFramePos = Main.Position
		end

		local function EndDrag()
			Dragging = false
		end

		local function UpdateDrag(pos)
			if not Dragging or not StartMousePos then return end
			local delta = pos - StartMousePos
			Main.Position = UDim2.new(
				StartFramePos.X.Scale,
				StartFramePos.X.Offset + delta.X,
				StartFramePos.Y.Scale,
				StartFramePos.Y.Offset + delta.Y
			)
		end

		DragPoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				BeginDrag(input.Position)
			elseif input.UserInputType == Enum.UserInputType.Touch then
				BeginDrag(input.Position)
			end
		end)

		DragPoint.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or
				input.UserInputType == Enum.UserInputType.Touch then
				EndDrag()
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateDrag(input.Position)
			elseif input.UserInputType == Enum.UserInputType.Touch then
				UpdateDrag(input.Position)
			end
		end)
	end)
end

-- =====================================================
-- UTILITÁRIOS DE CRIAÇÃO DE ELEMENTOS
-- =====================================================
local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		pcall(function() Object[i] = v end)
	end
	for _, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = ElementFunction
end

local function MakeElement(ElementName, ...)
	return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	for Property, Value in pairs(Props) do
		pcall(function() Element[Property] = Value end)
	end
	return Element
end

local function SetChildren(Element, Children)
	for _, Child in pairs(Children) do
		Child.Parent = Element
	end
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
	if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
	if Object:IsA("UIStroke") then return "Color" end
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end
	table.insert(OrionLib.ThemeObjects[Type], Object)
	local prop = ReturnProperty(Object)
	if prop then
		if prop == "BackgroundColor3" and Type == "Main" then
			Object.BackgroundTransparency = 1 - OrionLib.Transparency
		end
		Object[prop] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
		if Type == "Text" and OrionLib.CustomColors.Text then
			Object[prop] = OrionLib.CustomColors.Text
		elseif Type == "Stroke" and OrionLib.CustomColors.Stroke then
			Object[prop] = OrionLib.CustomColors.Stroke
		end
	end
	return Object
end

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			local prop = ReturnProperty(Object)
			if prop then
				if prop == "BackgroundColor3" and Name == "Main" then
					Object.BackgroundTransparency = 1 - OrionLib.Transparency
				end
				local color = OrionLib.Themes[OrionLib.SelectedTheme][Name]
				if Name == "Text" and OrionLib.CustomColors.Text then color = OrionLib.CustomColors.Text end
				if Name == "Stroke" and OrionLib.CustomColors.Stroke then color = OrionLib.CustomColors.Stroke end
				Object[prop] = color
			end
		end
	end
end

function OrionLib:SetTransparency(Value)
	OrionLib.Transparency = math.clamp(Value, 0.3, 1)
	for _, obj in pairs(OrionLib.ThemeObjects["Main"] or {}) do
		pcall(function()
			if obj:IsA("Frame") then
				obj.BackgroundTransparency = 1 - OrionLib.Transparency
			end
		end)
	end
end

function OrionLib:SetTextColor(R, G, B)
	OrionLib.CustomColors.Text = Color3.fromRGB(R, G, B)
	SetTheme()
end

function OrionLib:SetStrokeColor(R, G, B)
	OrionLib.CustomColors.Stroke = Color3.fromRGB(R, G, B)
	SetTheme()
end

function OrionLib:ResetColors()
	OrionLib.CustomColors.Text = nil
	OrionLib.CustomColors.Stroke = nil
	SetTheme()
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	for a, b in pairs(Data) do
		if OrionLib.Flags[a] then
			task.spawn(function()
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end
			end)
		end
	end
end

local function SaveCfg(Name)
	pcall(function()
		local Data = {}
		for i, v in pairs(OrionLib.Flags) do
			if v.Save then
				if v.Type == "Colorpicker" then
					Data[i] = PackColor(v.Value)
				else
					Data[i] = v.Value
				end
			end
		end
		writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
	end)
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then return true end
	end
end

-- =====================================================
-- ELEMENTOS BASE
-- =====================================================
CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {Color = Color or Color3.fromRGB(255, 255, 255), Thickness = Thickness or 1})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)})
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0}, {
		Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 0)})
	})
end)

-- BOTÃO CORRIGIDO - Active=true e AutoButtonColor=false para garantir clique
CreateElement("Button", function()
	return Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		Selectable = true
	})
end)

CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width or 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingEnabled = true
	})
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {Image = ImageID or "", BackgroundTransparency = 1})
	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end
	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	return Create("ImageButton", {
		Image = ImageID or "",
		BackgroundTransparency = 1,
		Active = true,
		Selectable = true,
		AutoButtonColor = false
	})
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	})
end)

-- =====================================================
-- NOTIFICAÇÕES
-- =====================================================
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -20, 1, -20),
	AnchorPoint = Vector2.new(1, 1),
	Size = UDim2.new(0, 300, 1, -20),
	Parent = Orion,
	ZIndex = 99
})

function OrionLib:MakeNotification(NotificationConfig)
	task.spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Name = NotificationConfig.Name or "Notificação"
		NotificationConfig.Content = NotificationConfig.Content or ""
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4393588266"
		NotificationConfig.Time = NotificationConfig.Time or 5

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, 10, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(80, 80, 80), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 13), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		task.wait(0.3)
		pcall(function()
			TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		end)
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		task.wait(0.05)
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0, 0)}):Play()
		task.wait(1.35)
		pcall(function() NotificationFrame:Destroy() end)
	end)
end

function OrionLib:Init()
	if OrionLib.SaveCfg then
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuração",
					Content = "Config carregada para o jogo " .. game.GameId,
					Time = 5
				})
			end
		end)
	end
end

-- =====================================================
-- JANELA PRINCIPAL - TAMANHO MÉDIO PARA COMPATIBILIDADE
-- =====================================================
function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		pcall(function()
			if not isfolder(WindowConfig.ConfigFolder) then
				makefolder(WindowConfig.ConfigFolder)
			end
		end)
	end

	-- TAMANHO ADAPTADO: 560x320 para melhor compatibilidade
	local WIN_W = 560
	local WIN_H = 320
	local TAB_W = 130

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50),
		ScrollingDirection = Enum.ScrollingDirection.Y
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	-- BOTÕES DA TOPBAR CORRIGIDOS
	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		ZIndex = 5
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		ZIndex = 5
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50),
		ZIndex = 2
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, TAB_W, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0)}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0)}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1)}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 28, 0, 28),
				Position = UDim2.new(0, 8, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(1, 0, 1, 0)}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1, 0, 1, 0)}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 12), {
				Size = UDim2.new(1, -45, 0, 13),
				Position = UDim2.new(0, 44, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true,
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 10), {
				Size = UDim2.new(1, -45, 0, 11),
				Position = UDim2.new(0, 44, 0, 28),
				Visible = not WindowConfig.HidePremium,
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "TextDark")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 16), {
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 22, 0, 0),
		Font = Enum.Font.GothamBlack,
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = Orion,
		Position = UDim2.new(0.5, -(WIN_W/2), 0.5, -(WIN_H/2)),
		Size = UDim2.new(0, WIN_W, 0, WIN_H),
		ClipsDescendants = true,
		Name = "MainWindow",
		ZIndex = 2
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar",
			ZIndex = 4
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(0, 68, 0, 28),
				Position = UDim2.new(1, -80, 0, 11),
				ZIndex = 5,
				Name = "BtnContainer"
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0)}), "Stroke"),
				CloseBtn,
				MinimizeBtn
			}), "Second"),
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	MainWindow.BackgroundTransparency = 1 - OrionLib.Transparency

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 46, 0, 0)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 22, 0, 16)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	-- =====================================================
	-- FECHAR / MINIMIZAR CORRIGIDOS
	-- =====================================================
	local function FireClose()
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name = "Interface Ocultada",
			Content = "Digite 'abr' no chat para reabrir a interface.",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end

	local function FireMinimize()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WIN_W, 0, WIN_H)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			task.wait(0.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 120, 0, 50)}):Play()
			task.wait(0.1)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end

	-- Mouse
	AddConnection(CloseBtn.MouseButton1Up, FireClose)
	AddConnection(MinimizeBtn.MouseButton1Up, FireMinimize)

	-- Touch
	CloseBtn.TouchTap:Connect(FireClose)
	MinimizeBtn.TouchTap:Connect(FireMinimize)

	-- Reabrir via chat
	AddConnection(LocalPlayer.Chatted, function(msg)
		local command = msg:lower()
		if command == "abr" then
			MainWindow.Visible = true
			UIHidden = false
			OrionLib:MakeNotification({Name = "Interface", Content = "Interface reaberta!", Time = 3})
		elseif command == "fchr" then
			MainWindow.Visible = false
			UIHidden = true
		end
	end)

	-- RightShift para reabrir
	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
			UIHidden = false
		end
	end)

	-- Botão flutuante para mobile
	local FloatingButton = SetChildren(SetProps(MakeElement("ImageButton", "rbxassetid://7072719338"), {
		Parent = Orion,
		Size = UDim2.new(0, 44, 0, 44),
		Position = UDim2.new(0, 16, 0.5, 0),
		BackgroundTransparency = 0.3,
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Name = "FloatingButton",
		Visible = false,
		Active = true,
		ZIndex = 10
	}), {
		Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
		Create("UIStroke", {Color = Color3.fromRGB(80, 80, 80), Thickness = 1.5})
	})

	AddConnection(MainWindow:GetPropertyChangedSignal("Visible"), function()
		FloatingButton.Visible = UIHidden
	end)

	local function FloatClick()
		if UIHidden then
			MainWindow.Visible = true
			UIHidden = false
			FloatingButton.Visible = false
		end
	end
	AddConnection(FloatingButton.MouseButton1Up, FloatClick)
	FloatingButton.TouchTap:Connect(FloatClick)

	-- Arrastar botão flutuante
	pcall(function()
		local fdrag, fdragStart, fstartPos = false, nil, nil
		FloatingButton.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				fdrag = true; fdragStart = i.Position; fstartPos = FloatingButton.Position
			end
		end)
		FloatingButton.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				fdrag = false
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if fdrag and fdragStart then
				local d = i.Position - fdragStart
				FloatingButton.Position = UDim2.new(fstartPos.X.Scale, fstartPos.X.Offset + d.X, fstartPos.Y.Scale, fstartPos.Y.Offset + d.Y)
			end
		end)
	end)

	-- Intro
	local function LoadSequence()
		MainWindow.Visible = false
		local Logo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1, ZIndex = 20
		})
		local Txt = SetProps(MakeElement("Label", WindowConfig.IntroText, 16), {
			Parent = Orion, Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 20
		})
		TweenService:Create(Logo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		task.wait(0.8)
		TweenService:Create(Logo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(Txt.TextBounds.X/2), 0.5, 0)}):Play()
		task.wait(0.3)
		TweenService:Create(Txt, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		task.wait(1.8)
		TweenService:Create(Txt, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		Logo:Destroy()
		Txt:Destroy()
	end

	if WindowConfig.IntroEnabled then
		task.spawn(LoadSequence)
	end

	-- =====================================================
	-- SISTEMA DE TABS
	-- =====================================================
	local TabFunction = {}

	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 32),
			Parent = TabHolder,
			ZIndex = 3
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 8, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 13), {
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -TAB_W, 1, -50),
			Position = UDim2.new(0, TAB_W, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer",
			ScrollingDirection = Enum.ScrollingDirection.Y
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 10, 8, 8, 10)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 20)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		local function SelectTab()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.2), {TextTransparency = 0.4}):Play()
				end
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, SelectTab)
		TabFrame.TouchTap:Connect(SelectTab)

		-- =====================================================
		-- ELEMENTOS DENTRO DA TAB
		-- =====================================================
		local function GetElements(ItemParent)
			local ElementFunction = {}

			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 14), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				local LabelFunction = {}
				function LabelFunction:Set(ToChange) LabelFrame.Content.Text = ToChange end
				return LabelFunction
			end

			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 14), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 8),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 12), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 24),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)
				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange) ParagraphFrame.Content.Text = ToChange end
				return ParagraphFunction
			end

			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end

				local Button = {}
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 32),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 14), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content",
						TextXAlignment = Enum.TextXAlignment.Center
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				local function DoClick()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
					task.spawn(ButtonConfig.Callback)
					task.wait(0.15)
					TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end

				AddConnection(Click.MouseButton1Up, DoClick)
				Click.TouchTap:Connect(DoClick)

				function Button:Set(ButtonText) ButtonFrame.Content.Text = ButtonText end
				return Button
			end

			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(1, -26, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 18, 0, 18),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Ico"
					}),
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 14), {
						Size = UDim2.new(1, -40, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.25), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.25), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.25), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 18, 0, 18) or UDim2.new(0, 6, 0, 6)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end

				Toggle:Set(Toggle.Value)

				local function DoToggle()
					Toggle:Set(not Toggle.Value)
					SaveCfg(game.GameId)
				end

				AddConnection(Click.MouseButton1Up, DoToggle)
				Click.TouchTap:Connect(DoToggle)

				if ToggleConfig.Flag then OrionLib.Flags[ToggleConfig.Flag] = Toggle end
				return Toggle
			end

			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 12), {
						Size = UDim2.new(1, -8, 0, 14),
						Position = UDim2.new(0, 8, 0, 5),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -20, 0, 24),
					Position = UDim2.new(0, 10, 0, 28),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 12), {
						Size = UDim2.new(1, -8, 0, 14),
						Position = UDim2.new(0, 8, 0, 5),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.7
					}), "Text"),
					SliderDrag
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 60),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 14), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 8),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag, TweenInfo.new(.15), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					local txt = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderBar.Value.Text = txt
					SliderDrag.Value.Text = txt
					SliderConfig.Callback(self.Value)
				end

				local function CalcVal(posX)
					local scale = math.clamp((posX - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					return SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * scale)
				end

				SliderBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
					if i.UserInputType == Enum.UserInputType.Touch then
						Slider:Set(CalcVal(i.Position.X))
						SaveCfg(game.GameId)
					end
				end)
				SliderBar.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
				end)

				UserInputService.InputChanged:Connect(function(i)
					if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						Slider:Set(CalcVal(i.Position.X))
						SaveCfg(game.GameId)
					end
					if i.UserInputType == Enum.UserInputType.Touch then
						-- touch move no slider
						local _, touchOnSlider = pcall(function()
							return SliderBar:IsDescendantOf(game)
						end)
						if Dragging then
							Slider:Set(CalcVal(i.Position.X))
						end
					end
				end)

				Slider:Set(Slider.Value)
				if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
				return Slider
			end

			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 4

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List")
				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {DropdownList}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 36),
					Size = UDim2.new(1, 0, 1, -36),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 14), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 18, 0, 18),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -28, 0.5, 0),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 12), {
							Size = UDim2.new(1, -38, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 36),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 5),
							AddThemeObject(SetProps(MakeElement("Label", Option, 12, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 26),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							ZIndex = 4
						}), "Divider")

						local function DoSelect()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end
						AddConnection(OptionBtn.MouseButton1Click, DoSelect)
						OptionBtn.TouchTap:Connect(DoSelect)
						Dropdown.Buttons[Option] = OptionBtn
					end
				end

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
						end
						return
					end
					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value
					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v, TweenInfo.new(.15), {BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title, TweenInfo.new(.15), {TextTransparency = 0.4}):Play()
					end
					TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(.15), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(.15), {TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				local function DoDropdownToggle()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
					local newSize
					if #Dropdown.Options > MaxElements then
						newSize = Dropdown.Toggled and UDim2.new(1, 0, 0, 36 + (MaxElements * 26)) or UDim2.new(1, 0, 0, 36)
					else
						newSize = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
					end
					TweenService:Create(DropdownFrame, TweenInfo.new(.15), {Size = newSize}):Play()
				end

				AddConnection(Click.MouseButton1Click, DoDropdownToggle)
				Click.TouchTap:Connect(DoDropdownToggle)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then OrionLib.Flags[DropdownConfig.Flag] = Dropdown end
				return Dropdown
			end

			function ElementFunction:AddBind(BindConfig)
				BindConfig = BindConfig or {}
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {Value = nil, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 40, 0, 22),
					Position = UDim2.new(1, -8, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", "None", 11), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, -55, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")

				local function DoBindClick()
					if not Bind.Binding then
						Bind.Binding = true
						BindBox.Value.Text = "..."
						TweenService:Create(BindBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
					end
				end

				AddConnection(Click.MouseButton1Up, DoBindClick)
				Click.TouchTap:Connect(DoBindClick)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or (Input.UserInputType and Input.UserInputType.Name == Bind.Value)) and not Bind.Binding then
						if BindConfig.Hold then Holding = true; BindConfig.Callback(Holding)
						else BindConfig.Callback() end
					elseif Bind.Binding then
						local Key
						pcall(function() if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end end)
						pcall(function() if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if (Input.KeyCode.Name == Bind.Value or (Input.UserInputType and Input.UserInputType.Name == Bind.Value)) then
						if BindConfig.Hold and Holding then Holding = false; BindConfig.Callback(Holding) end
					end
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = (type(Bind.Value) == "string") and Bind.Value or (Bind.Value.Name or tostring(Bind.Value))
					BindBox.Value.Text = Bind.Value
					TweenService:Create(BindBox, TweenInfo.new(0.2), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main}):Play()
				end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then OrionLib.Flags[BindConfig.Flag] = Bind end
				return Bind
			end

			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end
				TextboxConfig.PlaceholderText = TextboxConfig.PlaceholderText or "Input"

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, -8, 1, 0),
					Position = UDim2.new(0, 4, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(160, 160, 160),
					PlaceholderText = TextboxConfig.PlaceholderText,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 13,
					ClearTextOnFocus = false,
					ZIndex = 4
				}), "Text")

				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 80, 0, 22),
					Position = UDim2.new(1, -8, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ClipsDescendants = true
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")

				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 14), {
						Size = UDim2.new(1, -95, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then TextboxActual.Text = "" end
				end)

				local function DoFocus()
					TextboxActual:CaptureFocus()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
				end

				AddConnection(Click.MouseButton1Up, DoFocus)
				Click.TouchTap:Connect(DoFocus)

				TextboxActual.Text = TextboxConfig.Default
				return TextboxActual
			end

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}
				local ColorInput, HueInput = nil, nil

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(ColorS, 0, 1 - ColorV, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0.5, 0, 1 - ColorH, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252"
				}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), ColorSelection})

				local Hue = Create("Frame", {
					Size = UDim2.new(0, 18, 1, 0),
					Position = UDim2.new(1, -18, 0, 0),
					Visible = false
				}, {
					Create("UIGradient", {
						Rotation = 270,
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
							ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234, 255, 0)),
							ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21, 255, 0)),
							ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 17, 255)),
							ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255, 0, 251)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))
						}
					}),
					Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
					HueSelection
				})

				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(1, 0, 1, -30),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue, Color,
					Create("UIPadding", {PaddingLeft = UDim.new(0, 30), PaddingRight = UDim.new(0, 30), PaddingBottom = UDim.new(0, 8), PaddingTop = UDim.new(0, 12)})
				})

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})

				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(1, -8, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 36),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 14), {
							Size = UDim2.new(1, -36, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
					}), {Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true, Name = "F"}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				local function DoColorpickerToggle()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame, TweenInfo.new(.15), {Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 36)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end

				AddConnection(Click.MouseButton1Click, DoColorpickerToggle)
				Click.TouchTap:Connect(DoColorpickerToggle)

				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local px = input.UserInputType == Enum.UserInputType.Touch and input.Position.X or Mouse.X
							local py = input.UserInputType == Enum.UserInputType.Touch and input.Position.Y or Mouse.Y
							ColorS = math.clamp((px - Color.AbsolutePosition.X) / Color.AbsoluteSize.X, 0, 1)
							ColorV = 1 - math.clamp((py - Color.AbsolutePosition.Y) / Color.AbsoluteSize.Y, 0, 1)
							ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then ColorInput:Disconnect() end
					end
				end)

				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then HueInput:Disconnect() end
						HueInput = AddConnection(RunService.RenderStepped, function()
							local py = input.UserInputType == Enum.UserInputType.Touch and input.Position.Y or Mouse.Y
							ColorH = 1 - math.clamp((py - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
							HueSelection.Position = UDim2.new(0.5, 0, 1 - ColorH, 0)
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then HueInput:Disconnect() end
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end

			function ElementFunction:AddSection(SectionConfig)
				SectionConfig = SectionConfig or {}
				SectionConfig.Name = SectionConfig.Name or "Section"

				local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 0, 24),
					Parent = Container
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 12), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 0, 0, 2),
						Font = Enum.Font.GothamSemibold
					}), "TextDark"),
					SetChildren(SetProps(MakeElement("TFrame"), {
						AnchorPoint = Vector2.new(0, 0),
						Size = UDim2.new(1, 0, 1, -22),
						Position = UDim2.new(0, 0, 0, 20),
						Name = "Holder"
					}), {MakeElement("List", 0, 5)}),
				})

				AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 28)
					SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
				end)

				local SectionFunction = {}
				for i, v in next, GetElements(SectionFrame.Holder) do
					SectionFunction[i] = v
				end
				return SectionFunction
			end

			return ElementFunction
		end

		-- Aplicar "PremiumOnly" se necessário
		if TabConfig.PremiumOnly then
			Container:FindFirstChildOfClass("UIListLayout"):Destroy()
			pcall(function() Container:FindFirstChildOfClass("UIPadding"):Destroy() end)
			SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 1, 0), Parent = Container}), {
				AddThemeObject(SetProps(MakeElement("Label", "Acesso Restrito", 14), {
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 12, 0, 20),
					TextTransparency = 0.4
				}), "Text")
			})
		end

		local ElementFunction = {}
		for i, v in next, GetElements(Container) do ElementFunction[i] = v end

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig = SectionConfig or {}
			SectionConfig.Name = SectionConfig.Name or "Section"
			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 24), Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 12), {
					Size = UDim2.new(1, -12, 0, 14),
					Position = UDim2.new(0, 0, 0, 2),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 1, -22),
					Position = UDim2.new(0, 0, 0, 20),
					Name = "Holder"
				}), {MakeElement("List", 0, 5)}),
			})
			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 28)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)
			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do SectionFunction[i] = v end
			return SectionFunction
		end

		return ElementFunction
	end

	-- =====================================================
	-- TAB: EXECUTOR
	-- =====================================================
	function TabFunction:MakeExecutorTab()
		local ExecutorTab = self:MakeTab({Name = "Executor", Icon = "rbxassetid://6031082533"})

		-- Container principal do executor
		local ExecFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(20, 20, 20), 0, 8), {
			Size = UDim2.new(1, 0, 0, 200),
			Parent = nil -- será adicionado ao container abaixo
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke")
		})

		-- TextBox de código
		local CodeBox = Create("TextBox", {
			Size = UDim2.new(1, -16, 1, -10),
			Position = UDim2.new(0, 8, 0, 5),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 255, 200),
			PlaceholderColor3 = Color3.fromRGB(100, 120, 100),
			PlaceholderText = "-- Escreva seu script aqui...\n-- Suporta loadstring, require, etc.",
			Font = Enum.Font.Code,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			MultiLine = true,
			ClearTextOnFocus = false,
			TextWrapped = true,
			ZIndex = 3,
			Parent = ExecFrame
		})

		-- Container do executor com scroll
		local ExecScroll = Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 200),
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ZIndex = 2,
			Parent = nil
		})
		ExecFrame.Parent = ExecScroll

		-- Wrapper frame visível na tab
		local WrapperFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
			Size = UDim2.new(1, 0, 0, 216),
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke"),
			ExecFrame
		}), "Second")

		-- Adicionar diretamente ao Container da tab via parent hacking
		-- Vamos usar a função MakeTab normal para adicionar elementos
		local function AddToTabContainer(Obj)
			Obj.Parent = nil
			for _, v in ipairs(MainWindow:GetChildren()) do
				if v.Name == "ItemContainer" and v.Visible then
					Obj.Parent = v
					break
				end
			end
		end

		-- Implementação mais direta: criar botões normalmente
		-- Usaremos campos de texto e botões padrão da tab

		local scriptHistory = {}
		local currentScript = ""
		local savedScripts = {}

		-- Área de texto (via label decorativo)
		ExecutorTab:AddLabel("📝 Editor de Script")

		-- TextBox para o script
		local ScriptInput = ExecutorTab:AddTextbox({
			Name = "Script",
			Default = "",
			PlaceholderText = "-- Seu script aqui...",
			Callback = function(text)
				currentScript = text
			end
		})

		-- Botões de controle
		ExecutorTab:AddButton({
			Name = "▶  Executar Script",
			Callback = function()
				if currentScript and currentScript ~= "" then
					table.insert(scriptHistory, 1, currentScript)
					if #scriptHistory > 20 then table.remove(scriptHistory) end
					local ok, err = pcall(function()
						local fn, loadErr = loadstring(currentScript)
						if fn then
							fn()
							OrionLib:MakeNotification({Name = "Executor", Content = "Script executado!", Time = 3})
						else
							OrionLib:MakeNotification({Name = "Erro de Sintaxe", Content = tostring(loadErr), Time = 5})
						end
					end)
					if not ok then
						OrionLib:MakeNotification({Name = "Erro de Runtime", Content = tostring(err), Time = 5})
					end
				else
					OrionLib:MakeNotification({Name = "Executor", Content = "Nenhum script para executar.", Time = 3})
				end
			end
		})

		ExecutorTab:AddButton({
			Name = "🗑  Limpar Editor",
			Callback = function()
				currentScript = ""
				if ScriptInput and ScriptInput.PlaceholderText then
					pcall(function() ScriptInput.Text = "" end)
				end
				OrionLib:MakeNotification({Name = "Executor", Content = "Editor limpo.", Time = 2})
			end
		})

		ExecutorTab:AddButton({
			Name = "💾  Salvar Script",
			Callback = function()
				if currentScript ~= "" then
					local name = "script_" .. os.time()
					savedScripts[name] = currentScript
					pcall(function()
						if not isfolder("OrionScripts") then makefolder("OrionScripts") end
						writefile("OrionScripts/" .. name .. ".lua", currentScript)
					end)
					OrionLib:MakeNotification({Name = "Salvo", Content = "Script salvo como: " .. name, Time = 3})
				end
			end
		})

		ExecutorTab:AddButton({
			Name = "🔄  Último Script",
			Callback = function()
				if #scriptHistory > 0 then
					currentScript = scriptHistory[1]
					pcall(function() ScriptInput.Text = currentScript end)
					OrionLib:MakeNotification({Name = "Executor", Content = "Último script carregado.", Time = 2})
				else
					OrionLib:MakeNotification({Name = "Executor", Content = "Nenhum histórico disponível.", Time = 2})
				end
			end
		})

		ExecutorTab:AddLabel("📦 Scripts Rápidos")

		ExecutorTab:AddButton({
			Name = "Print Players",
			Callback = function()
				local code = 'for _, p in pairs(game.Players:GetPlayers()) do print(p.Name) end'
				currentScript = code
				pcall(function() ScriptInput.Text = code end)
			end
		})

		ExecutorTab:AddButton({
			Name = "Infinite Yield",
			Callback = function()
				local code = 'loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
				currentScript = code
				pcall(function() ScriptInput.Text = code end)
				OrionLib:MakeNotification({Name = "Executor", Content = "Script carregado. Clique em Executar.", Time = 3})
			end
		})

		ExecutorTab:AddButton({
			Name = "Print Workspace",
			Callback = function()
				local code = 'for _, v in pairs(workspace:GetDescendants()) do print(v.Name, v.ClassName) end'
				currentScript = code
				pcall(function() ScriptInput.Text = code end)
			end
		})

		return ExecutorTab
	end

	-- =====================================================
	-- TAB: REMOTE SPY
	-- =====================================================
	function TabFunction:MakeRemoteSpyTab()
		local SpyTab = self:MakeTab({Name = "Remote Spy", Icon = "rbxassetid://6031068420"})

		local remoteLog = {}
		local spyActive = false
		local connections = {}
		local maxLogs = 50
		local selectedRemote = nil
		local fireCount = {}

		SpyTab:AddLabel("🔍 Remote Spy - SimpleRSpy")

		local ActiveToggle = SpyTab:AddToggle({
			Name = "Ativar Spy",
			Default = false,
			Color = Color3.fromRGB(0, 180, 100),
			Callback = function(val)
				spyActive = val
				if val then
					OrionLib:MakeNotification({Name = "Remote Spy", Content = "Spy ativado! Monitorando remotes...", Time = 3})
				else
					OrionLib:MakeNotification({Name = "Remote Spy", Content = "Spy desativado.", Time = 2})
					-- Desconectar hooks antigos
					for _, c in pairs(connections) do pcall(function() c:Disconnect() end) end
					table.clear(connections)
				end
			end
		})

		SpyTab:AddButton({
			Name = "🗑  Limpar Logs",
			Callback = function()
				table.clear(remoteLog)
				table.clear(fireCount)
				selectedRemote = nil
				OrionLib:MakeNotification({Name = "Remote Spy", Content = "Logs limpos.", Time = 2})
			end
		})

		-- Label de status dinâmico
		local StatusLabel = SpyTab:AddLabel("Status: Inativo | Logs: 0")
		local RemoteLabel = SpyTab:AddLabel("Último Remote: nenhum")
		local ArgsLabel = SpyTab:AddLabel("Args: nenhum")

		-- Label para mostrar remotes capturados
		SpyTab:AddLabel("─────────────────────────")

		local RemoteListLabel = SpyTab:AddLabel("(Ative o Spy para capturar remotes)")
		local ArgsDisplayLabel = SpyTab:AddLabel("")

		SpyTab:AddButton({
			Name = "📋  Copiar Último Remote",
			Callback = function()
				if #remoteLog > 0 then
					local last = remoteLog[1]
					local txt = string.format(
						'-- Remote: %s\n-- Tipo: %s\n-- Path: %s\ngame:GetService("ReplicatedStorage"):FindFirstChild("%s"):FireServer()',
						last.name, last.rtype, last.path, last.name
					)
					pcall(function() setclipboard(txt) end)
					OrionLib:MakeNotification({Name = "Copiado!", Content = "Script do remote copiado.", Time = 3})
				else
					OrionLib:MakeNotification({Name = "Spy", Content = "Nenhum remote capturado ainda.", Time = 2})
				end
			end
		})

		SpyTab:AddButton({
			Name = "🔁  Repetir Último Remote",
			Callback = function()
				if #remoteLog > 0 then
					local last = remoteLog[1]
					if last.remote and last.remote.Parent then
						local ok, err = pcall(function()
							if last.rtype == "RemoteEvent" then
								last.remote:FireServer(table.unpack(last.args or {}))
							elseif last.rtype == "RemoteFunction" then
								last.remote:InvokeServer(table.unpack(last.args or {}))
							end
						end)
						if ok then
							OrionLib:MakeNotification({Name = "Repetido!", Content = "Remote repetido: " .. last.name, Time = 3})
						else
							OrionLib:MakeNotification({Name = "Erro", Content = tostring(err), Time = 4})
						end
					else
						OrionLib:MakeNotification({Name = "Spy", Content = "Remote não está mais disponível.", Time = 3})
					end
				else
					OrionLib:MakeNotification({Name = "Spy", Content = "Nenhum remote para repetir.", Time = 2})
				end
			end
		})

		SpyTab:AddButton({
			Name = "📊  Ver Todos os Remotes",
			Callback = function()
				if #remoteLog == 0 then
					OrionLib:MakeNotification({Name = "Spy", Content = "Nenhum remote capturado.", Time = 2})
					return
				end
				local seen = {}
				local list = ""
				for i, r in ipairs(remoteLog) do
					if not seen[r.name] then
						seen[r.name] = true
						list = list .. string.format("[%s] %s (%dx)\n", r.rtype:sub(1,2), r.name, fireCount[r.name] or 1)
					end
					if i >= 10 then list = list .. "...e mais"; break end
				end
				RemoteListLabel:Set(list ~= "" and list or "Vazio")
			end
		})

		-- Hook de remotes usando task.spawn para não bloquear
		task.spawn(function()
			while true do
				task.wait(0.1)
				if not spyActive then continue end

				-- Hook dinâmico de todos RemoteEvents/Functions no jogo
				pcall(function()
					for _, remote in ipairs(game:GetDescendants()) do
						if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
							local rname = remote.Name
							local rtype = remote.ClassName
							local rpath = remote:GetFullName()

							-- Verificar se já hookamos este remote
							if not fireCount[rname] then
								fireCount[rname] = 0

								local hookConn
								pcall(function()
									if remote:IsA("RemoteEvent") then
										hookConn = remote.OnClientEvent:Connect(function(...)
											if not spyActive then return end
											fireCount[rname] = (fireCount[rname] or 0) + 1
											local entry = {
												name = rname,
												rtype = rtype,
												path = rpath,
												remote = remote,
												args = {...},
												time = os.clock()
											}
											table.insert(remoteLog, 1, entry)
											if #remoteLog > maxLogs then table.remove(remoteLog) end

											-- Atualizar UI
											StatusLabel:Set("Status: Ativo | Logs: " .. #remoteLog)
											RemoteLabel:Set("Último: [" .. rtype:sub(1, 2) .. "] " .. rname)

											-- Formatar args
											local argStr = ""
											local args = {...}
											for i, a in ipairs(args) do
												argStr = argStr .. tostring(a)
												if i < #args then argStr = argStr .. ", " end
											end
											ArgsLabel:Set("Args: " .. (argStr ~= "" and argStr or "nenhum"))
										end)
										table.insert(connections, hookConn)
									end
								end)
							end
						end
					end
				end)
			end
		end)

		return SpyTab
	end

	return TabFunction
end

function OrionLib:Destroy()
	pcall(function() Orion:Destroy() end)
end

return OrionLib
