  generate_maps = require("generate_maps")
  all_heros 	= require("all_heros")
  
  mapTilesX = 400  -- TODO эти переменные будут разными для каждой карты
  mapTilesY = 400
  
  MAX_SPEED=15 -- нужно ли?

  
  local 
  tilesIm,
  icoMons1,
  icoMons2,
  spGex,
  curGex, 
  foeGex, 

  her_lst, -- список всех героев
  
  objc_arr,
  spd_arr,  
  
  LOGGER, -- логер  
  curStatus,
  
  curX, -- номер верхнего левого тайла
  curY,

  tilesX, -- количество тайлов на экране
  tilesY,  
  curGexX, -- выбранный ЛКМ тайл
  curGexY,
  timermouseCurGexVar,
	
  -- TODO эти переменные нужно будет загружать из файла
  scale, -- масштаб: 1 - самое близкое, 2 - дальше, 3 - еще дальше
  curTime,
  curTimeSpeed,  -- текущее игровое время и скорость промотки
  turnIS,
  curTurn,
  curPlayer=1, --игрок
  main_gameI,
  
  numHeros, -- номер общего кол-ва героев для her_lst

  heroWay, -- TODO сделать локальными	
  xyWay

function love.load()
  loader = require("loader")
  tilesIm = loader:load_assets('assets/tiles')
  
  --for i = -1, 13 do -- массив рисунков -- этот код не удалять, может будем использовать
  --  tilesIm[i] = love.graphics.newImage("assets/tiles/"..tostring(i)..".png")
  --end  
  
  
  icoMons1 = love.graphics.newImage("assets/icomons1.png") -- TODO выгружать иконки в массив
  icoMons2 = love.graphics.newImage("assets/icomons2.png") 
  icoicoMons1 = love.graphics.newImage("assets/icoicomons1.png")

  curGex = love.graphics.newImage("assets/gex.png")
  spGex = love.graphics.newImage("assets/speed.png")
  foeGex = love.graphics.newImage("assets/foe.png")
  wayGex = love.graphics.newImage("assets/way.png")

  imageDataIco = love.image.newImageData("assets/gameIco.png")
  imageDataCurs = love.image.newImageData("assets/gameCurs.png")

  love.window.setFullscreen(true, "desktop")
  love.window.setTitle("Hero of Reland v. 0.07")
  love.window.setIcon(imageDataIco)
  cursor = love.mouse.newCursor(imageDataCurs, 0, 0) --
  love.mouse.setCursor(cursor) -- TODO разные курсоры

  love.mouse.setVisible(true)
  
  intro()
  --menu()  
  init()
end

function calculate_tilesXtilesY()
  tilesX = math.ceil(widthScreen  / ((120+60)/2/ scale)) - 1
  tilesY = math.ceil(heightScreen / (60 / scale)) - 1
  
  tilesLenX = (120 + 60) / 2 * tilesX / scale
  tilesLenY = 60 * tilesX / scale 
end

function init()
  LOGGER = "Init"
  curStatus = 0
  
  time = require("time")
  mouse = require("mouse")
  gameTime()  
  
  curTurn=0
  main_gameI=0 
  turnIS = curPlayer -- 1 - ход игрока, остальные значения остальные игроки или ИИ 
  
  scale = 2 
  curGexX = -2 
  curGexY = -2

  curHero = 0

  widthScreen = love.graphics.getWidth()
  heightScreen = love.graphics.getHeight()

  calculate_tilesXtilesY()

  generate_maps:generate()  -- тестовый генератор мира

  objc_arr = {}
  for i = 0, mapTilesX do -- 0 - объекта нет, любое другое число - номер объекта
    objc_arr[i] = {}
    for j = 0, mapTilesY do
      objc_arr[i][j] = 0
    end
  end

  spd_arr = {}
  for i = 1, mapTilesX-1 do 
    spd_arr[i] = {}
    for j = 1, mapTilesY-1 do
      spd_arr[i][j] = 100
    end
  end
  
  -- тестовая часть с мобами  
  her_lst={}
	
  testHero={}
  all_heros.createMinos(testHero) 
  her_lst[1] = testHero
  her_lst[1].own = curPlayer -- владелец тестового героя -- игрок
  her_lst[1].ico = icoMons1
  
  
  testMob={}
  all_heros.createSprout(testMob)  
  her_lst[2] = testMob 
  her_lst[2].own = 2 -- владелец тестового моба - игрок 2, в данном случае ИИ
  her_lst[2].ico = icoMons2  
  -- 
  numHeros=#her_lst
end

function main_game() -- главный игровой цикл, тоже пока в тесте


    -- тестовый режим с расположением героя и моба
	if main_gameI==0 then
		x=0
		y=0
		i=0
	    for i = 0, 666 do
		  x=love.math.random(2, mapTilesX-2)
		  y=love.math.random(2, mapTilesY-2)
		  if LM[x][y]~="water" and LM[x][y]~="water1" then			
			i=999
			break
		  end
		end  
		if i==999 then
			for x = 2, mapTilesX-2 do
				for y = 2, mapTilesY-2 do
				  if LM[x][y]~="water" and LM[x][y]~="water1" then
					break
				  end
				end
			end 
		end 
		her_lst[1].x = x -- координаты героя
		her_lst[1].y = y
		
		her_lst[2].x = x+1 -- координаты моба
		her_lst[2].y = y+1

		centerTile(x, y)
	end
	main_gameI = main_gameI + 1
