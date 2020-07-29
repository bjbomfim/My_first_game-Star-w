----- Desenvolvido por Arthur e Alexandre ---------------------

math.randomseed (os.time())
local  w, h = love.graphics.getDimensions ()
local player = {} -- jogador
local enemy = {} -- inimigo
local projetil = {} -- tiro
local tiroduplolista = {}
local tiro = false -- variável que ativará o tiro
local inimigo = true -- variável para verificar se o inimigo morreui
local morto = 1 -- variável que aumenta a velocidade dos inimigos conforme eles vão morrendo e nascendos
local final = {'Não', 'Sim', escapebutton = 2} -- janela perguntando se o jogador quer ou não jogar novamente após o game over
local pontos =  0 --pontuação
local back --foto de fundo
local fotoplayer -- foto jogador
local fotoinimigo -- foto inimigo
local fototiroduplo --foto tiroduplo
local jogar = false --booleano para mantem o menu
local gera = true --booleano para gerar inimigos
local vida = 100 --vidas do jogador
local tiroduplo = false
local quadtiroduplo = {}
local quedaquad = false
local audiofase


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇOES NOSSAS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local function gera_jogador()
  local largura_player = w / 12
  local altura_player = h / 9
  local x_player = w/2 - largura_player/2
  local y_player = h - (altura_player * 1.125) 
  local velocidade = 450
  table.insert (player, {x = x_player, y = y_player, a = altura_player, l = largura_player, v = velocidade, foto = fotoplayer} )
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function gera_inimigo ()
  local largura_enemy = w / 16
  local altura_enemy = h / 12
  local x_enemy = math.random (largura_enemy * 1.125, w - largura_enemy * 1.125) 
  local y_enemy = 0
  local velocidade = 160 * morto
  table.insert (enemy, {x = x_enemy, y = y_enemy, a = altura_enemy, l = largura_enemy, v = velocidade, foto = fotoinimigo} )
  inimigo = true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function gera_tiroduplo()
  local tempoqueda = math.random(4, 12)
  local larg = 30
  local alt = 30
  local x = math.random(0, w-larg)
  local y = 0-alt
  table.insert(quadtiroduplo, {x = x, y = y, l = larg, a = alt, t = tempoqueda, t2 = tempoqueda, foto = fototiroduplo})
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function drawall()
  --jogador
  love.graphics.draw(player[1].foto, player[1].x, player[1].y)
  --inimigo
  for i = 1, #enemy do
    if inimigo then
      love.graphics.setColor(1,1,1)
      love.graphics.draw(enemy[i].foto, enemy[i].x, enemy[i].y)
    end
  end
  --validação do tiro duplo
  for i = 1, #quadtiroduplo do
    if quedaquad then
      love.graphics.draw(quadtiroduplo[i].foto, quadtiroduplo[i].x, quadtiroduplo[i].y)
    end
  end
  --projetil
  if tiro == true then
    for i = 1, #projetil do
      love.graphics.line (projetil[i].x, projetil[i].y, projetil[i].xf, projetil[i].yf)
    end
  end
  -- segundo projetil
  if tiroduplo then
    for i = 1, #tiroduplolista do  
      love.graphics.line (tiroduplolista[i].x, tiroduplolista[i].y, tiroduplolista[i].xf, tiroduplolista[i].yf)
    end
  end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function gatilho ()
  local x_projetil = player[1].x + player[1].l/2 
  local y_projetil = player[1].y
  local x_final = x_projetil
  local y_final = y_projetil - 24
  local velocidade = 560
  if tiroduplo then
    for i = #tiroduplolista, 1 -1 do
      table.remove(tiroduplolista, i)
    end
    table.insert(tiroduplolista, {x = x_projetil - 20, y = y_projetil, xf = x_final - 20, yf = y_final, v = velocidade})
  end
  table.insert (projetil, {x = x_projetil, y = y_projetil, xf = x_final, yf = y_final, v = velocidade} )
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function atira () -- verifica a colisão do projetil com o inimigo
  for i = #projetil, 1, -1 do
    for j = #enemy, 1, -1 do
      if projetil[i].yf <= enemy[j].y + enemy[j].a and projetil[i].yf >= enemy[j].y and projetil[i].xf >= enemy[j].x and projetil[i].xf <= (enemy[j].x + enemy[j].l) then
        table.remove (enemy, j)
        table.remove (projetil, i)
        inimigo = false
        morto = morto + 0.1
        if morto >= 1.5 then
          morto = 1.5
        elseif pontos >= 800 then
          morto = 2
        end
        pontos = pontos + 10
      end
    end
  end
  if tiroduplo then
    for i = #tiroduplolista, 1, -1 do
      for j = #enemy, 1, -1 do
        if tiroduplolista[i].yf <= enemy[j].y + enemy[j].a and tiroduplolista[i].yf >= enemy[j].y and tiroduplolista[i].xf >= enemy[j].x and tiroduplolista[i].xf <= (enemy[j].x + enemy[j].l) then
          table.remove (enemy, j)
          table.remove (tiroduplolista, i)
          inimigo = false
          morto = morto + 0.1
          if morto >= 1.5 then
            morto = 1.5
          elseif pontos >= 800 then
            morto = 2
          end
          pontos = pontos + 10
        end
      end
    end
  end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function remove ()
