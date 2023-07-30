    --inicio
    --inicio
    --inicio
    --inicio
    --inicio
    --inicio
    --inicio
    --inicio
    --inicio

    -- #DEPENDENCIA
    -- #DEPENDENCIA
    -- #DEPENDENCIA

    -- Verifica se a biblioteca JSON está instalada
    local json_lib_installed = false
    file.Enumerate(function(filename)
        if filename == "libraries/json.lua" then
            json_lib_installed = true
        end
    end)

    -- Instala a biblioteca JSON caso não esteja instalada
    if not json_lib_installed then
        local body = http.Get("https://raw.githubusercontent.com/Aimware0/aimware_scripts/main/libraries/json.lua")
        file.Write("libraries/json.lua", body)
    end

    -- Carrega a biblioteca JSON
    RunScript("libraries/json.lua")

    -- #ARQUIVOS DE GRAVAÇÃO
    -- #ARQUIVOS DE GRAVAÇÃO
    -- #ARQUIVOS DE GRAVAÇÃO

    -- Função para verificar se um arquivo existe
    function file.Exists(file_name)
        local exists = false
        file.Enumerate(function(_name)
            if file_name == _name then
                exists = true
            end
        end)
        return exists
    end

    -- Nome do arquivo de configuração do Walk Bot
    local file_name = "SuperiorWalkBot(Routes).txt"

    -- Cria o arquivo de configuração se não existir
    if not file.Exists(file_name) or string.len(file.Read(file_name)) <= 1 then
        file.Write(file_name, "[]")
    end

    -- Tabela para armazenar os dados do Walk Bot
    local ChickenWalkBot = {}

    -- Função para obter os nomes salvos do Walk Bot
    local function get_saved_walkbot_names()
        local names = {}
        local contents = json.decode(file.Read(file_name))

        for k, v in pairs(contents) do
            table.insert(names, k)
        end

        return names
    end

    -- Função para obter os dados salvos do Walk Bot com base no índice
    local function get_saved_walkbot_data(index)
        local contents = json.decode(file.Read(file_name))

        local i = 0
        for k, v in pairs(contents) do
            if i == index then
                return v or {}
            end
            i = i + 1
        end
    end

    -- #MENU
    -- #MENU
    -- #MENU

    -- Cria a referência ao menu principal do Aimware
    local AW_MENU = gui.Reference("MENU")

    -- Cria a janela principal do Walk Bot na aba "Misc"
    local wb_tab = gui.Tab(gui.Reference("Misc"), "Chicken.WalkBot.tab", "SuperiorWalkBot [Alpha 1.0]")

    -- Cria o Groupbox "Config"
    local wb_config_gb = gui.Groupbox(wb_tab, "Routes", 330, 15, 296, 0)

    -- Cria o Combobox para seleção das configurações do Walk Bot
    local wb_config_selector = gui.Combobox(wb_config_gb, "Chicken.WalkBot.Config.Selection", "Routes", unpack(get_saved_walkbot_names()) or "")
    wb_config_selector:SetOptions(unpack(get_saved_walkbot_names()))
    local wb_config_entry = gui.Editbox(wb_config_gb, "Chicken.WalkBot.Config.name", "Route name")

    -- Cria o botão "Save" para salvar a configuração atual do Walk Bot
    local wb_save_btn = gui.Button(wb_config_gb, "Save Route", function()
        local contents = json.decode(file.Read(file_name))
        if not contents[wb_config_entry:GetValue()] then
            contents[wb_config_entry:GetValue()] = ChickenWalkBot.walk_data
            file.Write(file_name, json.encode(contents))

            local saved_walkbot_names = get_saved_walkbot_names()
            wb_config_selector:SetOptions(unpack(saved_walkbot_names))
            wb_config_selector:SetValue(#saved_walkbot_names - 1)
            wb_config_entry:SetValue("")
        end
    end)
    wb_save_btn:SetPosX(150)

    -- Cria o grupo de configurações do WalkBot
    local wb_settings_gb = gui.Groupbox(wb_tab, "Walkbot", 330, 320, 240, 0)
    local ui_text = {}

    -- Cria o botão para iniciar/parar a reprodução do WalkBot
    local wb_play_btn = gui.Button(wb_settings_gb, "", function()
        ChickenWalkBot.is_playing = not ChickenWalkBot.is_playing
        ChickenWalkBot.is_recording = false

        ui_text.wb_record_text:SetText(ChickenWalkBot.is_recording and "Recording Route" or "Recording Route")
        ui_text.wb_play_text:SetText(ChickenWalkBot.is_playing and "Stop Route" or "Start Route")
    end)
    wb_play_btn:SetPosX(0)

    ui_text.wb_play_text = gui.Text(wb_settings_gb, "Start Route")
    ui_text.wb_play_text:SetPosY(12)
    ui_text.wb_play_text:SetPosX(33)

    -- Cria o botão para iniciar/parar a gravação do WalkBot
    local wb_record_btn = gui.Button(wb_config_gb, "", function()
        ChickenWalkBot.is_recording = not ChickenWalkBot.is_recording
        ChickenWalkBot.is_playing = false

        if ChickenWalkBot.is_recording then
            ChickenWalkBot.walk_data = {}
        end

        ui_text.wb_record_text:SetText(ChickenWalkBot.is_recording and "Stop Recording" or "Start Recording")
        ui_text.wb_play_text:SetText(ChickenWalkBot.is_playing and "Stop Playing" or "Start Route")
    end)
    wb_record_btn:SetPosX(0)
    wb_record_btn:SetPosY(112)
    ui_text.wb_record_text = gui.Text(wb_config_gb, "Start Recording")
    ui_text.wb_record_text:SetPosY(122)
    ui_text.wb_record_text:SetPosX(25)

    -- Cria os sliders para as configurações do WalkBot
    local wb_defualt_speed = gui.Slider(wb_settings_gb, "Chicken.Walkbot.defualtspeed", "Walk Speed", 300, 1, 300)
    local wb_aimbot_speed = gui.Slider(wb_settings_gb, "Chicken.Walkbot.aimbotspeed", "Walk Speed (On Fire)", 300, 1, 300)

    wb_defualt_speed:SetPosX(0) 
    wb_aimbot_speed:SetPosX(0) 


    -- Cria o grupo de configurações do WalkBot
    local wb_teste_gb = gui.Groupbox(wb_tab, "Target", 15, 15, 296, 0)
    local enable_procurarinimigo_checkbox = gui.Checkbox(wb_teste_gb, "misc.custommisc.enable_procurarinimigo", "Enemy", false)
    local enable_procuraraliado_checkbox = gui.Checkbox(wb_teste_gb, "misc.custommisc.enable_procuraraliado", "Ally", false)

    -- Cria o grupo de configurações do WalkBot
    local wb_teste2_gb = gui.Groupbox(wb_tab, "Corrections", 15, 150, 296, 0)
    local enable_corrigirpitch_checkbox = gui.Checkbox(wb_teste2_gb, "misc.custommisc.enable_corrigirpitch", "Pitch", false)
    local enable_auto_jump_checkbox = gui.Checkbox(wb_teste2_gb, "misc.custommisc.enable_auto_jump", "Auto Jump", false)
    wb_teste2_gb:SetPosY(150)

    -- Cria o grupo de configurações do WalkBot
    local wb_teste3_gb = gui.Groupbox(wb_tab, "Auto Buy", 15, 250, 296, 0)
    wb_teste3_gb:SetPosY(420)

    -- Cria o Combobox para seleção do tipo de compra
    local autobuy_selector = gui.Combobox(wb_teste3_gb, "autobuy.selector", "Buy Type", "None", "Rifle", "AWP", "P90")


    -- Cria o grupo de configurações do WalkBot
    local wb_teste4_gb = gui.Groupbox(wb_tab, "Visuals", 15, 250, 296, 0)
    wb_teste4_gb:SetPosY(285)
    local enable_drawline_checkbox = gui.Checkbox(wb_teste4_gb, "misc.custommisc.drawline", "Lines", false)
    local enable_startpoint_checkbox = gui.Checkbox(wb_teste4_gb, "misc.custommisc.startpoint", "Start Point", false)



    -- #INICIALIZAÇÃO DA UI
    -- #INICIALIZAÇÃO DA UI
    -- #INICIALIZAÇÃO DA UI

    -- Variável para armazenar o valor selecionado anteriormente do seletor de configuração
    local Owb_config_selector = -1

    -- Função para atualizar o UI do WalkBot
    function UI_shit()
        wb_tab:SetActive(AW_MENU:IsActive())
        wb_play_btn:SetDisabled(#ChickenWalkBot.walk_data == 0)
        wb_config_selector:SetDisabled(ChickenWalkBot.is_playing)

        if Owb_config_selector ~= wb_config_selector:GetValue() then
            ChickenWalkBot.walk_data = get_saved_walkbot_data(wb_config_selector:GetValue()) or {}
            Owb_config_selector = wb_config_selector:GetValue()
        end

        -- Definindo a largura das colunas
        local column1_width = 296
        local column2_width = 296

        -- Posicionando a primeira coluna
        wb_config_gb:SetPosY(210)
        wb_config_gb:SetWidth(column1_width)
        wb_settings_gb:SetPosY(15)
        wb_settings_gb:SetWidth(column1_width)

    end

    -- #FUNÇÕES
    -- #FUNÇÕES
    -- #FUNÇÕES

    
    -- Função para converter uma tabela para um Vector3
    local function table_to_v3(tbl)
        return Vector3(tbl.x, tbl.y, tbl.z)
    end

    -- Variável para armazenar se existe um alvo no Aimbot
    local has_target = false

    -- Definição dos métodos e propriedades do WalkbotSuperior
    ChickenWalkBot = {
        is_recording = false,
        step_size = 10,
        is_playing = false,
        play_index = 1,
        defualt_speed = 255,
        aimbot_speed = 32,
        walk_data = {},

        record = function(self, pos)
            if self.is_recording and not self.is_playing then
                local my_pos = entities.GetLocalPlayer():GetAbsOrigin()
                if #self.walk_data > 0 then
                    local dist = vector.Distance({self.walk_data[#self.walk_data].x, self.walk_data[#self.walk_data].y, self.walk_data[#self.walk_data].z}, {my_pos.x, my_pos.y, my_pos.z})
                    if dist >= self.step_size - 2 then
                        table.insert(self.walk_data, {x = my_pos.x, y = my_pos.y, z = my_pos.z})
                    end
                else
                    table.insert(self.walk_data, {x = my_pos.x, y = my_pos.y, z = my_pos.z})
                end
            end
        end,

        play = function(self, cmd)
            if self.is_playing and not self.is_recording then
                if self.play_index >= #self.walk_data then
                    self.play_index = 1
                end

                local my_pos = entities.GetLocalPlayer():GetAbsOrigin()
                self.move_to_pos(table_to_v3(self.walk_data[self.play_index]), cmd, has_target and self.aimbot_speed or self.defualt_speed)

                local dist = math.sqrt(math.pow(self.walk_data[self.play_index].x - my_pos.x, 2) + math.pow(self.walk_data[self.play_index].y - my_pos.y, 2))
                if dist <= 10 or dist - (self.walk_data[self.play_index].z - my_pos.z) < 5 then
                    self.play_index = self.play_index + 1
                end
            end
        end,

        get_nearest_point = function(self)
            local closest_dist = math.huge
            local closest_point = nil
            local closest_point_index = 1
            local my_pos = entities.GetLocalPlayer():GetAbsOrigin()

            for i, v in ipairs(self.walk_data) do
                local dist = vector.Distance({v.x, v.y, v.z}, {my_pos.x, my_pos.y, my_pos.z})
                if dist < closest_dist then
                    closest_dist = dist
                    closest_point_index = i
                    closest_point = v
                end
            end

            return closest_point, closest_point_index
        end,

        open = function() end,

        draw = function(self)
            local s_w, s_h = draw.GetScreenSize()
            if #self.walk_data ~= 0 then
                local x, y = client.WorldToScreen(table_to_v3(self.walk_data[1]))
                draw.Color(255, 255, 255)
                --draw.Text(x, y, "Start")

                local circle_radius = 5 -- Raio do círculo
                local circle_color = {255, 255, 255, 255} -- Cor do círculo (verde com transparência)     
                
                if enable_startpoint_checkbox:GetValue() then
                    draw.FilledCircle(x, y, circle_radius)
                end
                
            end

            for i = 1, #self.walk_data do
                if self.walk_data[i + 1] then
                    local x, y = client.WorldToScreen(table_to_v3(self.walk_data[i]))
                    local x2, y2 = client.WorldToScreen(table_to_v3(self.walk_data[i + 1]))
            
                    if enable_drawline_checkbox:GetValue() then     
                        if x and y and x2 and y2 then
                            draw.Color(255, 255, 255)
                            draw.Line(x, y, x2, y2)
                        end             
                    end
                end
            end

            -- draw.Color(255, 255, 255)
            -- if self.is_recording then
            --     draw.Text(15, s_h / 2, "Recording")
            -- elseif self.is_playing then
            --     draw.Text(15, s_h / 2, "Playing")
            -- else
            --     draw.Text(15, s_h / 2, "Idle")
            -- end
        end,

        move_to_pos = function(pos, cmd, speed)
            local LocalPlayer = entities.GetLocalPlayer()
            local angle_to_target = (pos - entities.GetLocalPlayer():GetAbsOrigin()):Angles()
            local my_pos = LocalPlayer:GetAbsOrigin()

            cmd.forwardmove = math.cos(math.rad((engine:GetViewAngles() - angle_to_target).y)) * speed
            cmd.sidemove = math.sin(math.rad((engine:GetViewAngles() - angle_to_target).y)) * speed
        end
    }

    -- Função para fazer o autobuy
    local function doAutobuy()
        local buyType = autobuy_selector:GetValue()

        if buyType == 1 then -- Rifle
            --client.Command("buy ak47; buy m4a1; buy vest; buy vesthelm; buy defuser", true)
            client.Command("buy ak47", true)
        elseif buyType == 2 then -- AWP
            --client.Command("buy awp; buy vest; buy vesthelm; buy defuser", true)
            client.Command("buy awp", true)
        elseif buyType == 3 then -- Sub P90
            --client.Command("buy awp; buy vest; buy vesthelm; buy defuser", true)
            client.Command("buy p90", true)
        end

    end

    -- Função para verificar se o jogador está atrás de uma parede
    local function IsPlayerBehindWall(player)
        local localPlayer = entities.GetLocalPlayer()
        if not localPlayer then
            return false
        end

        local localEyePos = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]")
        local playerEyePos = player:GetAbsOrigin() + player:GetPropVector("localdata", "m_vecViewOffset[0]")

        local traceResult = engine.TraceLine(localEyePos, playerEyePos, 0x46004009) -- 0x46004009 é a máscara para verificar apenas jogadores
        return traceResult.fraction >= 0.9 --valor padrão 1.0
    end

    -- Função para mover suavemente para o inimigo mais próximo
    local function MoveToClosestEnemySmoothly()
        -- Variáveis para ajustar a suavização para inimigos visíveis e ocultos
        local SmoothingFactorVisible = 0.04 -- Quanto menor o valor, mais suave será o movimento para inimigos visíveis
        local SmoothingFactorHidden = 0.02 -- Quanto menor o valor, mais suave será o movimento para inimigos ocultos

        -- Variáveis para ajustar o FOV para inimigos visíveis e ocultos
        local FovVisible = 19.5 -- Quanto maior o valor, maior será o FOV para inimigos visíveis
        local FovHidden = 0.0 -- Quanto menor o valor, menor será o FOV para inimigos ocultos

        local localPlayer = entities.GetLocalPlayer()
        if not localPlayer or not localPlayer:IsAlive() then
            return
        end

        local eyePos = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]")
        local players = entities.FindByClass("CCSPlayer")
        local closestDistance = math.huge
        local closestEnemy = nil
        local IsEnemyBehindWall = false -- Variável para verificar se o inimigo está atrás de uma parede

        -- Verifica se ambas as checkbox estão ativadas
        if enable_procurarinimigo_checkbox:GetValue() and enable_procuraraliado_checkbox:GetValue() then
            -- Código a ser executado quando as duas checkbox estiverem ativadas
            -- Verifica o jogador mais próximo
            for i, enemy in ipairs(players) do
                if enemy:IsPlayer() and enemy:IsAlive() and enemy:GetIndex() ~= localPlayer:GetIndex() then
                    local enemyPos = enemy:GetAbsOrigin()
                    local distance = (eyePos - enemyPos):Length()
            
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end
            -- ...
        elseif enable_procurarinimigo_checkbox:GetValue() then
            -- Código a ser executado apenas quando a checkbox1 estiver ativada
            -- Verifica se o jogador mais próximo é um inimigo
            for i, enemy in ipairs(players) do
                if enemy:IsPlayer() and enemy:IsAlive() and enemy:GetTeamNumber() ~= localPlayer:GetTeamNumber() then
                    local enemyPos = enemy:GetAbsOrigin()
                    local distance = (eyePos - enemyPos):Length()
        
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end 
            -- ...
        elseif enable_procuraraliado_checkbox:GetValue() then
        -- Código a ser executado apenas quando a checkbox2 estiver ativada
        -- Verifica se o jogador mais próximo é um aliado
            for i, enemy in ipairs(players) do
                if enemy:IsPlayer() and enemy:IsAlive() and enemy:GetIndex() ~= localPlayer:GetIndex() then
                    local enemyPos = enemy:GetAbsOrigin()
                    local distance = (eyePos - enemyPos):Length()
            
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end
            -- ...
        end

        if closestEnemy then
            local viewAngles = engine.GetViewAngles()

            -- Verifica se o inimigo está atrás de uma parede
            IsEnemyBehindWall = IsPlayerBehindWall(closestEnemy)

            -- Calcula o ângulo necessário para mirar no inimigo mais próximo apenas horizontalmente
            local delta = closestEnemy:GetAbsOrigin() - eyePos
            local targetYaw = math.deg(math.atan2(delta.y, delta.x))

            -- Seleciona o fator de suavização apropriado com base na visibilidade do inimigo
            local SmoothingFactor = IsEnemyBehindWall and SmoothingFactorVisible or SmoothingFactorHidden
            local FinalFov = IsEnemyBehindWall and FovHidden or FovVisible

            -- Ajusta o ângulo para que fique dentro do intervalo de -180 a 180
            targetYaw = targetYaw - math.floor((targetYaw - viewAngles.yaw + 180) / 360) * 360 + FinalFov

            -- Interpolação suave para evitar movimentos abruptos apenas no ângulo de yaw
            local yawDelta = targetYaw - viewAngles.yaw
            viewAngles.yaw = viewAngles.yaw + yawDelta * SmoothingFactor
            

            local pitchAdjustment = 1
            -- Calcula o ângulo necessário para mirar no inimigo verticalmente
            local targetPitch = 0
            local verticalAimEnabled = true
            if verticalAimEnabled then
                local targetZ = delta.z
                local distanceXY = math.sqrt(delta.x * delta.x + delta.y * delta.y)
                targetPitch = -math.deg(math.atan2(targetZ, distanceXY))
            end

            -- Interpolação suave para evitar movimentos abruptos apenas no ângulo do pitch
            local pitchDelta = targetPitch - viewAngles.pitch

            if IsEnemyBehindWall then
                viewAngles.pitch = viewAngles.pitch +pitchDelta * SmoothingFactor
            end

            -- Mantém o ângulo vertical (pitch) e inclinado (roll) inalterados
            -- para evitar mirar para cima ou para baixo ao mirar no inimigo
            viewAngles.pitch = viewAngles.pitch
            viewAngles.roll = 0

            engine.SetViewAngles(viewAngles)
        end
    end

    local function SmoothPitch()
        local pitchSpeed = 0.1
        local viewAngles = engine.GetViewAngles()

        if viewAngles.pitch > 0 then
            viewAngles.pitch = math.max(viewAngles.pitch - pitchSpeed, 0)
        elseif viewAngles.pitch < 0 then
            viewAngles.pitch = math.min(viewAngles.pitch + pitchSpeed, 0)
        end

        engine.SetViewAngles(viewAngles)
    end

    local function MoveForwardAndControlAngles(cmd)

        local localPlayer = entities.GetLocalPlayer()

        if localPlayer and localPlayer:IsAlive() then
            local velocity = localPlayer:GetPropVector("localdata", "m_vecVelocity[0]")
            local speed = velocity:Length2D()

            if enable_auto_jump_checkbox:GetValue() and speed < 1 then
                cmd.buttons = bit.bor(cmd.buttons, 2)
            end

            if enable_corrigirpitch_checkbox:GetValue() then
                SmoothPitch()
                cmd.pitch = 0
            end

            MoveToClosestEnemySmoothly()
            
        end
    end

    -- #CALLBACKS
    -- #CALLBACKS
    -- #CALLBACKS

    -- Callback para verificar se existe um alvo no Aimbot
    callbacks.Register("AimbotTarget", function(t)
         has_target = t:GetIndex() or false
     end)

    -- Variável para armazenar se o jogador nasceu
    local alive_time = 0
    local me_spawned = false
    local me_spawned_time = globals.CurTime()

    -- Habilita o listener para o evento de spawn de jogador
    client.AllowListener("player_spawn")

    -- Callback para tratar o evento de respawn do jogador e executar o autobuy quando você nascer
   callbacks.Register("FireGameEvent", function(e)
        if e and e:GetName() == "player_spawn" then        
            local dead_guy = client.GetPlayerIndexByUserID(e:GetInt("userid"))
            if client.GetLocalPlayerIndex() == dead_guy then
                alive_time = globals.CurTime()          
                me_spawned = true
                me_spawned_time = globals.CurTime()
                doAutobuy()
            end
        end
    end)

    -- Callback para desenhar o WalkBot e atualizar o UI
    callbacks.Register("Draw", function()

        -- Callback para verificar e ajustar a posição do jogador após o respawn
        if me_spawned and globals.CurTime() > me_spawned_time + 0.5 then
            local _, closest_point_index = ChickenWalkBot:get_nearest_point()
            ChickenWalkBot.play_index = closest_point_index
            me_spawned = false
        end

        ChickenWalkBot.defualt_speed = wb_defualt_speed:GetValue()
        ChickenWalkBot.aimbot_speed = wb_aimbot_speed:GetValue()
        ChickenWalkBot.step_size = 25 --wb_step_size:GetValue()

        local localPlayer = entities.GetLocalPlayer()

        if localPlayer and localPlayer:IsAlive() then
            ChickenWalkBot:record()
            ChickenWalkBot:draw()
        end

        UI_shit()
    end)

    -- Callback para criar o movimento do jogador
    callbacks.Register("CreateMove", "MoveForwardAndControlAngles", MoveForwardAndControlAngles)

    -- Callback para executar o WalkBot
    callbacks.Register("CreateMove", function(cmd)
        ChickenWalkBot:play(cmd)
    end)
    --fim
    --fim
    --fim
    --fim
    --fim
    --fim
    --fim
    --fim
    --fim
 