end

function love.update(dt)
  mouseX = love.mouse.getX()  -- получить координаты мыши х и у
  mouseY = love.mouse.getY()

  mouse_move()
  
  calculate_tilesXtilesY()
  
  main_game()
end

function mouse_move() 
--  LOGGER = "mouse_move"
--  curStatus = 0

  side = mouse:get_map_scrool_side(scale, widthScreen, heightScreen)

  if side == 0 then -- если курсор в центре
    timermouse = 0 -- то обнуляем таймеры
    timermouse2 = 0
    lastScroolSide = 0 --lastScroolSide содержит в себе сторону, в которую карта крутилась последний раз с помощью мыши.

  elseif side ~= lastScroolSide then    -- иначе если мышка переместилась на край
    lastScroolSide = side -- обновляем, куда последний раз мы крутились
    timermouse = love.timer.getTime() -- счетчик времени, пока курсор мыши на этом краю
    timermouse2 = 0 -- будет первое перемещение
  end

  if love.timer.getTime() - timermouse > 0.5 then -- если мышь находится в области перемещения больше определенного значения
    if timermouse2 == 0 or love.timer.getTime() - timermouse2 >= 0.1 then -- если после перемещения прошло 0.12 с или это первое перемещение
      move_map(side, scale) -- переместить в сторону соответсвующей области перемещения
      timermouse2 = love.timer.getTime() -- счетчик времени после начала перемещения
    end
  end
  curStatus = side  
end

function move_map(side, k) -- перемещение карты
  local tmpX, tmpY
  if side == 1 then
    tmpX = curX - k
    curX = tmpX > 0 and tmpX or 0
    tmpY = curY + k
    curY = tmpY < mapTilesY - tilesX and tmpY or mapTilesY - tilesX
  elseif side == 3 then -- для scale= 2
    tmpX = curX + k
    curX = tmpX < mapTilesX - tilesX and tmpX or  mapTilesX - tilesX
    tmpY = curY + k
    curY = tmpY < mapTilesY - tilesX and tmpY or mapTilesY - tilesX
  elseif side == 7 then
    tmpX = curX - k
    curX = tmpX > 0 and tmpX or 0
    tmpY = curY - k
    curY = tmpY > 0 and tmpY or 0
  elseif side == 9 then
    tmpX = curX + k
    curX = tmpX < mapTilesX - tilesX and tmpX or  mapTilesX - tilesX
    tmpY = curY - k
    curY = tmpY > 0 and tmpY or 0
  elseif side == 2 then
    tmpY = curY + k
    curY = tmpY < mapTilesY - tilesX and tmpY or mapTilesY - tilesX
  elseif side == 4 then
    tmpX = curX - k
    curX = tmpX > 0 and tmpX or 0
  elseif side == 6 then
    tmpX = curX + k
    curX = tmpX < mapTilesX - tilesX and tmpX or  mapTilesX - tilesX
  elseif side == 8 then
    tmpY = curY - k
    curY = tmpY > 0 and tmpY or 0
  end
end

function love.keypressed(key) -- обработчик клавиатуры
  if key == "up" then
    move_map(8, scale)
  elseif key == "down" then
    move_map(2, scale)
  elseif key == "left" then
    move_map(4, scale)
  elseif key == "right" then
    move_map(6, scale)
  elseif key == "space" then
    curTime:inc(0, 10)
	endTurn()
  elseif key == "escape" then
    love.event.quit()
  end
end

function endTurn()	-- TODO тут будет изменяться значение turnIS, чей ход и все в таком духе.
	-- здесь будет передаваться ход следующему игроку
	-- TODO это нужно для всех героев!
	-- сброс скорости только для героев походившего игрока
	her_lst[1].curSpd=her_lst[1].modSpd
	her_lst[1].curAct=her_lst[1].modAct	
	curTurn=curTurn+1
	curHero=0 -- ?FIX? для теста будет так пока
	drawIFace()
end

function love.draw()
 drawIFace()
end

function drawIFace() -- рисуем интерфейс
  drawLM()
  drawMM()
end



function load_maps() -- загрузка карт. пока не используется
-- тут мы будем загружать обе карты
	f = io.open(arg[1].."\\GM.txt","r"); -- TODO проверку на ОС. если линух , то  arg[0]
	for line in f:lines() do
		message(tostring(line));
		--line в строку
		-- строку в массив
	end
	
	--GM
	f:close();   -- Закрывает файл	
end



