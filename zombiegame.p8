pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--game--

function _init()
 ienemies()
 ibullets()
 ipups()
end

function _update()
 move_player()
 
 if btnp(❎) then
  shoot()
 end

 uplayer()
 uenemies()
 ubullets()
end

function _draw()
 cls()
 print(player.inv.ammo)
 
 dbullets()
 denemies()
 dpups()
 dplayer()
end
-->8
--helpers--

dirs={
 {0,1}, -- down
 {1,0}, -- right
 {0,-1}, -- up
 {-1,0} -- left
}

edges={
 bottom=128-7,
 right=128-7,
 top=0,
 left=0
}

function col(a,b)
 --collision box of a
 local a_top=a.y
 local a_right=a.x+7
 local a_bottom=a.y+7
 local a_left=a.x
 --collision box of b
 local b_top=b.y
 local b_right=b.x+7
 local b_bottom=b.y+7
 local b_left=b.x
 --collision calculation
 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true 
end

function constrain_map(o)
 if o.y<edges.top then o.y=edges.top end
 if o.x<edges.left then o.x=edges.left end
 if o.y>edges.bottom then o.y=edges.bottom end
 if o.x>edges.right then o.x=edges.right end
end

function draw_hit(o)
 --draw blood splatter
 if o.hit_dir==dirs[1] then
  spr(11,o.x,o.y-3,1,1,false,false)
 elseif o.hit_dir==dirs[2] then
	 spr(10,o.x-3,o.y,1,1,false)
	elseif o.hit_dir==dirs[3] then
	 spr(11,o.x,o.y+3,1,1,false,true)
 elseif o.hit_dir==dirs[4] then
	 spr(10,o.x+2,o.y,1,1,true)
 end
end
-->8
--bullets--

dmg=35

function ibullets()
 buls={}
end

function ubullets()
 for bul in all(buls) do
  --what does each bullet do
  bul.x+=bul.spd*bul.dir[1]
  bul.y+=bul.spd*bul.dir[2]
  if bul.x<0 or
     bul.x>128 or
     bul.y<0 or
     bul.y>128 then
   --delete bullet off screen
   del(buls,bul)
  end
  for e in all(enemies) do
   if not e.dead and col(bul,e) then
    e.hit_frame=5
    sfx(8)
    e.hit_dir=bul.dir
    --deal damage to enemy
    del(buls,bul)
    e.hp-=dmg
   end
  end
 end
end

function dbullets()
 for bul in all(buls) do
  --draw bullet
  spr(0,bul.x,bul.y)
 end
end

function shoot()
 if player.inv.ammo>0 then
	 sfx(1)
	 --fire bullet
	 newbul={
	  x=player.x,
	  y=player.y,
	  dir=player.dir,
	  spd=5,
	  dmg=100,
	 }
 	add(buls,newbul)
 	player.inv.ammo-=1
 else
 	--play click sound
 	sfx(4)
 end
end
-->8
--player--

player={
 hp=100,
 x=8,
 y=8,
 dir=dirs[1],
 sprite=1,
 flipped=false,
 moving=false,
 anim={
  timer=0
 },
 inv={
  ammo=10
 }
}

function uplayer()
 constrain_map(player)
 for a in all(ammo) do
  if col(a,player) then
   --pick up ammo
   del(ammo,a)
   player.inv.ammo+=a.value
   sfx(2)
  end
 end
end

function dplayer()
 if player.flipped then
  spr(player.sprite,player.x,player.y,1,1,true)
 else
  spr(player.sprite,player.x,player.y) 
 end
end

function move_player()
 player.moving=false
 if btn(⬇️) then
  player.y+=1
  player.dir=dirs[1]
  player.moving=true
  player.sprite=1
 end
 if btn(➡️) then
  player.x+=1
  player.dir=dirs[2]
  player.flipped=false
  player.moving=true
  player.sprite=2
 end
 if btn(⬆️) then
  player.y-=1
  player.dir=dirs[3]
  player.moving=true
  player.sprite=3
 end
 if btn(⬅️) then
  player.x-=1
  player.dir=dirs[4]
  player.flipped=true
  player.moving=true
  player.sprite=2
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
spawn_count=10
kill_counter=0

function ienemies()
 --spawn enemies
 for i=1,spawn_count/2 do
 	enemy={
		 sprite=4,
		 hp=100,
		 damage=10,
		 spd=0.25,
		 flipped=false,
		 moving=false,
		 hit_frame=0,
		 hit_dir=nil,
		 dying=false,
		 dead=false,
  }
  enemy.x=128
  enemy.y=rnd(128)
	 add(enemies,enemy)
 end
 for i=1,spawn_count/2 do
  enemy={
		 sprite=4,
		 hp=100,
		 damage=10,
		 spd=0.25,
		 flipped=false,
		 moving=false,
		 hit_frame=0,
		 hit_dir=nil,
		 dying=false,
		 dead=false,
  }
  enemy.x=rnd(128)
  enemy.y=128
	 add(enemies,enemy)
 end
