--[[
    Author: Neer
    License : GPL3 (free to share,modify,sell,do whatever you please)
    Check my github repository and feel free to improve them
    https://github.com/YoungNeer/
]]

require("Card")
local height=500
local width=700
suits = { "heart","spade","club","diamond" }
values = { "ace","2","3","4","5","6","7","8","9","10","jack","queen","king" }
cards={}

--playerhand table and computerhand table
playerh={}
comph={}
playerscore=0
compscore=0
math.randomseed(os.time())
COMP_LIMIT=math.random(14,17)

--[[
    The player would automatically have to hold if he picks more than 11 cards
]]
hold=false;
function love.load()
    initialiseCards()    
    love.window.setMode(width,height)
    love.window.setTitle("Game of Twenty-One");
    COMPDECK=love.graphics.newImage("img/pattern"..math.random(3)..".png")
    BACKDECK=love.graphics.newImage("img/pattern4.png");
    EMPTYDECK=love.graphics.newImage("img/empty.png");
    --see draw function to understand the next two steps
    DECKWIDTH=BACKDECK:getWidth()
    DECKHEIGHT=BACKDECK:getHeight()
    DECKPOSX=width-DECKWIDTH-20;
    COMP_POSX=DECKPOSX-2*DECKWIDTH;
    BACK=love.graphics.newImage("img/back.jpg")
    regular=love.graphics.newFont("fonts/LeagueGothic-Regular.otf", 24)
    title=love.graphics.newFont("fonts/MontereyFLF.ttf",20)
    large=love.graphics.newFont("fonts/LeagueGothic-Regular.otf", 38)
    love.graphics.setFont(regular)
end

function love.draw()
    love.graphics.setColor(1,1,1)
    --draw the background
    for i=0,height,50 do
        love.graphics.draw(BACK,0,i,0,0.25,0.25) 
    end
    --draw the empty decks at the beginning of the game
    if #playerh==0 then
        love.graphics.draw(EMPTYDECK,30,30)    
        love.graphics.draw(EMPTYDECK,COMP_POSX+30,30)
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(title)  
        --try removing this if to know its purpose in life  
        if hold==false then
            love.graphics.printf("Player",30,DECKHEIGHT/2+16,DECKWIDTH,'center')        
        end
        love.graphics.printf("Computer",COMP_POSX+30,DECKHEIGHT/2+16,DECKWIDTH,'center') 
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(regular)    
        
        
    end
    --draw the cards in player's hand
    for i,value in ipairs(playerh) do
        love.graphics.setColor(1,1,1)        
        love.graphics.draw(value.img,i*30,i*30)
    end
    --if user hovers over backdeck (see next fee lines)
    if checkhover() then
        love.graphics.setColor(0.7,0.7,0)
    end
    --draw the backdeck, the deck on clicking which the player will hold to his cards    
    love.graphics.draw(BACKDECK,DECKPOSX,30)
    

    --draw the cards in computer's hand
    for i, card in ipairs(comph) do
        love.graphics.setColor(0.7,0.8,0.7)
        --the player shouldn't be able to see his opponent's cards until both of them hold to their cards.
        --the computer will hold his cards automatically (see mousereleased function) so we don't need to check for computer
        if hold==false then
            love.graphics.draw(COMPDECK,COMP_POSX+30*i,30*i)
        --if the game is over then the player must be able to see the cards in computer's hand
        else 
            love.graphics.draw(card.img,COMP_POSX+30*i,30*i)
        end
        love.graphics.setColor(1,1,1)
    end

    --draw the box (instruction box and the dialog box which appears when the game is completed)
    love.graphics.setColor(1,1,1,0.8)
    if hold==false or compscore<COMP_LIMIT  then 
        love.graphics.rectangle('fill',width/2-110,height-100,220,60);
    else
        love.graphics.rectangle('fill',width/2-160,height/2-55,320,110); 
    end    

    --draw the text
    love.graphics.setColor(0,0,0,1)
    if hold==false then
        love.graphics.printf("Click anywhere to pick a card\nClick on the deck to hold",width/2-110,height-100,220,'center')
    else
        if compscore<COMP_LIMIT then 
            love.graphics.printf("Click anywhere to wait for computer's turn",width/2-110,height-100,220,'center')        
        else
            love.graphics.setFont(large)    
            if getWinner()=='Tie' then
                love.graphics.printf("Game is Tie",width/2-110,height/2-38,220,'center')                
            else
                love.graphics.printf(getWinner().." WON",width/2-110,height/2-38,220,'center')
            end
            love.graphics.setFont(regular)
            love.graphics.printf("Click to start a new game",width/2-110,height/2+12,220,'center')            
        end
    end
end

function love.mousereleased(x,y,button)
    if button==1 then
        --if game is completed
        if compscore>=COMP_LIMIT and hold==true then
            --reset the game
            initialiseCards()
            playerh={}
            comph={}
            hold=false
            playerscore=0
            compscore=0
        end
        --if computer is not holding to his cards
        if compscore<COMP_LIMIT then
            local c=getRandomCard()
            table.insert(comph,c)
            compscore=compscore+face(c.value,compscore)
        end
        --if player is not holding to his cards
        if  hold==false then
            --if the user clicks on the backdeck                    
            if x>DECKPOSX and y>30 and x<DECKPOSX+DECKWIDTH and y<DECKHEIGHT+30 then
                hold=true
            --if the user clicks elsewhere on the screen
            else
                --[[
                think about it the only case where user would have maximum number of cards
                to make the sum exactly 21 is having five 2 cards and 1 ace card i.e. eleven
                so for the next opponent who cannot see the cards but only the number of cards
                will be sure that no of cards in his hands cannot be more than eleven so he would
                automatically hold to his cards. This is a pretty unique idea i think, as other
                blackjack games usually make the player hold or stop the game if sum > 21
                ]]
                if #playerh==11 then
                    hold=true;
                --in any other case the computer (opponent/dealer) will allow him to pick up a card
                else
                    local c=getRandomCard()
                    playerh[#playerh+1]=c
                    playerscore=playerscore+face(c.value,playerscore)
                end
            end
        end
    end
end

function face(value,score)
    if value=='king' or value=='queen' or value=='jack' then
        return 10;
    elseif value=='ace' then
        --ace will give u either 1 or 11 depending on the situation
        --which seems to be in advantage
        if score+11>21 then
            return 1;
        else return 11;
        end
    else return tonumber(value);
    end
end

function getWinner()
    if playerscore>21 and compscore>21 then
        return "Tie"
    else
        if playerscore>21 then
            return "Computer"
        elseif compscore>21 then
            return "Player"
        else
            if playerscore==compscore then
                return "Tie"
            elseif playerscore>compscore then
                return "Player"
            else
                return "Computer"
            end
        end
    end
end

function checkhover()
    x=love.mouse.getX()
    y=love.mouse.getY()    
    if x>DECKPOSX 
    and y>30 and x<DECKPOSX+DECKWIDTH 
    and y<DECKHEIGHT+30 and hold==false then
        return true
    else
        return false
    end
end

function initialiseCards()
    for i,suit in ipairs (suits) do
        cards[i]={}
        for j, value in ipairs (values) do
            cards[i][j]=Card.init(suit,value)
        end
    end
end

function getRandomCard()
    local s=math.random(4)
    local c=math.random(#cards[s])
    local card=cards[s][c]
    table.remove(cards[s],c)
    return card
end