function drawMM() 	-- отрисовать МиниМапу
  scale1D = 1 / scale
  sizeMMx=390 	 -- TODO size?
  sizeMMy=390
  x_win=love.graphics.getWidth()*8/10-- TODO изменить координаты
  y_win=love.graphics.getHeight()*6/10+30
  
  love.graphics.setColor(0, 0, 210, 255)
  love.graphics.rectangle("fill", x_win, y_win, sizeMMx-10, sizeMMy-10) -- рисуем океан

  maps = {}
  a=0
  love.graphics.setColor(0, 210, 0, 255) -- рисуем землю  
 	for i = 0, mapTilesY/4-1 do
		for j = 0, mapTilesX/4-1 do
			if GM[i][j] == 1 then		-- если земля, то зеленая
				maps[a]={x_win+i*4, 	 y_win+j*4}
				a=a+1				
				maps[a]={x_win+i*4+1,	 y_win+j*4}
				a=a+1				
				maps[a]={x_win+i*4,		 y_win+j*4+1}
				a=a+1				
				maps[a]={x_win+i*4+1,	 y_win+j*4+1}
				a=a+1				
			end
		end		
	end	 
  love.graphics.points(maps)  
  love.graphics.setColor(255, 255, 255, 255)	-- белый квадрат окна
  love.graphics.rectangle("line",x_win + curX, y_win + curY, sizeMMx/100*scale*4, sizeMMy/100*scale*4)
  
  love.graphics.setColor(255, 255, 255, 255)  
  
  drawingImage = icoicoMons1	-- здесь рисуем иконку героя
  love.graphics.draw(drawingImage, x_win + her_lst[1].x-10, y_win + her_lst[1].y-10, 0, 1/2, 1/2, 0, 0)  
  
end

function drawLM() -- отрисовка локальной карты
  lenT = math.floor(90 / scale)
  wigT = math.floor(60 / scale)
  wigTD2 = math.floor(30 / scale)
  scale1D = 1 / scale

	if scale >= 1 and scale <= 4 then -- тайлы карты
		for i = curX, curX + tilesX - 1 do -- i - столбец. j - строка
			for j = curY, curY + tilesY - 1 do
			drawingImage = tilesIm[LM[i][j]]
			offset = 0
			if string.sub(LM[i][j], 0, 1)=='_'  then-- смещение из-за двойных тайлов
				offset=wigT
			end
			if i % 2 == 1 then -- нечетный столбец, то смещаем вниз
				love.graphics.draw(drawingImage, (i - curX) * lenT, (j - curY) * wigT + wigTD2-offset, 0, scale1D, scale1D, 0, 0)
				--love.graphics.print(i.."."..j, (i - curX) * lenT, (j - curY) * wigT + wigTD2)
			elseif i % 2 == 0 then -- четный столбец или нулевой, то без смещения
				love.graphics.draw(drawingImage, (i - curX) * lenT, (j - curY) * wigT-offset, 0, scale1D, scale1D, 0, 0)
				--love.graphics.print(i.."."..j, (i - curX) * lenT, (j - curY) * wigT)
			end
		end
    end

    -- объекты

	-- исследованная часть карты

    -- туман войны

  fog_arr = {} -- инициализация
  for i = 0, tilesX do
    fog_arr[i] = {}
    for j = 0, tilesY do
      fog_arr[i][j] = false -- false - нет видимости, true - есть
    end
  end
  -- любой перс игрока дает видимость вокруг себя на значение его heroSigth

  -- тут должен быть цикл с перебором всех персонажей игрока
  
  -- если персонаж находится на холме
	--  увеличивает heroSigth=heroSigth+1
   -- если персонаж находится на горе
	--  увеличичвает heroSigth=heroSigth+2

  -- лес частично препятствуют видимости. следующую клетку за лесом видно, если мы стоим на холме, то следующие 2 клетки, если на горе , то 3 клетки.
  
  -- холмы и горы полностью препятствуют видимости.

    -- выделенный тайл
    if curGexX ~= -2 and curGexY ~= -2 then
	  offset=0
      if curGexX % 2 == 1 then        -- co смещением
	    offset=wigTD2
	  end
      love.graphics.draw(curGex, (curGexX - curX) * lenT, (curGexY - curY) * wigT + offset, 0, scale1D, scale1D, 0, 0)
    end

	
	-- TODO ограничение по карте выводимой на экране
    if curHero ~= 0 and curGexX ~= -2 and curGexY ~= -2 then     -- тайлы доступные для перемещения
		if her_lst[curHero].own == curPlayer then
			for a = 1, mapTilesX-1 do
				for b = 1, mapTilesY-1 do	
					if spd_arr[a][b]>0 and spd_arr[a][b]<=her_lst[curHero].curSpd and spd_arr[a][b]~=100 then
						x=(a-curX)				-- координаты вывода картинки
						y=(b-curY)

						if a % 2 == 1 then			 -- смещение из-за гексагональной сетки - это нужно
							y=y	 + 0.5				
						end
														
						
						--LOGGER= "x: "..x.."  y: "..y
						if x >= 0 and x <= tilesX  and y >= 0 and y < tilesY or y==tilesY and x%2==0 or y==tilesY and curX%2==0  then -- ограничение карты TODO FIX тут бага!
							love.graphics.draw(spGex,  x* lenT,  y* wigT, 0, scale1D, scale1D, 0, 0)
							if scale<4 then
								love.graphics.print(a.."."..b, 		 (x+0.6)* lenT, (y + 0.6)* wigT)
								love.graphics.print(spd_arr[a][b], (x+0.6)* lenT, (y + 0.3)* wigT)		
							end					
						end	
					end
				end
			end
		end
    end
	
	--[[ путь
    if heroWay~=nil then
	  for i=0, #heroWay do
		  offset=0
		  if heroWay[i].x % 2 == 1 then        -- co смещением
			offset=wigTD2
		  end
		  love.graphics.draw(wayGex, (heroWay[i].x - curX) * lenT, (heroWay[i].y - curY) * wigT + offset, 0, scale1D, scale1D, 0, 0)
	  end
    end	--]]
	
	
	for i = 1, numHeros do -- рисуем героев
		if her_lst[i].x>=curX and her_lst[i].x<=curX+tilesX and her_lst[i].y>=curY and her_lst[i].y<=curY+tilesY then
			offset=0
			if her_lst[i].x % 2 == 1 then -- нечетный столбец, смещаем вниз 
				offset= wigTD2
			end
			
			love.graphics.draw(her_lst[i].ico,(her_lst[i].x - curX) * lenT + 25 / scale,(her_lst[i].y - curY) * wigT + offset, 0,scale1D,scale1D,0,0)
		end	
	end
	
  end

  _printValue("Scale",   scale, 1) -- псевдо логгер
  _printValue("TilesX",  tilesX, 2)
  _printValue("TilesY",  tilesY, 3)
  _printValue("CurX",    curX, 4)
  _printValue("CurY",    curY, 5)
  _printValue("CurGexX", curGexX, 6)
  _printValue("CurGexY", curGexY, 7)
  _printValue("MouseX",  love.mouse.getX(), 8)
  _printValue("MouseY",  love.mouse.getY(), 9)
  _printValue("curHero", curHero, 10)
  _printValue("curAct",   her_lst[1].curAct, 11)
  _printValue("curSpd",   her_lst[1].curSpd, 12)
  _printValue("curTurn", curTurn, 13) 
  _printLOGGER(LOGGER, LOGGER, 14)
  --_printLog(LOGGER, curStatus)
  
  _printTime()

