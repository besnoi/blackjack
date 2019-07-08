Card={}
function Card.init(suit,value)
    local this=setmetatable({},Card);
    this.suit=suit
    this.value=value
    this.img=love.graphics.newImage("img/"..suit.."_"..value..".png")
    return this;
end