end

function uenemies()
 for e in all(enemies) do
  chase_player(e)
  if e.hp<=0 and not e.dead then
   kill(e)
  end
  if e.hit_frame>0 then
   e.hit_frame-=1
  end
 end
 if most_dead() then
  --respawn enemies
  ienemies()
 end
end

function denemies()
 for e in all(enemies) do 
 	spr(e.sprite,e.x,e.y)
 	if not e.dead and
     e.hit_frame>0 then
 	 draw_hit(e)
 	end
 end
end

function chase_player(e)
 --pythagorean theorem
 local dx=player.x-e.x
 local dy=player.y-e.y
 local d=sqrt(dx*dx+dy*dy)
 --normalized vectors
 local dir_x=dx/d
 local dir_y=dy/d
 --chase speed variable
 e.x+=dir_x*e.spd
 e.y+=dir_y*e.spd
end

function kill(e)
 --play dying sound
 if e.hp<=0 and
    not e.dying then
  sfx(0)
  e.dying=true
  e.spd=0
 end
 --play death animation
 if e.sprite<9 then
  e.sprite+=0.2
 else
  e.dying=false
  e.dead=true
  kill_counter+=1
  if flr(rnd(3))==1 then
   --drop ammo
   add(ammo,{
		  x=e.x+3,
		  y=e.y+3,
		  value=10,
		  sprite=17
	 })
  end 
 end
end

function all_dead()
 --check if all enemies are dead
 for e in all(enemies) do
  if not e.dead then
   return false
  end
 end
 return true
end

function most_dead()
 --check if most enemies are dead
 local t=spawn_count-spawn_count/4
 --if more kills than threshold
 if kill_counter>t then
  kill_counter=0
  return true
 else
  return false
 end
end
-->8
--powerups--

ammo={}

function ipups()
 --spawn powerups
 for i=1,2 do
	 add(ammo,{
		 x=40+rnd(64),
		 y=20+rnd(64),
		 value=10,
		 sprite=17
	 })
 end
end

function dpups()
 for a in all(ammo) do
  spr(a.sprite,a.x,a.y)
 end
end
__gfx__
00000000000000000000000000000000000000000808008000080880000000800008008000088880000000000080000000000000000000000000000000000000
00000000004440000044400000444000003330000000800808000888008080080088880800888888000000000000080000000000000000000000000000000000
00000000007f700000ff700000fff000008380000088880800080388000008000888888808888888008000000000800000000000000000000000000000000000
0000000000fff00000fff00000fff000003330000038800080066338063633888636338086363388080880000008800000000000000000000000000000000000
0000500000a110000011a00000111000006630000086308800366630006688888866888888668888000080000000000000000000000000000000000000000000
00000000001110000011100000111000003660000036608000603600036838088368388083683888008000000000000000000000000000000000000000000000
00000000001010000010100000101000006030000060300000003008000080000880880008888888000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000800000800880008008808880880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000065c77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009caca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0808080801010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000001500115001150021500415006150091500a1500a1500615004150031500215002150021500215002150031500515007150071500615004150021500015000150001500015000150011500115001150
00010000256602464023630216401e6401c64019620171301513013730112400f1400d6400d2300c1200a21009620091200611005630047100413004110027300211003130021100111002710011100171000110
0000000004316221062010622065230543cb07240561ab2510a2412a2312a4213a5213a6113a5113a4118a5113a523fa7213a7313a522aa5224b522d0622ca7230a1324a2324a223da323da532f0733ea573a167
001000200000015170111700a17004170000000417000000051700000000000041700000000000041700000004170001700617007170041700000005170001700000006170041700000000160061700917011170
000100000735005350023500115000150042000320001200002000220002200032000320003200032000220000200000000000018100000000000004100000000410000000041000410004100041000000000000
000400003b6403a640386403664033640326402f6402c6402a640286402664025640246402264021640206401e6401e6301c6301b6301a630196201962018620166101561013610136101261011630106100f610
000000003660022000200001f0001e0001d0001c0001b0001b0001900016000160001600016000180001600016010170301805018060180501805018050190501b0601f060250702b07030070360702e0703f070
000500000e0500e0500e0500e0500e0500e0500e0500f0500f05010050100501105011050110501105012050120501205012050120501305015050160501c0501e0501f0502005021050230502a0502805027050
000200000d15006170041300325002160081700a1500a1400b2000a2000920009200082000720007200072000720007200072000720007200062000620005200042000320002200022000c1000b1000b1000a100
__music__
00 00014344