end
function _printLOGGER(nameVal, val, n)-- псевдо логгер
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.print(val, 20,20)

  love.graphics.setColor(255, 255, 255, 255)
end

function _printValue(nameVal, val, n)-- псевдо логгер
  love.graphics.setColor(255, 0, 0, 255)
  if nameVal~="-3" then
	love.graphics.print(nameVal, love.graphics.getWidth() - 200, (n - 1) * 20)
  end
  if val~=-3 then
	love.graphics.print(val, love.graphics.getWidth() - 150, (n - 1) * 20)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function _printLog(nameFun, status)-- псевдо логгер
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.print(nameFun, love.graphics.getWidth() - 200, love.graphics.getHeight() - 300)
  love.graphics.print(status, love.graphics.getWidth() - 100, love.graphics.getHeight() - 300)
  love.graphics.setColor(255, 255, 255, 255)
end

function _printTime()-- Вывод времени
  -- TODO засечь секунду, если она прошла ,моргнуть :
  love.graphics.setColor(0, 255, 0, 200)
  local hour, min = curTime.get()
  love.graphics.print(string.format("%02d", hour), love.graphics.getWidth() - 100, love.graphics.getHeight() - 25)
  love.graphics.print(":", love.graphics.getWidth() - 80, love.graphics.getHeight() - 25)
  love.graphics.print(string.format("%02d", min), love.graphics.getWidth() - 75, love.graphics.getHeight() - 25)
  if hour == 4 then
    love.graphics.print("Sunrise", love.graphics.getWidth() - 100, love.graphics.getHeight() - 15)
  elseif hour == 12 then
    love.graphics.print("Noon", love.graphics.getWidth() - 100, love.graphics.getHeight() - 15)
  elseif hour == 18 then
    love.graphics.print("Sunset", love.graphics.getWidth() - 100, love.graphics.getHeight() - 15)
  elseif hour == 0 then
    love.graphics.print("Midnight", love.graphics.getWidth() - 100, love.graphics.getHeight() - 15)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

function intro()
  --widthScreen = love.graphics.getWidth()
  --heightScreen = love.graphics.getHeight()

--  intro = love.audio.newSatomurce("assets/intro.mp3", "stream")
--  love.audio.play(intro) atom- music
  --[[
	for i=0, 1000 do
		if love.keyboard.isDownatom)==false or love.mousepressed()==false then -- если пользователь ничего не нажал
			--love.timer.sleep(1)atom
			love.graphics.draw(gameArt, widthScreen / 2 - gameArt:getWidth() / 2, heightScreen / 2 - gameArt:getHeight() / 2)
		elseif love.keyboard.isDown()==true or love.mousepressed()==true then
			i=1000
		end
	end
	love.graphics.setBackgroundColor(0, 0, 0)
	
	--]]

  --! курсор невидим. после это функции виден.+ на экране загрузки его нет.
  --		love.graphics.draw(anim1, widthScreen/2 - anim1:getWidth()/2, heightScreen/2 - anim1:getHeight()/2)
  -- ничего не происходит
  -- Если нажал черный фон - дальше
end

function centerTile(tileX, tileY) -- функция центровки карты по координатам
  local tmpX, tmpY
  tmpX = tileX - math.floor(tilesX/2)
  if tmpX < 0 then
    curX = 0
  elseif tmpX > (mapTilesX - tilesX) then
    curX = mapTilesX - tilesX
  else
    curX = tmpX
  end
  tmpY = tileY - math.floor(tilesX/2)
  if tmpY < 0 then
    curY = 0
  elseif tmpY > (mapTilesY - tilesX) then
    curY = mapTilesY - tilesX
  else
    curY = tmpY
  end
end

