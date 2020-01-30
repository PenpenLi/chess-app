local C = class("SettingsLayer",BaseLayer)
SettingsLayer = C

C.RESOURCE_FILENAME = "common/SettingsLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="box_img.close_btn",events={{event="click",method="hide"}}},
	musicSlider = {path="box_img.music_slider",events={{event="event",method="onEventMusicSlider"}}},
	soundSlider = {path="box_img.sound_slider",events={{event="event",method="onEventSoundSlider"}}},
}

function C:onCreate()
	C.super.onCreate(self)
	local musicVol = GET_MUSIC_VOLUME()
	local soundVol = GET_SOUND_VOLUME()
	printInfo("onCreate==musicVolume:"..tostring(musicVol))
	printInfo("onCreate==soundVolume:"..tostring(soundVol))
	--self.musicSlider:setPercent(self:volToSlider(musicVol))
	--self.soundSlider:setPercent(self:volToSlider(soundVol))
end

function C:onEventMusicSlider( event )
	if event.name == "ON_PERCENTAGE_CHANGED" then
		local percent = self.musicSlider:getPercent()
--		if percent < 10 then
--			percent = 10
--		elseif percent > 90 then
--			percent = 90
--		end
		self.musicSlider:setPercent(percent)
		local vol = self:sliderToVol(percent)
		SET_MUSIC_VOLUME(vol)
	end
end

function C:onEventSoundSlider( event )
	if event.name == "ON_PERCENTAGE_CHANGED" then
		local percent = self.soundSlider:getPercent()
--		if percent < 10 then
--			percent = 10
--		elseif percent > 90 then
--			percent = 90
--		end
		self.soundSlider:setPercent(percent)
		local vol = self:sliderToVol(percent)
		SET_SOUND_VOLUME(vol)
	end
end

--slider to vol
function C:sliderToVol( sliderPercent )
	--return ((sliderPercent-10)/80)*100
    --print("sliderPercent-----" .. sliderPercent)
    return sliderPercent
end

function C:volToSlider( volPercent )
	return 10 + 80*(volPercent/100)
end

return SettingsLayer