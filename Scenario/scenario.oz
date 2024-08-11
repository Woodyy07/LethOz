local
   NoBomb=false|NoBomb
in
   scenario(
      bombLatency: 3
      walls: false
      step: 0
      spaceships: [
         spaceship(
            team: blue
            name: mathis
            positions: [pos(x:3 y:3 to:south) pos(x:3 y:2 to:south) pos(x:2 y:2 to:east)]
            effects: nil
            strategy: [
               repeat([repeat([forward] times:5) turn(right)] times:2)
               repeat([forward] times:3)
               turn(left)
               repeat([forward] times:5)
               turn(right)
               repeat([forward] times:3)
               turn(left)
               repeat([forward] times:4)
               turn(right)
               repeat([forward] times:2)
               turn(left)
               repeat([forward] times:3)
               repeat([turn(right)] times:2)
               turn(left)
               repeat([forward] times:2)
               turn(right)
               repeat([forward] times:30) % win
            ]
            seismicCharge: true|NoBomb
         )
         spaceship(
            team: blue
            name: alexandre
            positions: [pos(x:22 y:22 to:north) pos(x:22 y:23 to:north) pos(x:23 y:23 to:east)]
            effects: nil
            strategy: [
               repeat([forward] times:5)
               repeat([turn(left) turn(right)] times:3)
               repeat([forward] times:5)
               repeat([turn(left) forward] times:2)
               repeat([forward] times:5)
               turn(right)
               repeat([forward] times:6)
               turn(left)
               repeat([forward] times:8)
               repeat([turn(left) turn(right)] times:30) % win
            ]
            seismicCharge: true|NoBomb
         )
         spaceship(
            team: red
            name: victor
            positions: [pos(x:22 y:3 to:south) pos(x:22 y:2 to:south) pos(x:23 y:2 to:west)]
            effects: nil
            strategy: [
               repeat([forward] times:6)
               repeat([turn(right)] times:2)
               repeat([turn(left) forward] times:2)
               repeat([forward] times:3)
               turn(left)
               repeat([forward] times:4)
               turn(right) % turn left because of malware
               repeat([forward] times:30) % dead
            ]
            seismicCharge: true|NoBomb
         )
         spaceship(
            team: red
            name: zelia
            positions: [pos(x:3 y:22 to:north) pos(x:3 y:23 to:north) pos(x:2 y:23 to:west)]
            effects: nil
            strategy: [
               repeat([forward] times:3) 
               repeat([turn(right)] times:3)
               turn(left)
               repeat([forward] times:22)
               turn(right) % turn left because of malware
               repeat([forward] times:6)
               turn(left)
               repeat([forward] times:7)
               turn(left) % turn right because of malware
               repeat([forward] times:30) % dead
            ]
            seismicCharge: true|NoBomb
         )
         ]
      bonuses: [
         % Catcher revert (saves mathis from bomb)
         bonus(position:pos(x:3 y:6) color:orange effect:revert target:catcher)

         % Catcher wormhole (zelia catch a scrap because of it)
         bonus(position:pos(x:3 y:20) color:white effect:wormhole(x:9 y:17) target:catcher)
         bonus(position:pos(x:9 y:17) color:white effect:wormhole(x:3 y:20) target:catcher)

         % Opponents revert (alexandre prevents victor from taking a scrap)
         bonus(position:pos(x:19 y:13) color:red effect:revert target:opponents)

         % Opponents malware (alexandre use it to kill victor by making him crash into mathis)
         bonus(position:pos(x:17 y:11) color:green effect:malware target:opponents)

         % Opponents shrink (zelia use it to shrink mathis and alexandre)
         bonus(position:pos(x:9 y:10) color:black effect:shrink target:opponents)

         % Catcher wormhole (mathis go into it to catch a scrap and zelia pass trough on the other side later)
         bonus(position:pos(x:15 y:10) color:white effect:wormhole(x:7 y:5) target:catcher)
         bonus(position:pos(x:7 y:5) color:white effect:wormhole(x:15 y:10) target:catcher)

         % Opponents emb (alexandre use it to stop zelia for 3 turns, preventing her from crahsing into mathis by the way)
         bonus(position:pos(x:16 y:16) color:blue effect:emb(n:3) target:opponents)

         % Opponents malware (alexandre use it to prevent zelia from taking a scrap)
         bonus(position:pos(x:13 y:16) color:green effect:malware target:opponents)

         % Allies revert (alexandre use it so that mathis can grow even more)
         bonus(position:pos(x:10 y:20) color:yellow effect:revert target:allies)

         % Opponents emb (alexandre use it to stop zelia for 5 turns)
         bonus(position:pos(x:10 y:14) color:blue effect:emb(n:5) target:opponents)

         % Opponents malware (alexandre use it to make zelia crash into mathis)
         bonus(position:pos(x:8 y:11) color:green effect:malware target:opponents)

         % Scraps
         bonus(position:pos(x:10 y:16) color:gray effect:scrap target:catcher)
         bonus(position:pos(x:19 y:11) color:gray effect:scrap target:catcher)
         bonus(position:pos(x:12 y:6) color:gray effect:scrap target:catcher)
         bonus(position:pos(x:15 y:8) color:gray effect:scrap target:catcher)
      ]
      bombs: [
         bomb(position:pos(x:5 y:7) explodesIn:4)
         bomb(position:pos(x:20 y:10) explodesIn:8)
      ]
   )
end