function love.wheelmoved(x, y)
  local Gx, Gy, tmpX, tmpY
  Gx, Gy = whatGex() -- координаты гекса над которым курсор
  if mouse:mouse_in_map(mouseX, mouseY, tilesLenX, tilesLenY) and Gx ~= -2 and Gy ~= -2 then
    -- если курсор в карте и у нас есть координаты гекса
    tmpScale = scale
    if y > 0 and scale ~= 4 and scale > 1 then -- then add min and max scale
          text = "Mouse wheel moved up"
      scale = scale - 1
    elseif y <0 and scale ~= 2 and scale < 4 then
      scale = scale + 1
      text = "Mouse wheel moved down"
    elseif y <0 and scale == 2 then
      scale = 4		
      text = "Mouse wheel moved down"
    elseif y >0 and scale == 4 then
      scale = 2	
      text = "Mouse wheel moved up"
    end

    if scale ~= tmpScale then
      calculate_tilesXtilesY()
      centerTile(Gx, Gy)
    end
  end
end


function findArgHeroOnXY(xi, yi, arg)
	-- проходим список всех героев ищем нужного с совпадающими координатами -- TODO? нужно ли оптимизировать алгоритмом поиска?
	for i=1, numHeros do	
		for x, numHeros in pairs(her_lst[i]) do
			for y, numHeros in pairs(her_lst[i]) do
				if her_lst[i].x==xi and her_lst[i].y==yi  then
					return her_lst[i][arg]
				end
			end
		end
	end
	return 0
end

function findNumHeroOnXY(xi, yi) -- номер героя с карты
	for i=1, numHeros do	
		for x, numHeros in pairs(her_lst[i]) do
			for y, numHeros in pairs(her_lst[i]) do
				if her_lst[i].x==xi and her_lst[i].y==yi  then
					return i
				end
			end
		end
	end
	return 0
end

function move_hero( movetoGexX, movetoGexY, attackFoe)

	-- TODO пусть проверки на скорость и действия будут тут
	
	gexCount = findWay(her_lst[curHero].x,her_lst[curHero].y, movetoGexX, movetoGexY)-- получить восстановленный путь в виде массива
if gexCount==0 then -- FIX нужна ли ?
	if attackFoe == true then
		lastGex = 1-- дойти до предпоследней клетки
	else
		lastGex = 0-- иначе до последней	
	end

	-- для блинка другое правило передвижения
	if her_lst[curHero].rules:find("blink") ~= nil then 
		her_lst[curHero].curSpd = her_lst[curHero].curSpd - gexCount + lastGex					
		her_lst[curHero].x, her_lst[curHero].y = heroWay[lastGex].x, heroWay[lastGex].y	

	-- обычное перемещение
	else 	
		for idx = gexCount, lastGex, -1  do 								
			her_lst[curHero].curSpd = her_lst[curHero].curSpd - spd_arr[heroWay[gexCount-idx].x][heroWay[gexCount-idx].y]
			her_lst[curHero].x, her_lst[curHero].y = heroWay[idx].x, heroWay[idx].y--Передвинуть на след. гекс
		end	
	end
	
	-- правило "свободный шаг" - можно двигаться дальше после мува еще 1 раз
	if her_lst[curHero].rules:find("freemove") ~= nil then 
		if her_lst[curHero].rules:find("startFM") ~= nil then 
			her_lst[curHero].rules = string.gsub(her_lst[curHero].rules, "startFM", "")							
		else
			her_lst[curHero].curAct = her_lst[curHero].curAct-1
			her_lst[curHero].rules  = her_lst[curHero].rules.."startFM" -- добавить правило "startFM"
		end

	-- правило "свободный бег" - можно двигаться дальше после мува сколько угодно раз
	elseif her_lst[curHero].rules:find("freerun") ~= nil then 
		if her_lst[curHero].rules:find("startFM") ~= nil then 
			if her_lst[curHero].curSpd == 0 then
				her_lst[curHero].rules = string.gsub(her_lst[curHero].rules, "startFM", "")	
			end
		else
			her_lst[curHero].curAct = her_lst[curHero].curAct-1
			her_lst[curHero].rules  = her_lst[curHero].rules.."startFM" -- добавить правило "startFM"
		end		
	else
	
	-- передвижение без правилa "свободный бег"
		her_lst[curHero].curSpd = 0 
		her_lst[curHero].curAct = her_lst[curHero].curAct-1	
	end
	curGexX, curGexY = movetoGexX, movetoGexY
end
end

function love.mousepressed( x, y, button, istouch, presses )
  gexCountSpeed = 0

  if button == 1 then
--    LOGGER = "mousepressed_l"
	if presses==2 then
		LOGGER= "D_LKM"
	end

    if scale >= 1 and scale <= 4 then    -- проверка по окнам
      if mouseX < tilesLenX and mouseY < tilesLenY then -- если карта
        curGexX, curGexY = whatGex()
		-- TODO обработка: если щелкаем второй раз - через короткое время = двойной ЛКМ
        -- TODO через длительное время = сброс curGexVar=0
        -- если двойной щелчок -- открыть окно Объекта(города / объекта/ армии (в приоритете город, потом объект и армия))

        if curGexX ~= -2 and curGexY ~= -2 then	-- здесь можно выбрать героя
			curHero = findNumHeroOnXY(curGexX,curGexY)
			
			if curHero ~= 0 and turnIS == curPlayer and findArgHeroOnXY(curGexX,curGexY,"own") == curPlayer then-- если герой выделен, если ход игрока и если отряд свой			

			  if  findArgHeroOnXY(curGexX,curGexY,"curAct")~=0 then --  если у героя есть действия
			    --her_lst[curHero].curSpd=her_lst[curHero].modSpd -- FIX это частное правило. пока так
				countSpeed(her_lst[curHero].curSpd, curGexX, curGexY) -- будем передавать функции текущую скорость
			  end
			end
		end

      -- click_screen_interface
      -- если меню, миникарта, и тд и тп.

      end
    end
  end
  if button == 2 then -- если нажата ПКМ