-- remove o projetil caso ele acerte a parede (h = 0)
  for i = #projetil, 1, -1 do
    if projetil[i].yf <= 0 then
      table.remove (projetil, i)
    end
  end
  if tiroduplo then
    for i = #tiroduplolista, 1, -1 do
      if tiroduplolista[i].yf <= 0 then
        table.remove (tiroduplolista, i)
      end
    end
  end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function verifica_tiroduplo() -- verifica se o player pegou o tiroduplo
  for i = #quadtiroduplo, 1, -1 do
    if ((quadtiroduplo[i].x >= player[1].x and quadtiroduplo[i].x + quadtiroduplo[i].l <= player[1].x + player[1].l) or (quadtiroduplo[i].x <= player[1].x and quadtiroduplo[i].x + quadtiroduplo[i].l >= player[1].x) or (quadtiroduplo[i].x <= player[1].x + player[1].l and quadtiroduplo[i].x + quadtiroduplo[i].l >= player[1].x + player[1].l)) and quadtiroduplo[i].y >= player[1].y then
      quedaquad = false
      table.remove(quadtiroduplo, i)
      tiroduplo = true
    elseif quadtiroduplo[i].y >= h then
      table.remove(quadtiroduplo, i)
      quedaquad = false
      gera_tiroduplo()
    end
  end
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DO LOVE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function love.load ()
  love.window.setTitle("Flight of the Falcon")
  fontemenu = love.graphics.newFont("fontes/star_jedi/starjedi/Starjedi.ttf", 60)
  textomenu = love.graphics.newText(fontemenu, "")
  fontemenu2 = love.graphics.newFont("fontes/starwars_kit/StarWars.ttf", 60)
  textomenu2 = love.graphics.newText(fontemenu2, "")
  fontepontos = love.graphics.newFont("fontes/star_jedi/starjedi/Starjedi.ttf", 15)
  textopontos = love.graphics.newText(fontepontos, "")
  textomenu3 = love.graphics.newText(fontepontos, "")
  back = love.graphics.newImage("fotos/background.png")
  fotoinimigo = love.graphics.newImage("fotos/tie_fighter.png")
  fotoplayer = love.graphics.newImage("fotos/millenium_falcon.png")
  fototiroduplo = love.graphics.newImage("fotos/orb2.png")
  audiomenu = love.audio.newSource("audios/musica_menu.mp3","static")
  audiofase = love.audio.newSource("audios/musica_boss.mp3", 'static')
  love.keyboard.setKeyRepeat(true)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function love.draw ()
  if jogar then -- altera entre o jogo e o menu
    if gera then -- gera os inimigos apenas uma vez
      gera_jogador()
      gera_inimigo ()
      gera_tiroduplo()
      gera = false
    end
    audiomenu:stop()
    audiofase:play()
    love.graphics.draw(back, 0,0)
    textopontos :set (string.format('Pontos:%s\nHP:%s',pontos, vida))
    love.graphics.draw(textopontos, 0, 0)
    drawall()
  else
    textomenu :set (string.format('StarWars'))
    love.graphics.rectangle('line', (w-425)/2, (h-200)/2, 400, 100)
    love.graphics.draw(textomenu, (w-350)/2, (h-200)/2)
    textomenu2 :set (string.format('{ f ^ D _'))
    textomenu3:set(string.format('Press Enter'))
    love.graphics.draw(textomenu2, (w-450)/2, (h-400)/2)
    love.graphics.draw(textomenu3, (w-150)/2, h/2)
  end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function love.keypressed (k)  
  --ativação do projetil
  if k == "up" then
    tiro = true
    gatilho ()
  end
  --inicia o jogo
  if k == "return" then
    jogar = true
  end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function love.update(dt)
  -- deslocamento do jogador
  if jogar then
    if love.keyboard.isDown( "a" ) then
      if player[1].x > 17.4 then
        player[1].x = (player[1].x - player[1].v * dt)
      end
    elseif love.keyboard.isDown( "d" ) then 
      if player[1].x < w - player[1].l * 1.125 then
        player[1].x = (player[1].x + player[1].v * dt)
      end
    end
  end
  --deslocamento do projetil
  for i = #projetil, 1, -1 do
    if tiro == true then
      projetil[i].y = projetil[i].y - projetil[i].v * dt 
      projetil[i].yf = projetil[i].yf - projetil[i].v * dt
      if inimigo then
        atira ()
      end
    end
  end
  if tiroduplo then
    for i = #tiroduplolista, 1, -1 do
      tiroduplolista[i].y = tiroduplolista[i].y - tiroduplolista[i].v * dt
      tiroduplolista[i].yf = tiroduplolista[i].yf - tiroduplolista[i].v * dt
      if inimigo then
        atira ()
      end
    end
  end
  --deslocamento do inimigo
  for i = 1, #enemy do
    enemy[i].y = enemy[i].y + enemy[i].v * dt
  end
  --geração de um novo inimigo após a morte do anterior
  if not inimigo then
    gera_inimigo ()
  end
  --verifica se você perdeu o jogo
  for i = #enemy, 1, -1 do
    if enemy[i].y >= h or (enemy[i].y + enemy[i].a >= player[1].y and enemy[i].x >= player[1].x and enemy[i].x <= (player[1].x + player[1].l)) then
      vida = vida - 25
      table.remove (enemy, i)
      gera_inimigo ()
      if tiroduplo then
        tiroduplo = false
        quedaquad = false
        table.remove(quadtiroduplo, 1)
        gera_tiroduplo()
      end
      if vida == 0 then
        audiofase: stop()
        local clicado = love.window.showMessageBox('GAME OVER', 'Quer jogar outra partida?', final)
        if clicado == 1 then
          love.event.quit()
        end
        if clicado == 2 then
          love.event.quit('restart')
        end
      end
    end
  end
  --deslocamento da validação do tiro duplo
  for i = #quadtiroduplo, 1, -1 do
    quadtiroduplo[i].t2 = quadtiroduplo[i].t2 - dt
    if quadtiroduplo[i].t2 <= 0 and quedaquad == false then
      quedaquad = true
      quadtiroduplo[i].t2 = quadtiroduplo[i].t
    end
    if quedaquad then
      quadtiroduplo[i].y = quadtiroduplo[i].y + 5
      verifica_tiroduplo()
    end
  end
  if not jogar then
    audiomenu:play()
  end
  --verifica se o projetil acertou a parede
  remove ()
end

  
----------------------------------------------------------------------- FIM ------------------------------------------------------------------------------

