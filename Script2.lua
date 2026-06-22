-- [[ BLOX FRUITS SEA 1 RAYFIELD ALL-IN-ONE HUB ]]
-- Versão Avançada Otimizada: Sistema de Key, Viagem Linear (Velocidade 100), Auto Farm Morte (5 Studs acima da Cabeça), Fruit Dropdown Teleport & ESP Sync, Magnet Real Corrigido
-- Totalmente compatível com Delta Executor (Mobile & PC)

if game.CoreGui:FindFirstChild("Rayfield") then
    game.CoreGui.Rayfield:Destroy()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Delta Fruits Hub 🌊 (Tween 100 Speed)",
   LoadingTitle = "Injetando Motores de Automação...",
   LoadingSubtitle = "by Gemini v13",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   
   -- [[ SISTEMA DE KEY ALTERADO ]]
   KeySystem = true,
   KeySettings = {
      Title = "Sistema de Chave (Verification)",
      Subtitle = "Insira a Key para liberar o script",
      Note = "A chave padrão foi alterada.",
      FileName = "DeltaKeyConfig",
      SaveKey = true, 
      GrabKeyFromUrl = false,
      Key = {"publicado123"}
   }
})

-- Shorthands de Serviços do Roblox (Melhor Performance)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURAÇÕES DO HUB ]]
local Flags = {
    AutoFarmMorte = false,
    AutoChest = false,
    AntiBanActive = false,
    FruitESP = false,
    BringMobs = false,
    MaxDistance = 1000,
    CollectDelay = 0.25,
    TravelSpeed = 100
}

local FruitsInServer = {} 
local SelectedFruitInstance = nil 

-- [[ LISTA NEGRA DE BOSSES (SEA 1) ]]
local BossBlacklist = {
    "Saber Expert", "The Saw", "Greybeard", "Gorilla King", "Bobby", 
    "Veti", "Vice Admiral", "Warden", "Chief Warden", "Swan", 
    "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God"
}

local function IsBoss(npc)
    local npcName = npc.Name
    for i = 1, #BossBlacklist do
        if BossBlacklist[i] == npcName then return true end
    end
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.MaxHealth >= 5000 then
        return true
    end
    return false
end

-- [[ SISTEMA DE CAPTURA DE FRUTAS (DYNAMIC ESP) ]]
local function ApplyDynamicFruitESP(fruit)
    if fruit:FindFirstChild("FruitESP_Gui") then return end
    local targetPart = fruit:IsA("Model") and (fruit.PrimaryPart or fruit:FindFirstChildOfClass("BasePart")) or fruit
    if not targetPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FruitESP_Gui"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 35) 
    billboard.Adornee = targetPart
    billboard.Parent = fruit

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1 
    textLabel.Text = "[ 🍎 " .. fruit.Name .. " ]"
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 120) 
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = billboard
end

-- [[ TELEPORTE CAMUFLADO (CURTA DISTÂNCIA) ]]
local function SecureMove(hrp, targetCFrame)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        if Flags.AntiBanActive then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
        hrp.CFrame = targetCFrame * CFrame.new(0, 1.2, 0)
    end)
end

-- [[ SISTEMA DE VIAGEM SUAVE A 100 DE VELOCIDADE (LONGA DISTÂNCIA) ]]
local function SmoothTravel(targetCFrame)
    local completed = false
    pcall(function()
        local character = LocalPlayer.Character
        if not character then completed = true return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp then completed = true return end
        
        local distance = (targetCFrame.Position - hrp.Position).Magnitude
        
        if distance < 15 then
            hrp.CFrame = targetCFrame
            completed = true
            return
        end
        
        local duration = distance / Flags.TravelSpeed
        
        local floatPart = Instance.new("Part")
        floatPart.Size = Vector3.new(10, 1, 10)
        floatPart.Transparency = 1
        floatPart.Anchored = true
        floatPart.CanCollide = true
        floatPart.Parent = workspace
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if character and hrp and floatPart.Parent then
                floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
            else
                if connection then connection:Disconnect() end
            end
        end)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
        
        if connection then connection:Disconnect() end
        floatPart:Destroy()
        completed = true
    end)
    repeat task.wait() until completed
end