--    LOGGER = "mousepressed_r"
			
    -- с помощью ПКМ мы можем переместить перса
    if curHero ~= 0 then -- если выделен герой
      if mouseX < tilesLenX and mouseY < tilesLenY then -- если игрок щелкнул по карте
		movetoGexX, movetoGexY = whatGex() -- установить как координаты тайла, куда наш персонаж будет идти
		tmpHero=findNumHeroOnXY(movetoGexX,movetoGexY)
		if her_lst[curHero].curAct~=0 then -- если у героя есть действия
			if tmpHero == 0 then -- если та клетка свободна
				if movetoGexX+her_lst[curHero].curSpd>=curGexX and movetoGexY+her_lst[curHero].curSpd>=curGexY then	-- ограничение по movetoGexX и movetoGexY
					if spd_arr[movetoGexX][movetoGexY] <= her_lst[curHero].curSpd then		-- проверка по spd_arr, если эти тайлы из тех куда нам хватает скорости шагнуть
					
					-- TODO добавить анимацию движения	
					
						move_hero( movetoGexX, movetoGexY, false)				
						drawIFace()	
					end
				end
			-- если та клетка занята ВРАЖЕСКИМ юнитом
			elseif tmpHero ~= 0 and her_lst[tmpHero].own~=curPlayer then 
				
				
				-- подойти к врагу 
						move_hero( movetoGexX, movetoGexY, true)	

				-- her_lst[curHero].curAct = her_lst[curHero].curAct-1	
				--[[
					— проверка дистанции
					for crit=0, crit>0 do

					roll = rolld10()

					— тут проверка мастерства и преимущества/помехи

					If roll==1 then
					— проверка 1 на всех кубах атаки
					—тут анимация промаха, в лог событий, срабатывание правила промах

					Elseif roll==10
					roll=roll+rolld10— крит
					crit = crit +1
					Else
					— расчет
		
		
				--]]
				-- после атаки
				-- her_lst[curHero].curAct = her_lst[curHero].curAct-1				
				
				drawIFace()	
			end
		end
      end
    end
    --if curHero == 0 then --todo c помощью ПКМ можно двигать карту. но это нужно реализовать в mousepressed/mousereleased
    --  if mouseX < 90 * tilesX / scale and mouseY < 60 * tilesY / scale then -- если карта
    --  end
    --end
  end

end

function whatGex() -- функция определяет какой гекс выбран мышкой
  --TODO заменить числа 30 на wight/2, 60 на wight, 120 на lenght(Во всей проге).
  --LOGGER = "whatGex"
  --curstatus = 0

  x = love.mouse.getX()  -- получить координаты мыши х и у
  y = love.mouse.getY()

  lenT = math.floor(90 / scale) 	-- длина тайла в пикселях
  wigT = math.floor(60 / scale) 	-- ширина тайла в пикселях
  wigTD2 = math.floor(30 / scale)	-- треугольника

  tnx		= 	math.floor(x / lenT) -- номер тайла по Х
  tny 		= 	math.floor(y / wigT) -- по y
  modx90	= 	x % (lenT) -- остаток от деления на 90
  mody60 	= 	y % (wigT) -- на 60
  lupx 		= 	tnx * lenT -- левая точка тайла по x
  lupy 		=	tny * wigT -- по y
  lrpx 		= 	lupx + wigTD2 -- правая точка тайла по x
  lmpy 		= 	lupy + wigTD2 -- по y
  drpy 		= 	lmpy + wigTD2
  urpy 		= 	lupy - wigTD2

  if modx90 >= wigTD2 and modx90 <= lenT then -- если точка принадлежит прямоугольнику
    if curX % 2 == 1 and tnx % 2 == 0 or curX % 2 == 0 and tnx % 2 == 1 then
      y = y - wigTD2
    end
    retGexX = math.floor(x / lenT)
    retGexY = math.floor(y / wigT)
  elseif curX % 2 == 0 and modx90 <= wigTD2 and tnx % 2 == 0 or curX % 2 == 1 and modx90 <= wigTD2 and tnx % 2 == 1 then -- слева от прямоугольника
    if _pointInTriangle(lupx, lmpy, lrpx, lupy, lrpx, drpy, x, y) == true then -- проверка на большой треуг слева
      retGexX = math.floor((x + 30) / lenT)
      retGexY = math.floor(y / wigT)
	  if scale ==4 then -- TODO разобраться в чем прикол - сейчас временная проверка
		retGexX=retGexX-1
	  end
    else	  	
      y = y - wigTD2
      retGexX = math.floor((x - 30) / lenT)
      retGexY = math.floor(y / wigT)
	  if scale ==4 then -- TODO разобраться в чем прикол - сейчас временная проверка
		retGexX=retGexX+1	  
		end
    end	
  elseif curX % 2 == 0 and modx90 <= wigTD2 and tnx % 2 == 1 or curX % 2 == 1 and modx90 <= wigTD2 and tnx % 2 == 0 then -- справа от прямоугольника
    if _pointInTriangle(lupx, lupy, lrpx, lmpy, lupx, drpy, x, y) == true then -- проверка на большой треуг справа
      retGexX = math.floor((x - 30) / lenT)
      retGexY = math.floor(y / wigT)
	  if scale ==4 then -- TODO разобраться в чем прикол - сейчас временная проверка
		retGexX=retGexX+1
	  end
    else
      y = y - wigTD2
      retGexX = math.floor((x + 30) / lenT)
      retGexY = math.floor(y / wigT)
	  if scale ==4 then -- TODO разобраться в чем прикол - сейчас временная проверка
		retGexX=retGexX-1
	  end	    
    end
  end

  if retGexX ~= -2 and retGexY ~= -2 then
    if retGexX < 0 then
      retGexX = 0 -- ! x не может быть меньше 0
    end
    if retGexY < 0 then
      retGexY = 0 -- ! у тоже не может быть меньше 0
    end
    if retGexX > tilesX then
      retGexX = tilesX
    end
    if retGexY > tilesX then
      retGexY = tilesX
    end
    if curX % 2 == 1 then
      y = y - wigT
    end
    if retGexX % 2 == 1 then -- если тот тайл на который мы щелкнули стоит в нечетном ряду, тогда смещение
      y = y - wigTD2
    end

    retGexX = retGexX + curX -- cмещение относительно карты
    retGexY = retGexY + curY
  end
  return retGexX, retGexY
