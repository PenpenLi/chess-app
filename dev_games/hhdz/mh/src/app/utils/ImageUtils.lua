local C = class("ImageUtils")
ImageUtils = C

C.xmlHttpReqs = nil

function C:ctor()
	self.xmlHttpReqs = {}
end

function C:clean()
	for k,v in pairs(self.xmlHttpReqs) do
		if v and v.unregisterScriptHandler then
			v:unregisterScriptHandler()
		end
	end
end

--下载图片 url=图片连接 fileName=图片名称 callback=回调(fileName,absolutePath)
function C:downloadImage( url,fileName,callback )
	if not url or not fileName then
		if callback then
			callback(nil)
		end
		return
	end

	if cc.FileUtils:getInstance():isFileExist(fileName) then
        if callback then
        	callback(fileName)
        end
        return
    end

    local xmlHttpReq = cc.XMLHttpRequest:new()
    xmlHttpReq.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xmlHttpReq.timeout = 60;
    xmlHttpReq:open("GET", url) -- 打开链接

    local key = Md5.sumhexa(tostring(url))
    self.xmlHttpReqs[key] = xmlHttpReq

    -- http响应回调
    local function onResponse()
        if xmlHttpReq.readyState == 4 and (xmlHttpReq.status >= 200 and xmlHttpReq.status < 207) then
        	--download
            local fileUtil = cc.FileUtils:getInstance()
			if not fileUtil:isDirectoryExist(DOWNLOAD_PATH) then
			    fileUtil:createDirectory(DOWNLOAD_PATH)
			end
			--download/res
			local DOWNLOAD_RES = DOWNLOAD_PATH.."res/"
			if not fileUtil:isDirectoryExist(DOWNLOAD_RES) then
			    fileUtil:createDirectory(DOWNLOAD_RES)
			end
			--filename
            local fullFileName = DOWNLOAD_RES..tostring(fileName)
	        local file = io.open(fullFileName,"wb")
	        local data = xmlHttpReq.response
	        file:write(data)
	        file:close()
	        if callback then
	        	callback(fileName,fullFileName)
	        end
        else
        	if callback then
            	callback(nil)
            end
        end
        xmlHttpReq:unregisterScriptHandler();
        xmlHttpReq = nil;
        self.xmlHttpReqs[key] = nil
    end

    -- 注册脚本回调方法
    xmlHttpReq:registerScriptHandler(onResponse)
    xmlHttpReq:send() -- 发送请求
end

function C:cancelDownloadImage( url )
	if not url then
		return
	end
	local key = Md5.sumhexa(tostring(url))
	local xmlHttpReq = self.xmlHttpReqs[key]
	if xmlHttpReq and xmlHttpReq.unregisterScriptHandler then
		xmlHttpReq:unregisterScriptHandler()
	end
	self.xmlHttpReqs[key] = nil
end

if imageUtils then
	imageUtils:clean()
end

imageUtils = ImageUtils.new()

return C