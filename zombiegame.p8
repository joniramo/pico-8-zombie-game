pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--game--

function _init()
 ibullets()
 ienemies()
end

function _update()
 move_player()
 
 if btnp(❎) then
  shoot()
 end
 ubullets()
end

function _draw()
 cls()
 if btnp(❎) then
  spr(0,player.x,player.y)
  sp=17
 end
 spr(player.sprite,player.x,player.y) 
 for e in all(enemies) do
 	spr(e.sprite,e.x,e.y)
 end
 dbullets()
end
-->8
--bullets--

function ibullets()
 buls={}
end

function ubullets()
 for bul in all(buls) do
  --what does each bullet do
  bul.x+=bul.spd
  if bul.x > 128 then
   del(buls,bul)
  end
 end
end

function dbullets()
 for bul in all(buls) do
  --how to draw each bullet
  spr(0,bul.x,bul.y)
 end
end

function shoot()
 --what happens when we fire
 newbul = {
  x=player.x,
  y=player.y,
  spd=5
 }
 add(buls,newbul)
end
-->8
--player--

player={
 x=8,
 y=8,
 sprite=1,
 flipped=false,
 moving=false,
 animation={
  timer=0
 }
}

function move_player()
 player.moving=false

 if btn(⬅️) then
  player.x-=1
  player.flipped=true
  player.moving=true
 end
 if btn(➡️) then
  player.x+=1
  player.flipped=false
  player.moving=true
 end
 if btn(⬆️) then
  player.y-=1
  player.moving=true
 end
 if btn(⬇️) then
  player.y+=1
  player.moving=true
 end
end

function animate_player()
 if player.moving then
  player.anim.timer+=1
   if player.anim.timer>5 then  -- this value determines animation speed
    player.anim.timer=0
    player.sprite=(player.sprite+1)%2  -- alternate between 0 and 1
  end
 else
  player.anim.frame=player.sprite --resets to idle sprite when not moving
 end
end
-->8
--enemy--

enemies={}

function ienemies()
 for i=1,5 do
	 add(enemies,{
		 x=rnd(20+64),
		 y=rnd(20+64),
		 sprite=2,
		 flipped=false,
		 moving=false,
		 anim={
		  timer=0,
		  frame=0
		 }
	 })
 end
end
__gfx__
00000000000000000000000008080080000808800008888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004440000033300000008008080003880888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007f70000083800000888808000808338008888800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000fff0000033300000333000800668388636338800000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000000a110000066300000863088003666300066888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001110000036600000866080006036000366388800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001010000060300000603000000030080088000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000008008888880800000000000000000000000000000000000000000000000000000000000000000000000000000000