end

function _pointInTriangle(pt1x, pt1y, pt2x, pt2y, pt3x, pt3y, pmx, pmy)
  -- функция выясняет принадлежит ли точка треугольнику. передаем три точки нужного нам треугольника и точку мыши.
  a = (pt1x - pmx) * (pt2y - pt1y) - (pt2x - pt1x) * (pt1y - pmy)
  b = (pt2x - pmx) * (pt3y - pt2y) - (pt3x - pt2x) * (pt2y - pmy)
  c = (pt3x - pmx) * (pt1y - pt3y) - (pt1x - pt3x) * (pt3y - pmy)
  
  return ((a >= 0 and b >= 0 and c >= 0) or (a <= 0 and b <= 0 and c <= 0))
end

function Ms2n(str)  -- базовая функция преобразования ЛМ в стоимость движения
	if str=="grass" then
		return 1
	elseif str=="desert" or str=="desert1"or str=="_desert" then
		return 2
	elseif str=="forest" or str=="forest1" or str=="forest2" or str=="forest3"or str=="_forest" then
		return 3
	elseif str=="hills"  or str=="hills1" then
		return 3
	elseif str=="_mount" or str=="_mount1" or str=="mount"   or str=="mount1" or str=="mount2" then
		return 4
	elseif str=="water" or str=="water1"  then
		return 5
	end
end

function countSpeed(tmpSpeed, chX, chY)
-- функция определяет стоимость перемещения по карте, используя волновой алгоритм
-- функция возвращает количество гексов до цели

-- TODO враги и некоторые объекты препятствуют перемещению
-- TODO blink игнорирует преграды для него все по стоимости 1 клетки

  spd_arr = {}
  for i = 1, mapTilesX-1 do		-- массив с информацией о стоимости перемещения - по факту ложится поверх локальной карты
    spd_arr[i] = {}
    for j = 1, mapTilesX-1 do
      spd_arr[i][j] = 100			-- заполняем 100, чтобы 1 иниализировать, 2 для алгоритма
    end
  end
	spd_arr[chX][chY] = 0 

	for a=0,tmpSpeed do				-- цикл от 0 до значения скорости -- TODO проверить: может быть бага из-за построчного заполнения массива
	  for i = 1, mapTilesX-1 do
		for j = 1, mapTilesY-1 do
		  if spd_arr[i][j] == a then
			if spd_arr[i  ][j+1]>a then -- вниз
			    spd_arr[i  ][j+1]=a+Ms2n(LM[i    ][j + 1])
			end			   
			if spd_arr[i  ][j-1]>a then -- вверх
				spd_arr[i  ][j-1]=a+Ms2n(LM[i    ][j - 1])
			end
		  	if i % 2 == 1 then -- нечет по х
				if spd_arr[i+1][j+1]>a then -- вниз вправо
				   spd_arr[i+1][j+1]=a+Ms2n(LM[i + 1][j + 1])
				end
				if spd_arr[i-1][j+1]>a then -- вниз влево
				   spd_arr[i-1][j+1]=a+Ms2n(LM[i - 1][j + 1])
				end
				if spd_arr[i-1][j  ]>a then -- вверх влево
				   spd_arr[i-1][j  ]=a+Ms2n(LM[i - 1][j    ])
				end
				if spd_arr[i+1][j  ]>a then -- вверх вправо
				   spd_arr[i+1][j  ]=a+Ms2n(LM[i + 1][j    ])
				end	
			elseif i % 2 == 0 then -- чет по х
				if spd_arr[i+1][j  ]>a then -- вниз вправо
				   spd_arr[i+1][j  ]=a+Ms2n(LM[i + 1][j    ]) 
				end
				if spd_arr[i-1][j  ]>a then -- вниз влево
				   spd_arr[i-1][j  ]=a+Ms2n(LM[i - 1][j    ])
				end
				if spd_arr[i-1][j-1]>a then -- вверх влево
				   spd_arr[i-1][j-1]=a+Ms2n(LM[i - 1][j - 1])
				end
				if spd_arr[i+1][j-1]>a then -- вверх вправо
				   spd_arr[i+1][j-1]=a+Ms2n(LM[i + 1][j - 1])
				end				
			end
		  end
		end
	  end
	end
	--LOGGER=a
	return a
