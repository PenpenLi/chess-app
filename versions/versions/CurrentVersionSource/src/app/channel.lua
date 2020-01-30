if device.platform == "ios" then
    local testWritableAllPathkpp = cc.FileUtils:getInstance():listFiles("ZZChannel");
    local filesLength = table.getn(testWritableAllPathkpp)
    require "src.app.utils.Utils"
    local Strary = Utils:stringSplit(testWritableAllPathkpp[filesLength],"/")
    CHANNEL_ID=Strary[table.getn(Strary)-1]
else
    CHANNEL_ID=101
end