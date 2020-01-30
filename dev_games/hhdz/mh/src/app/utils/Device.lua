function device:isVm()
    return platform.isSiumlator()
end

function device:getUuid()
    return platform.getUUID()
end

function device:getLocalIp()
     require "socket"
     local s = socket.udp()
     s:setpeername("74.125.115.104",80) --这里的IP是谷歌的，其实随便写一个就行
     local ip, _ = s:getsockname()
     if ip then
         return ip
     else
         return "0.0.0.0"
     end
end