end

function findWay(startX, startY, chX, chY)
--! вызывать только если рассчитан countSpeed для текущего героя
-- возвращает кол-во гексов до координаты, при неудаче возвращает 0
-- также заполняет heroWay

	idx = 0
    heroWay = { }
    xyWay = { x, y }
	
	while true do -- пока текущая ячейка — не стартовая
		a = spd_arr[chX][chY]
		minTmp = a
		variant=0
		
		xyWay.x = chX 
		xyWay.y = chY
		heroWay[idx]=xyWay
		
		if startX~=chX and startY~=chY	then
			break
		end
		
		LOGGER="i"..idx..": "..heroWay[idx].x.."/"..heroWay[idx].y.."-"..LOGGER
		
		-- TODO выбор случайного пути при нескольких минимумах
		-- по идее при нескольких минимумах не должно быть проблем - так работает волновой алгоритм 
		-- ищем минимальное значение - проверить все соседние ячейки
		if spd_arr[chX  ][chY+1] < a and spd_arr[chX  ][chY+1] < minTmp then -- вниз
		    minTmp=spd_arr[chX  ][chY+1]
			variant=1
		end			   
		if spd_arr[chX  ][chY-1]<a and spd_arr[chX  ][chY-1] < minTmp then -- вверх
			minTmp=spd_arr[chX  ][chY-1]
			variant=2
		end
		if chX % 2 == 1 then -- нечет по х
			if spd_arr[chX+1][chY+1]<a and spd_arr[chX+1][chY+1] < minTmp then -- вниз вправо
			   minTmp=spd_arr[chX+1][chY+1]
			   variant=3
			end
			if spd_arr[chX-1][chY+1]<a and spd_arr[chX-1][chY+1] < minTmp  then -- вниз влево
			   minTmp=spd_arr[chX-1][chY+1]
			   variant=4
			end
			if spd_arr[chX-1][chY  ]<a and spd_arr[chX-1][chY  ] < minTmp  then -- вверх влево
		       minTmp=spd_arr[chX-1][chY  ]
			   variant=5
			end
			if spd_arr[chX+1][chY  ]<a and spd_arr[chX+1][chY  ] < minTmp  then -- вверх вправо
			   minTmp=spd_arr[chX+1][chY  ]
			   variant=6
			end
		elseif chX % 2 == 0 then -- чет по х
			if spd_arr[chX+1][chY  ]<a and spd_arr[chX+1][chY  ] < minTmp  then -- вниз вправо
			   minTmp=spd_arr[chX+1][chY  ]
			   variant=6
			end
			if spd_arr[chX-1][chY  ]<a and spd_arr[chX-1][chY  ] < minTmp  then -- вниз влево
			   minTmp=spd_arr[chX-1][chY  ]
			   variant=5
			end
			if spd_arr[chX-1][chY-1]<a and spd_arr[chX-1][chY-1] < minTmp  then -- вверх влево
			   minTmp=spd_arr[chX-1][chY-1]
			   variant=7
			end
			if spd_arr[chX+1][chY-1]<a and spd_arr[chX+1][chY-1] < minTmp  then -- вверх вправо
			   minTmp=spd_arr[chX+1][chY-1]
			   variant=8
			end				
		end

		
			
		if minTmp >= a then -- TODO если внезапно появилось правило на неадекватное перемещение, то проверить тут 
			return 0		-- если минимума нет вернуть 0 - пока так	
		else	
			-- узнать какой именно минимум, присвоить heroWay[a].x и heroWay[a].y
			if variant==1 then -- TODO готов к обсуждению рефакторинга данного куска
				chY = chY + 1
			elseif  variant==2 then
				chY = chY - 1				
			elseif  variant==3 then
				chX = chX + 1
				chY = chY + 1			
			elseif  variant==4 then
				chX = chX - 1
				chY = chY + 1			
			elseif  variant==5 then
				chX = chX - 1			
			elseif  variant==6 then
				chX = chX + 1				
			elseif  variant==7 then
				chX = chX - 1
				chY = chY - 1			
			elseif  variant==8 then
				chX = chX + 1
				chY = chY - 1				
			end
			
			idx = idx + 1
		end 
	end
	return idx
end

function gameTime()	-- вызов модуля времени
  -- В тестовом режиме
  -- если первый запуск , рандомно
  -- иначе брать из загрузочного файла в ините, а в этой функции тупо считать и выводить

  --curTime = os.date('*t') --get the date/time
  --print(gameTime.hour)
  --print(gameTime.min)
  --print(gameTime.sec)

  curTime = time:new()
end