-- [[ FUNÇÃO PARA ENCONTRAR O NPC MAIS PRÓXIMO ]]
local function GetClosestNPC()
    local closestNPC = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        local myPos = character.HumanoidRootPart.Position
        local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
        
        for _, npc in pairs(enemiesFolder:GetChildren()) do
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            local root = npc:FindFirstChild("HumanoidRootPart")
            
            if root and humanoid and humanoid.Health > 0 and humanoid.MaxHealth > 100 and not IsBoss(npc) then
                local distance = (root.Position - myPos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestNPC = npc
                end
            end
        end
    end
    return closestNPC
end

-- [[ SISTEMA AUXILIAR DE AUTO-CLICKER CENTRAL ]]
local function ClickCenterScreen()
    pcall(function()
        if Camera then
            local centerViewport = Camera.ViewportSize / 2
            VirtualInputManager:SendMouseButtonEvent(centerViewport.X, centerViewport.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(centerViewport.X, centerViewport.Y, 0, false, game, 1)
        end
    end)
end

-- [[ CRIAÇÃO DAS ABAS ]]
local FarmMorteTab = Window:CreateTab("⚔️ Auto Farm (Morte)", 4483362458)
local FarmTab = Window:CreateTab("🌾 Automação de Farm", 4483362458)
local ChestTab = Window:CreateTab("💰 Farm de Baús", 4483362458)
local IslandTab = Window:CreateTab("📍 Ilhas (Viagem Segura)", 4483362458)
local VisualTab = Window:CreateTab("⚡ Visual & Desempenho", 4483362458)

-- [[ ABA: AUTO FARM POR MORTE ]]
FarmMorteTab:CreateToggle({
   Name = "Ativar Auto Farm por Morte + Clicker + Aimlock",
   CurrentValue = false,
   Flag = "AutoFarmMorteToggle",
   Callback = function(Value)
      Flags.AutoFarmMorte = Value
      
      if Flags.AutoFarmMorte then
          task.spawn(function()
              while Flags.AutoFarmMorte do
                  task.wait(0.1)
                  pcall(function()
                      local targetNPC = GetClosestNPC()
                      if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") and targetNPC:FindFirstChildOfClass("Humanoid") then
                          local npcHumanoid = targetNPC:FindFirstChildOfClass("Humanoid")
                          local npcRoot = targetNPC:FindFirstChild("HumanoidRootPart")
                          
                          SmoothTravel(npcRoot.CFrame * CFrame.new(0, 8, 0))
                          
                          while Flags.AutoFarmMorte and targetNPC and targetNPC.Parent and npcHumanoid.Health > 0 do
                              RunService.RenderStepped:Wait()
                              local character = LocalPlayer.Character
                              if character and character:FindFirstChild("HumanoidRootPart") and npcRoot then
                                  character.HumanoidRootPart.CFrame = npcRoot.CFrame * CFrame.new(0, 8, 0)
                                  character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                  Camera.CFrame = CFrame.new(Camera.CFrame.Position, npcRoot.Position)
                              end
                          end
                      end
                  end)
              end
          end)

          task.spawn(function()
              while Flags.AutoFarmMorte do
                  RunService.RenderStepped:Wait()
                  ClickCenterScreen()
              end
          end)
      end
   end,
})

-- [[ ABA 1: AUTOMAÇÃO DE FARM (NPC MAGNET ULTRA REFORMULADO) ]]
FarmTab:CreateToggle({
   Name = "Juntar Inimigos (NPC Magnet Real)",
   CurrentValue = false,
   Flag = "BringMobsToggle",
   Callback = function(Value)
      Flags.BringMobs = Value
      
      if Flags.BringMobs then
          task.spawn(function()
              local renderConnection
              renderConnection = RunService.Heartbeat:Connect(function()
                  if not Flags.BringMobs then
                      if renderConnection then renderConnection:Disconnect() end
                      return
                  end
                  
                  pcall(function()
                      local character = LocalPlayer.Character
                      if character and character:FindFirstChild("HumanoidRootPart") then
                          local myRoot = character.HumanoidRootPart
                          local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                          
                          for _, npc in pairs(enemiesFolder:GetChildren()) do
                              local humanoid = npc:FindFirstChildOfClass("Humanoid")
                              local root = npc:FindFirstChild("HumanoidRootPart")
                              
                              if root and humanoid and humanoid.Health > 0 and not IsBoss(npc) then
                                  local distance = (root.Position - myRoot.Position).Magnitude
                                  
                                  if distance <= 250 then 
                                      -- Remove colisão física local instantaneamente
                                      for _, part in pairs(npc:GetChildren()) do
                                          if part:IsA("BasePart") then
                                              part.CanCollide = false
                                          end
                                      end
                                      
                                      -- Congela a IA e a física padrão dele
                                      humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                                      root.Velocity = Vector3.new(0, 0, 0)
                                      root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                      
                                      -- Prende o NPC logo à frente (-3) e levemente abaixo (-1) para registrar seu ataque manual
                                      root.CFrame = myRoot.CFrame * CFrame.new(0, -1, -3)
                                  end
                              end
                          end
                      end
                  end)
              end)
          end)
      end
   end,
})

-- [[ ABA 2: FARM DE BAÚS ]]
ChestTab:CreateToggle({
   Name = "Ativar Camuflagem Anti-Ban",
   CurrentValue = false,
   Flag = "AntiBanToggle",
   Callback = function(Value) Flags.AntiBanActive = Value end,
})

ChestTab:CreateToggle({
   Name = "Auto Farm Baús (Raio 1000 Studs)",
   CurrentValue = false,
   Flag = "OptimizedChestToggle", 
   Callback = function(Value)
      Flags.AutoChest = Value
      
      if Flags.AutoChest then
          task.spawn(function()
              while Flags.AutoChest do
                  task.wait(0.05)
                  pcall(function()
                      local character = LocalPlayer.Character
                      if character and character:FindFirstChild("HumanoidRootPart") then
                          local myRoot = character.HumanoidRootPart
                          for _, v in pairs(workspace:GetDescendants()) do
                              if not Flags.AutoChest then break end
                              if v.Name:find("Chest") and (v:IsA("BasePart") or v:IsA("Model")) then
                                  local chestCFrame = v:IsA("Model") and v:GetPivot() or v.CFrame
                                  local distance = (chestCFrame.Position - myRoot.Position).Magnitude
                                  if distance <= Flags.MaxDistance then
                                      SecureMove(myRoot, chestCFrame)
                                      task.wait(Flags.CollectDelay) 
                                  end
                              end
                          end
                      end
                  end)
              end
          end)
      end
   end,
})

-- [[ ABA 3: TELEPORTES COM TWEEN FIXO 100 ]]
IslandTab:CreateButton({ Name = "🍎 NPC: Vendedor de Frutas (Selva)", Callback = function() SmoothTravel(CFrame.new(-1246, 16, 514)) end })
IslandTab:CreateButton({ Name = "🌴 Ilha Inicial (Piratas)", Callback = function() SmoothTravel(CFrame.new(1037, 16, 1426)) end })
IslandTab:CreateButton({ Name = "⚓ Ilha Inicial (Marinhos)", Callback = function() SmoothTravel(CFrame.new(-2566, 7, 4322)) end })
IslandTab:CreateButton({ Name = "🐒 Selva (Jungle) [Lv. 15]", Callback = function() SmoothTravel(CFrame.new(-1237, 12, 331)) end })
IslandTab:CreateButton({ Name = "🏴‍☠️ Vila dos Piratas [Lv. 30]", Callback = function() SmoothTravel(CFrame.new(-1146, 5, 3824)) end })
IslandTab:CreateButton({ Name = "🏜️ Deserto (Desert) [Lv. 60]", Callback = function() SmoothTravel(CFrame.new(1094, 6, 4376)) end })
IslandTab:CreateButton({ Name = "❄️ Vila Congelada (Gelo) [Lv. 90]", Callback = function() SmoothTravel(CFrame.new(1185, 6, -4518)) end })
IslandTab:CreateButton({ Name = "🏙️ Cidade do Meio [Lv. 100]", Callback = function() SmoothTravel(CFrame.new(-652, 8, 1582)) end })
IslandTab:CreateButton({ Name = "🏰 Fortaleza da Marinha [Lv. 120]", Callback = function() SmoothTravel(CFrame.new(-4607, 20, 4278)) end })
IslandTab:CreateButton({ Name = "☁️ Skypiea (Ilha do Céu) [Lv. 150]", Callback = function() SmoothTravel(CFrame.new(-1242, 722, -1815)) end })
IslandTab:CreateButton({ Name = "⛓️ Prisão (Prison) [Lv. 190]", Callback = function() SmoothTravel(CFrame.new(4807, 6, 735)) end })
IslandTab:CreateButton({ Name = "🔱 Cidade Subaquática [Lv. 250]", Callback = function() SmoothTravel(CFrame.new(6116, 11, 4019)) end })
IslandTab:CreateButton({ Name = "🌋 Vila do Magma [Lv. 300]", Callback = function() SmoothTravel(CFrame.new(-5230, 12, 8520)) end })
IslandTab:CreateButton({ Name = "⛲ Cidade da Fonte [Lv. 625]", Callback = function() SmoothTravel(CFrame.new(5125, 4, 4105)) end })

-- [[ ABA 4: VISUAL, PERFORMANCE E TELEPORTE DE FRUTAS ]]
local FruitDropdown = VisualTab:CreateDropdown({
   Name = "Frutas no Servidor",
   Options = {"Nenhuma fruta detectada"},
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "FruitServerDropdown",
   Callback = function(Option)
       SelectedFruitInstance = FruitsInServer[Option[1]]
   end,
})

VisualTab:CreateButton({
   Name = "Confirmar Teleporte para Fruta",
   Callback = function()
       if SelectedFruitInstance and SelectedFruitInstance.Parent then
           local targetCFrame = SelectedFruitInstance:IsA("Model") and SelectedFruitInstance:GetPivot() or SelectedFruitInstance.CFrame
           Rayfield:Notify({ Title = "Teleportando", Content = "Indo até a fruta a 100 de velocidade...", Duration = 3 })
           SmoothTravel(targetCFrame)
       else
           Rayfield:Notify({ Title = "Erro", Content = "Selecione uma fruta válida na lista primeiro ou atualize a lista.", Duration = 4 })
       end
   end,
})

local function RefreshFruitListAndESP()
    FruitsInServer = {}
    local optionsList = {}
    local count = 0
    
    for _, object in pairs(workspace:GetChildren()) do
        if object.Name:find("Fruit") and (object:IsA("Tool") or object:IsA("Model")) then
            count = count + 1
            local uniqueName = tostring(count) .. ". " .. object.Name
            FruitsInServer[uniqueName] = object
            table.insert(optionsList, uniqueName)
            ApplyDynamicFruitESP(object)
        end
    end
    
    if #optionsList == 0 then
        table.insert(optionsList, "Nenhuma fruta encontrada")
        SelectedFruitInstance = nil
    end
    
    FruitDropdown:Refresh(optionsList, true)
    Rayfield:Notify({ Title = "Lista Atualizada!", Content = "Frutas mapeadas e marcas de ESP sincronizadas.", Duration = 3 })
end

VisualTab:CreateButton({
   Name = "🔄 Atualizar Lista de Frutas & Sincronizar ESP",
   Callback = function()
       RefreshFruitListAndESP()
   end,
})

VisualTab:CreateToggle({
   Name = "Rastreador de Frutas Automático (Loops)",
   CurrentValue = false,
   Flag = "FruitESPToggle",
   Callback = function(Value)
      Flags.FruitESP = Value
      if Flags.FruitESP then
          task.spawn(function()
              while Flags.FruitESP do
                  task.wait(3)
                  pcall(function()
                      for _, object in pairs(workspace:GetChildren()) do
                          if not Flags.FruitESP then break end
                          if object.Name:find("Fruit") and (object:IsA("Tool") or object:IsA("Model")) then
                              ApplyDynamicFruitESP(object)
                          end
                      end
                  end)
              end
          end)
      end
   end,
})

VisualTab:CreateButton({
   Name = "Otimizar FPS (Remover Lag/Texturas)",
   Callback = function()
       pcall(function()
           for _, v in pairs(game:GetDescendants()) do
               if v:IsA("DataModelMesh") or v:IsA("CharacterMesh") then v:Destroy()
               elseif v:IsA("Texture") or v:IsA("Decal") then v.Texture = ""
               elseif v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
           end
           local terrain = workspace:FindFirstChildOfClass("Terrain")
           if terrain then
               terrain.WaterWaveSize = 0
               terrain.WaterWaveSpeed = 0
               terrain.WaterReflectance = 0
           end
           Lighting.GlobalShadows = false
           Rayfield:Notify({ Title = "Lag Removido!", Content = "Texturas limpas com sucesso.", Duration = 3, Image = 4483362458 })
       end)
   end,
})

Rayfield:Notify({
   Title = "Hub Inicializado",
   Content = "Sistema carregado com o Magnet de Ataque Manual corrigido.",
   Duration = 5,
   Image = 4483362458,
})
