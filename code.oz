%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                        %%%
%%% LINFO1104 – Concepts, paradigms and semantics of programming languages %%%
%%%%%%%%%%%%%%%%%%%%%%% Course titular : Van Roy Peter %%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LethOz Project %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Hanen Mathis and Lejeune ALexandre %%%%%%%%%%%%%%%%%%%%%
%%%                                                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local 

   %%%%% Setup %%%%%

   % Replace this path with the working directory that contains LethOzLib.ozf
   Dossier = {Property.condGet cwdir './'}
   LethOzLib

   %%%%% The two functions to implement %%%%%
   Next
   DecodeStrategy
   
   % Width and height of the grid (1 <= x <= W=24, 1 <= y <= H=24)
   W = 24
   H = 24

   Options
in
   %%%%%% Do NOT change this line ! %%%%%
   [LethOzLib] = {Link [Dossier#'/'#'LethOzLib.ozf']}
   {Browse LethOzLib.play}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Students implementations %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   local

      %%%%% Auxiliary functions %%%%%

      Append
      Concatenate % (was used in a previous implementation)
      AddHead
      RemoveHead
      AddTail % (was used in a previous implementation)
      RemoveTail
      Contains

      %%%%% Effects functions %%%%%

      CheckBoundaries
      GetTimeLeft
      GetTPCoord
      Invert
      MalwareDirection
      DontMove
      Apply

      %%%%% Movements functions %%%%%
      
      NextDirection
      NextHead   
      Move

      %%%%% DecodeStrategy functions %%%%%
         
      DecodeForward
      DecodeRight
      DecodeLeft
      DecodeRepeat
      DecodeStrategyAcc

   in

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Start Auxiliary functions implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      % Function that takes two lists L1 and L2 as arguments
      % and returns a list that is the concatenation of both lists
      %
      % L1 ::= nil | T '|' <List T>
      % L2 ::= nil | T '|' <List T>
      %
      % For example : Calling {Append a|b|c|nil d|e|f|nil} returns the list a|b|c|d|e|f|nil.
      fun {Append L1 L2}
         case L1
            of nil then L2
            [] H|T then H|{Append T L2}
         end
      end

      % Function that takes a List and an integer N as arguments
      % and returns a list which is the concatenation of N times List
      %
      % List ::= nil | T '|' <List T>
      % N ::= <integer>
      %
      % For example : Calling {Concatenate a|b|nil 3} returns the list a|b|a|b|a|b|nil
      fun {Concatenate List N}
         local
            ConcatenateHelper = fun{$ ListArg ListFinal N}
               if N == 0 then ListFinal
               else {ConcatenateHelper ListArg {Append ListArg ListFinal} N-1}
               end
            end
         in
         {ConcatenateHelper List nil N}
         end
      end

      % Function that takes a Head and a List as arguments
      % and returns a list containing the same elements as List 
      % but with Head at its start
      %
      % List ::= nil | T '|' <List T>
      % Head ::= <T> 
      %
      % For example : Calling {AddHead 1|2|3|nil 0} returns the list 0|1|2|3|nil
      fun {AddHead List Head}
         case List
            of nil then Head|nil
            [] H|T then Head|H|T
         end
      end

      % Function that takes a List as an argument
      % and returns a list containing the same elements as List 
      % but without its first element
      %
      % List ::= nil | T '|' <List T>
      %
      % For example : Calling {RemoveHead 0|1|2|3|4|nil} returns the list 1|2|3|4|nil
      fun {RemoveHead List}
         case List
            of nil then nil
            [] H|T then T
         end
      end

      % Function that takes a List as an argument
      % and returns a list containing the same elements as List 
      % but with Tail at its end
      %
      % List ::= nil | T '|' <List T>
      % Tail ::= <T> 
      %
      % For example : Calling {AddTail 1|2|3|nil 4} returns the list 1|2|3|4|nil
      fun {AddTail List Tail}
         case List
            of nil then Tail|nil
            [] H|T then H|{AddTail T Tail}
         end
      end

      % Function that takes a List as an argument
      % and returns a list containing the same elements as List 
      % but without its last element
      %
      % List ::= nil | T '|' <List T>
      %
      % For example : Calling {RemoveTail 1|2|3|4|nil} returns the list 1|2|3|nil
      fun {RemoveTail List}
         case List
            of nil then nil
            [] H|T then
               case T 
                  of nil then nil
                  [] A|B then H|{RemoveTail T}
               end
         end
      end

      % Function that takes an Element and a List as an argument
      % and returns true if one of the element of the List match the given Element
      % and false otherwise
      %
      % List ::= nil | T '|' <List T>
      % Element ::= <T>
      %
      % For example : Calling {Contains good 1|2|good|4|nil} returns true
      fun {Contains Element List}
         case List
             of nil then false
             [] H|T then
                 if H==Element then true
                 else {Contains Element T}
             end
         else false
         end
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % End Auxiliary functions implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Start Next implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %%%%% Effects %%%%%

      % Function that takes a Spaceship as an argument and checks if he is crossing the grid limit
      % and, if so, returns on which boundary and nil otherwise
      %
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Head ::= pos(x:<P> y:<P> to:<direction>)
      fun {CheckBoundaries Head}
         case Head.to
             of nil then nil
             [] west then 
                 if Head.x==1 then left
                 else nil
                 end
             [] east then
                 if Head.x==24 then right
                 else nil
                 end
             [] north then
                 if Head.y==1 then up
                 else nil
                 end
             [] south then
                 if Head.y==24 then bottom
                 else nil
                 end
         end
      end

      % Function that takes a list of Effects as an argument 
      % and returns the time left of the emb if an emb effect is in the list 
      % and nil otherwise
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % N ::= <integer>
      % Effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      fun {GetTimeLeft Effects}
         case Effects
            of nil then nil
            [] H|T then 
               case H 
                  of emb(n:N) then time(t:N)
                  else {GetTimeLeft T}
               end
         end
      end 

      % Function that takes a list of Effects as an argument 
      % and returns the coordinates of the teleportation if a wormhole effect is in the list 
      % and nil otherwise
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % N ::= <integer>
      % Effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      fun {GetTPCoord Effects}
         case Effects
            of nil then nil
            [] H|T then 
               case H 
                  of wormhole(x:X y:Y) then tp(x:X y:Y)
                  else {GetTPCoord T}
               end
         end
      end 

      % Function that takes a list of the Positions of a spaceship
      % and returns an inverted list of those Positions using an Accumulator
      % It therefore changes the directions and positions of the Spaceship to turn around
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Positions ::= positions: [
      %                 pos(x:<P> y:<P> to:<direction>) % Head
      %                 ...
      %                 pos(x:<P> y:<P> to:<direction>) % Tail
      %                 ]
      fun {Invert Positions Acc}
         local 
            Pos
            NewPos
         in
            case Positions 
               of nil then Acc
               [] H|T then
                  case T 
                     of nil then {Invert T H|Acc}
                     [] A|B then
                        if H.x+1==A.x then Pos=pos(x:H.x y:H.y to:east)
                        elseif H.x-1==A.x then Pos=pos(x:H.x y:H.y to:west)
                        elseif H.y+1==A.y then Pos=pos(x:H.x y:H.y to:south)
                        elseif H.y-1==A.y then Pos=pos(x:H.x y:H.y to:north)
                        else
                           case H.to
                              of north then Pos=pos(x:H.x y:H.y to:south)
                              [] south then Pos=pos(x:H.x y:H.y to:north)
                              [] west then Pos=pos(x:H.x y:H.y to:east)
                           else Pos=pos(x:H.x y:H.y to:west)
                           end
                        end
                        if B==nil then NewPos=pos(x:A.x y:A.y to:Pos.to)
                        else NewPos=A
                        end
                        {Invert NewPos|B Pos|Acc}
                  end
            end
         end
      end

      % Function that takes a spaceship's Head position as an argument
      % and returns its new direction depending on the Instruction
      % but by inverting left and right (malware effect)
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Head ::= pos(x:<P> y:<P> to:<direction>)
      % Instruction ::= forward | turn(left) | turn(right)
      fun {MalwareDirection Head Instruction}
         case Instruction 
            of forward then Head.to
            [] turn(left) then
               case Head.to
                  of north then east
                  [] south then west
                  [] west then north
                  [] east then south
               end
            [] turn(right) then
               case Head.to
                  of north then west
                  [] south then east
                  [] west then south
                  [] east then north
               end
         end
      end

      % Function that takes a Spaceship as an argument
      % and returns an updated spaceship by preventing him from getting an Instruction
      % but stilll affecting non-moving effect like revert and shrink
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Spaceship ::= spaceship(
      %                  ...  
      %                  positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                  ]
      %                  effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                  )
      %
      % It uses these auxiliary functions :
      %     - Invert to effect revert
      %     - AddHead/RemoveHead/RemoveTail to update the Spaceship according to theshrink effect
      %     - GetTimeLeft to update the effects
      fun {DontMove Spaceship EffectsRec N}
         local
            OldPositions % revert
            NewPositions % shrink
            UpdatedEffects % updating effects (emb(n:N-1))
            NewSpaceship % updating spaceship 
         in
            % Effecting revert effect (if needed)
            if EffectsRec.revert==true then OldPositions={Invert Spaceship.positions nil}
            else OldPositions=Spaceship.positions
            end

            % Effecting shrink effect (if needed)
            if EffectsRec.shrink==true then NewPositions={RemoveTail OldPositions}
            else NewPositions=OldPositions
            end

            % Updating the effects
            if N==1 then UpdatedEffects=nil
            else UpdatedEffects=emb(n:N-1)|nil
            end

            % Updating the spaceship
            NewSpaceship=spaceship(
               team: Spaceship.team
               name: Spaceship.name
               positions: NewPositions
               effects: UpdatedEffects
               strategy: Spaceship.strategy
               seismicCharge: Spaceship.seismicCharge
            )

            NewSpaceship
         end
      end

      % Function that takes a Spaceship as an argument 
      % and returns a Record containing every information needed by Move 
      % to affect the Spaceship according to the effects affecting him
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % N ::= <integer>
      % Spaceship ::= spaceship(
      %                 ...
      %                 effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                 )
      %
      % It uses these auxiliary functions :
      %     - Contains to know if a certain effect is affecting the Spaceship
      %     - GetTPCoord to get the teleportation coordinates if a wormhole is affecting the Spaceship
      %     - GetTimeLeft to get the time left if an emb is affecting the Spaceship
      fun {Apply Spaceship}
         effectsrec(
            scrap: {Contains scrap Spaceship.effects} 
            revert: {Contains revert Spaceship.effects}
            wormhole: {GetTPCoord Spaceship.effects}
            shrink: {Contains shrink Spaceship.effects}
            malware: {Contains malware Spaceship.effects}
            emb: {GetTimeLeft Spaceship.effects}
            )
      end

      %%%%% Movements %%%%%
      
      % Function that takes a spaceship's Head position as an argument
      % and returns its new direction correctly (no malware) depending on the Instruction
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Instruction ::= forward | turn(left) | turn(right)
      % Head ::= pos(x:<P> y:<P> to:<direction>)
      fun {NextDirection Head Instruction}
         case Instruction 
            of forward then Head.to
            [] turn(left) then
               case Head.to
                  of north then west
                  [] south then east
                  [] west then south
                  [] east then north
               end
            [] turn(right) then
               case Head.to
                  of north then east
                  [] south then west
                  [] west then north
                  [] east then south
               end
         end
      end

      % Function that takes a spaceship's Head position as an argument
      % and returns its new Head 
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Head ::= pos(x:<P> y:<P> to:<direction>)
      %
      % It uses these auxiliary functions :
      %     - CheckBoundaries to move the Spaceship to the other side of the grid if it tries to cross one boundary
      fun {NextHead Head}
         if {CheckBoundaries Head}==left then pos(x:24 y:Head.y to:Head.to)
         elseif {CheckBoundaries Head}==right then pos(x:1 y:Head.y to:Head.to)
         elseif {CheckBoundaries Head}==up then pos(x:Head.x y:24 to:Head.to)
         elseif {CheckBoundaries Head}==bottom then pos(x:Head.x y:1 to:Head.to)
         else 
            case Head.to
               of north then pos(x:Head.x y:Head.y-1 to:Head.to)
               [] south then pos(x:Head.x y:Head.y+1 to:Head.to)
               [] west then pos(x:Head.x-1 y:Head.y to:Head.to)
               [] east then pos(x:Head.x+1 y:Head.y to:Head.to)
            end 
         end
      end

      % Function that takes a Spaceship and an Instruction as arguments
      % and returns an updated spaceship according to the Instruction
      % 
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Instruction ::= forward | turn(left) | turn(right)
      % EffectsRec ::= effectsrec(scrap:)
      % Spaceship ::= spaceship(
      %                  ...  
      %                  positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                  ]
      %                  effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                  )
      %
      % It uses these auxiliary functions :
      %     - NextDirection or MalwareDirection (depending on malware effect) 
      %           to change the direction of the Spaceship Head
      %     - Invert to effect revert
      %     - NextHead to move the Head of the Spaceship
      %     - AddHead/RemoveHead/RemoveTail to update the Spaceship for moving
      %           according to the scrap and shrink effect
      fun {Move Spaceship Instruction EffectsRec}
         local
            DirectionFunction % malware
            OldPositions % revert
            OldHead % wormhole
            NewHead % absorbant boundaries
            NewPositions % scrap/shrink
            NewSpaceship % updating spaceship 
         in
            % Effecting malware effect (if needed)
            if EffectsRec.malware==true then DirectionFunction=MalwareDirection
            else DirectionFunction=NextDirection
            end

            % Effecting revert effect (if needed)
            if EffectsRec.revert==true then OldPositions={Invert Spaceship.positions nil}
            else OldPositions=Spaceship.positions
            end

            % Effecting wormhole effect (if needed)
            case EffectsRec.wormhole
               of nil then OldHead=pos(x:OldPositions.1.x y:OldPositions.1.y to:{DirectionFunction OldPositions.1 Instruction})
               [] tp(x:X y:Y) then OldHead=pos(x:X y:Y to:{DirectionFunction OldPositions.1 Instruction})
            end
            
            % Checking for grid limits in NextHead function
            NewHead={NextHead OldHead}

            % Effecting scrap/shrink effect (if needed)
            if EffectsRec.scrap==true then NewPositions={AddHead{AddHead{RemoveHead OldPositions} OldHead} NewHead}
            elseif EffectsRec.shrink==true then NewPositions={RemoveTail{RemoveTail{AddHead{AddHead{RemoveHead OldPositions} OldHead} NewHead}}}
            else NewPositions={RemoveTail{AddHead{AddHead{RemoveHead OldPositions} OldHead} NewHead}}
            end

            % Updating the spaceship
            NewSpaceship=spaceship(
               team: Spaceship.team
               name: Spaceship.name
               positions: NewPositions
               effects: nil
               strategy: Spaceship.strategy
               seismicCharge: Spaceship.seismicCharge
            )

            NewSpaceship
         end
      end

      %%%%% Next %%%%%

      % Function that computes the next attributes of the Spaceship given the effects
      % affecting him as well as the Instruction
      % 
      % Instruction ::= forward | turn(left) | turn(right)
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Spaceship ::= spaceship(
      %                 ...
      %                 positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                 ]
      %                 effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                 )
      %
      % It uses these auxiliary functions :
      %     - Apply to get a Record of the informations needed by Move 
      %           to affect the Spaceship according to the effects affecting him
      %     - Move to update the Spaceship according to the Instruction and the effects affecting him
      %     - DontMove to update a Spaceship affected by an emb 
      fun {Next Spaceship Instruction}
         % Effecting emb effect (if needed)
         case {Apply Spaceship}.emb
         of nil then 
            {Move Spaceship Instruction {Apply Spaceship}}
         [] time(t:N) then 
            {DontMove Spaceship {Apply Spaceship} N}
         end
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % End Next implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Start DecodeStrategy implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
      % Function that takes no argument
      % and returns a Next function for Spaceship using forward as Instruction
      %
      % Instruction ::= forward
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Spaceship ::= spaceship(
      %                 ...
      %                 positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                 ]
      %                 effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                 )
      %
      % It uses these auxiliary functions :
      %     - Next to return it with the correct Instruction
      fun {DecodeForward}
         fun {$ Spaceship}
            {Next Spaceship forward}
         end
      end

      % Function that takes no argument
      % and returns a Next function for Spaceship using turn(right) as Instruction
      %
      % Instruction ::= turn(right)
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Spaceship ::= spaceship(
      %                 ...
      %                 positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                 ]
      %                 effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                 )
      %
      % It uses these auxiliary functions :
      %     - Next to return it with the correct Instruction
      fun {DecodeRight}
         fun {$ Spaceship}
            {Next Spaceship turn(right)}
         end
      end

      % Function that takes no argument   
      % and returns a Next function for Spaceship using turn(left) as Instruction
      %
      % Instruction ::= turn(left)
      % P ::= <integer x such that 1 <= x <= 24>
      % direction ::= north | south | west | east
      % Spaceship ::= spaceship(
      %                 ...
      %                 positions: [
      %                    pos(x:<P> y:<P> to:<direction>) % Head
      %                    ...
      %                    pos(x:<P> y:<P> to:<direction>) % Tail
      %                 ]
      %                 effects ::= [scrap|revert|wormhole(x:<P> y:<P>)|malware|shrink|emb(n:N)]
      %                 )
      %
      % It uses these auxiliary functions :
      %     - Next to return it with the correct Instruction
      fun {DecodeLeft}
         fun {$ Spaceship}
            {Next Spaceship turn(left)}
         end
      end

      % Function that takes a Strategy and an integer N as arguments
      % and returns a list of functions by repeating N times the Strategy
      % by using an Accumulator 
      %
      % Strategy ::= <instruction> '|' <strategy>
      %            | repeat(<strategy> times:<integer>) '|' <strategy>
      %            | nil
      % N ::= <Int>
      %
      % It uses these auxiliary functions :
      %     - Append to create one and only one list at the end of the DecodeStrategy process
      %     - DecodeStrategyAcc to generate the list of functions needed
      fun {DecodeRepeat Strategy N Acc}
         if N == 0 then Acc
         else {DecodeRepeat Strategy N-1 {Append Acc {DecodeStrategyAcc Strategy nil}}}
         end
      end

      % Function that decodes the strategy of a Spaceship into a list of functions
      % by using an Accumulator
      % Each function of the list corresponds to an instant in the game 
      % and should apply the Instruction of that instant to the Spaceship
      %
      % Spaceship ::= spaceship(
      %                 ...
      %                 strategy: [forward|turn(left)|turn(right)|repeat(Instructions times:N)]
      %                 )
      % Strategy ::= <instruction> '|' <strategy>
      %            | repeat(<strategy> times:<integer>) '|' <strategy>
      %            | nil
      %
      % It uses these auxiliary functions :
      %     - Append to create one and only one list at the end of the DecodeStrategy process
      %     - DecodeForward/DecodeRight/DecodeLeft to generate the correct function to add on the list
      %     - DecodeRepeat to handle repeat Strategy
      fun {DecodeStrategyAcc Strategy Acc}
         case Strategy
            of nil then Acc
            [] forward|Tail then  {DecodeStrategyAcc Tail {Append Acc {DecodeForward}|nil}}
            [] turn(right)|Tail then {DecodeStrategyAcc Tail {Append Acc {DecodeRight}|nil}}
            [] turn(left)|Tail then {DecodeStrategyAcc Tail {Append Acc {DecodeLeft}|nil}}
            [] repeat(Instructions times:N)|Tail then {DecodeStrategyAcc Tail {Append Acc {DecodeRepeat Instructions N nil}}}
         end
      end

      % Function that decodes the strategy of a Spaceship into a list of functions. 
      % Each corresponds to an instant in the game 
      % and should apply the Instruction of that instant to the Spaceship
      %
      % Spaceship ::= spaceship(
      %                 ...
      %                 strategy: [forward|turn(left)|turn(right)|repeat(Instructions times:N)]
      %                 )
      % Strategy ::= <instruction> '|' <strategy>
      %            | repeat(<strategy> times:<integer>) '|' <strategy>
      %            | nil
      %
      % It uses these auxiliary functions :
      %     - DecodeStrategyAcc to generate the list of function
      fun {DecodeStrategy Strategy}
         {DecodeStrategyAcc Strategy nil}
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % End DecodeStrategy implementations %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
      %%%%% Options %%%%%

      Options = options(
         % Path of the scenario (relative to Dossier)
         scenario:'Scenario/scenario.oz'
         %scenario: '/home/alexandre/projet_oz/projet-lethoz/tests/scenario_test_moves.oz'
         
         % Use this key to leave the graphical mode
         closeKey:'Escape'

         % Graphical mode
         debug: true

         % Steps per second, 0 for step by step. (press 'Space' to go one step further)
         frameRate: 0
      )
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Students implementations  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %%%%% Run the program %%%%%
   
   local
      R = {LethOzLib.play Dossier#'/'#Options.scenario Next DecodeStrategy Options}
   in
      {Browse R}
   end
end
