-- ţţ����
local GameOxConfig = class('GameOxConfig')

function GameOxConfig:ctor()
    self.pokerCfg={}
    self.pokerCfg[1]={}
    self.pokerCfg[1].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[1].hua={{228,347,1,1,true}}--x,y,scaleX,scaleY,���⴦��

    self.pokerCfg[2]={}
    self.pokerCfg[2].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[2].hua={{228,564,1,1},{228,130,-1,-1}}--x,y,scaleX,scaleY

    self.pokerCfg[3]={}
    self.pokerCfg[3].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[3].hua={{228,564,1,1},{228,130,-1,-1},{228,347,1,1}}--x,y,scaleX,scaleY

    self.pokerCfg[4]={}
    self.pokerCfg[4].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[4].hua={{128,564,1,1},{328,564,1,1},{128,130,-1,-1},{328,130,-1,-1}}--x,y,scaleX,scaleY

    self.pokerCfg[5]={}
    self.pokerCfg[5].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[5].hua={{128,564,1,1},{328,564,1,1},{128,130,-1,-1},{328,130,-1,-1},{228,347,1,1}}--x,y,scaleX,scaleY\

    self.pokerCfg[6]={}
    self.pokerCfg[6].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[6].hua={{128,564,1,1},{328,564,1,1},{128,130,-1,-1},{328,130,-1,-1},{128,347,1,1},{328,347,1,1}}--x,y,scaleX,scaleY

    self.pokerCfg[7]={}
    self.pokerCfg[7].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[7].hua={{128,564,1,1},{328,564,1,1},{128,130,-1,-1},{328,130,-1,-1},{128,347,1,1},{328,347,1,1},{228,455,1,1}}--x,y,scaleX,scaleY

    self.pokerCfg[8]={}
    self.pokerCfg[8].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[8].hua={{128,564,1,1},{328,564,1,1},{128,130,-1,-1},{328,130,-1,-1},{128,347,1,1},{328,347,1,1},{228,455,1,1},{228,230,-1,-1}}--x,y,scaleX,scaleY

    self.pokerCfg[9]={}
    self.pokerCfg[9].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[9].hua={{128,564,1,1},{328,564,1,1},{128,420,1,1},{328,420,1,1},{128,276,-1,-1},{328,276,-1,-1},{128,130,-1,-1},{328,130,-1,-1},{228,347,1,1}}--x,y,scaleX,scaleY

    self.pokerCfg[10]={}
    self.pokerCfg[10].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[10].hua={{128,564,1,1},{328,564,1,1},{128,420,1,1},{328,420,1,1},{128,276,-1,-1},{328,276,-1,-1},{128,130,-1,-1},{328,130,-1,-1},{228,485,1,1},{228,200,-1,-1}}--x,y,scaleX,scaleY

    self.pokerCfg[11]={}
    self.pokerCfg[11].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[11].hua={{228,347,0.95,0.95,true}}--x,y,scaleX,scaleY

    self.pokerCfg[12]={}
    self.pokerCfg[12].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[12].hua={{228,347,0.95,0.95,true}}--x,y,scaleX,scaleY

    self.pokerCfg[13]={}
    self.pokerCfg[13].numbers={{56,624,1,1},{400,70,-1,-1},{56,534,0.5,0.5},{400,160,-0.5,-0.5}}--x,y,scaleX,scaleY
    self.pokerCfg[13].hua={{228,347,0.95,0.95,true}}--x,y,scaleX,scaleY


    self.numberNames={'hongse','heise','hongse','heise'}
    self.colorNames={'dafangjiao','dameihua','dahongtao','daheitao'}
    self.colorNamesA={'fangkuai','meihua','hongtao','heitao'} --A�Ƚ�����

end

return GameOxConfig
