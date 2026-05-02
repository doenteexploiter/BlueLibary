# 🔷 Blue UI Library (Executor Version)

A **complete, modern and mobile-friendly UI Library for Roblox**, made for **executors (loadstring)** with full customization and advanced components.

---

## 🚀 Load Library

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/doenteexploiter/BlueLibary/refs/heads/main/blue.lua"))()
local player = game.Players.LocalPlayer

local ui = UILibrary:CreateUI(player)
```

---

## ⚙️ UI Settings

```lua
ui:SetMainColor(Color3.fromRGB(0, 180, 255))
ui:SetUITitle("BLUE UI LIBARY")
ui:SetUIBackgroundAsset("rbxassetid://SEU_ASSET")
```

---

## 📑 Tabs

```lua
local tab = ui:AddTab("Home", "🏠")
```

---

# 🧩 COMPONENTS

---

## 🔘 Button

```lua
ui:CreateButton(parent, text, size, color, callback)
```

```lua
ui:CreateButton(tab, "Click Me", nil, nil, function()
    print("clicked")
end)
```

---

## 📝 TextBox

```lua
ui:CreateTextBox(parent, placeholder, size, callback)
```

```lua
ui:CreateTextBox(tab, "Type here...", nil, function(text)
    print(text)
end)
```

---

## 🔁 Toggle

```lua
ui:CreateToggle(parent, text, defaultState, callback)
```

```lua
local toggle = ui:CreateToggle(tab, "Enable", true, function(state)
    print(state)
end)

toggle.setState(false)
```

---

## 🎚️ Slider

```lua
ui:CreateSlider(parent, text, min, max, defaultValue, size, callback)
```

```lua
local slider = ui:CreateSlider(tab, "Volume", 0, 100, 50, nil, function(v)
    print(v)
end)

slider.setValue(80)
slider.getValue()
```

---

## 📂 Dropdown

```lua
ui:CreateDropdown(parent, items, callback)
```

```lua
ui:CreateDropdown(tab, {"A", "B", "C"}, function(item)
    print(item)
end)
```

---

## 👥 Player Dropdown

```lua
ui:CreatePlayerDropdown(parent, callback)
```

```lua
ui:CreatePlayerDropdown(tab, function(player)
    print(player.Name)
end)
```

---

## 🏷️ Label

```lua
ui:CreateLabel(parent, text, size, textColor, textSize, alignment)
```

```lua
ui:CreateLabel(tab, "Hello World")
```

---

## 🖼️ Image Only

```lua
ui:CreateImageOnly(parent, imageAsset, size)
```

```lua
ui:CreateImageOnly(tab, "rbxassetid://123456")
```

---

## 🖼️ Image Label (Texto + Imagem)

```lua
ui:CreateImageLabel(parent, text, imageAsset, size, textColor, textSize)
```

```lua
ui:CreateImageLabel(
    tab,
    "Join Discord!",
    "rbxassetid://136489865028091",
    UDim2.new(1,0,0,50)
)
```

---

## 💬 Chat Log

```lua
local log = ui:CreateLogChat(parent)
```

```lua
log:addLog("Hello")
```

---

## 👤 Player Profile

```lua
ui:CreatePlayerProfile(parent)
```

---

## 🌐 Social Buttons

### Discord

```lua
ui:CreateDiscordButton(parent, link)
```

---

### YouTube

```lua
ui:CreateYouTubeButton(parent, link)
```

---

## 🔔 Notification

```lua
ui:SendNotification(title, text, duration, iconAsset)
```

```lua
ui:SendNotification("Hello", "Works!", 3)
```

---

# ⚙️ SYSTEMS

---

## 🎨 Theme

```lua
ui:SetMainColor(Color3.fromRGB(255,0,0))
```

---

## 🖼️ Background

```lua
ui:SetUIBackgroundAsset("rbxassetid://ID")
```

---

## 📝 Title

```lua
ui:SetUITitle("New Title")
```

---

## ⌨️ Commands

| Command  | Function |
| -------- | -------- |
| `!tool`  | Open UI  |
| `!close` | Close UI |

---

## 🧠 INTERNAL FEATURES

* Drag UI (mouse + touch)
* Auto player list update
* Smooth animations (TweenService)
* Mobile optimized
* Scroll system automático
* Limitador de logs (30 mensagens)

---

## ⚠️ Executor Notes

Some features require executor support:

* `setclipboard`
* `StarterGui:SetCore`

---

## 💡 Tips

* Use poucas coisas por tab (melhor UX)
* Combine cores com `SetMainColor`
* Evite spam de notificações

---

## 🔥 Full Example

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/doenteexploiter/BlueLibary/refs/heads/main/blue.lua"))()
local player = game.Players.LocalPlayer

local ui = UILibrary:CreateUI(player)

ui:SetMainColor(Color3.fromRGB(0,180,255))
ui:SetUITitle("BLUE HUB")

local home = ui:AddTab("Home", "🏠")

ui:CreateLabel(home, "Welcome!")

ui:CreateButton(home, "Test", nil, nil, function()
    ui:SendNotification("OK", "Working", 2)
end)

ui:CreateToggle(home, "Enable", true, function(v)
    print(v)
end)

ui:CreateSlider(home, "Speed", 0, 100, 50, nil, function(v)
    print(v)
end)

ui:CreateDropdown(home, {"Red","Blue"}, function(opt)
    print(opt)
end)

ui:CreateImageLabel(
    home,
    "Discord",
    "rbxassetid://136489865028091",
    UDim2.new(1,0,0,50)
)

local log = ui:CreateLogChat(home)
log:addLog("UI Loaded!")
```

---

# 📜 License

Free to use, modify and share.

---

# 🚀 Done

Your UI Library is now fully documented.
