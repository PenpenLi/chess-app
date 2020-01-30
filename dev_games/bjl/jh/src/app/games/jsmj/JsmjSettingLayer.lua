
local C = class("JsmjSettingClass",BaseLayer)
JsmjSettingClass = C

C.RESOURCE_FILENAME = "games/jsmj/SettingsLayer.csb"
C.RESOURCE_BINDING = {
	closeBtn = {path="Panel_close",events={{event="click",method="hide"}}},
	musicSlider = {path="box_img.Image_music.music_slider",events={{event="event",method="onEventMusicSlider"}}},
	soundSlider = {path="box_img.Image_sound.sound_slider",events={{event="event",method="onEventSoundSlider"}}}
}

function C:onCreate()
	C.super.onCreate(self)
	local musicVol = GET_MUSIC_VOLUME()
	local soundVol = GET_SOUND_VOLUME()
	printInfo("onCreate==musicVolume:"..tostring(musicVol))
	printInfo("onCreate==soundVolume:"..tostring(soundVol))
	self.musicSlider:setPercent(self:volToSlider(musicVol))
	self.soundSlider:setPercent(self:volToSlider(soundVol))
end

function C:onEventMusicSlider( event )
	if event.name == "ON_PERCENTAGE_CHANGED" then
		local percent = self.musicSlider:getPercent()
		self.musicSlider:setPercent(percent)
		local vol = self:sliderToVol(percent)
		SET_MUSIC_VOLUME(vol)
	end
end

function C:onEventSoundSlider( event )
	if event.name == "ON_PERCENTAGE_CHANGED" then
		local percent = self.soundSlider:getPercent()
		self.soundSlider:setPercent(percent)
		local vol = self:sliderToVol(percent)
		SET_SOUND_VOLUME(vol)
	end
end

--slider to vol
function C:sliderToVol( sliderPercent )
	return (sliderPercent/100)*100
end

function C:volToSlider( volPercent )
	return 100*(volPercent/100)
end

return JsmjSettingClass