--金币比例
MONEY_SCALE = 100

--TODO:微信登录开关 默认关闭
WECHAT_LOGIN_ENABLED = false
--TODO:微信AppId
WECHAT_APPID = ""
--定位开关 默认关闭
LOCATION_ENABLED = false

--输入框占位符颜色
PLACE_HOLDER_COLOR = cc.c3b(218,219,220)

--游戏ID
GAMEID_ZJH=1                	--炸金花
GAMEID_MAJIANG=2                --麻将	
GAMEID_YAODIREN=3				--幺地人
GAMEID_DOUDIZHU=4           	--听用斗地主
GAMEID_NIUNIU=5           		--牛牛
GAMEID_SAIMA=6                	--赛马
GAMEID_DEZHOUPUKE=7           	--德州扑克
GAMEID_MAGU=8                 	--麻古
GAMEID_HUANSANZHANG=9         	--换三张（万洲麻将)
GAMEID_BUYU=10                 	--金蟾捕鱼
GAMEID_HUANLEWUZHANG=11       	--欢乐五张
GAMEID_XIAOBAISHA=12          	--小白鲨
GAMEID_CHONGQINGNIUNIU=13     	--重庆牛牛
GAMEID_MAJIANGNIUNIU=14        	--拖儿八
GAMEID_DAER=15                 	--大贰
GAMEID_NEIJIANGMAJIANG=16    	--内江麻将	
GAMEID_JJBUYU=17              	--街机捕鱼
GAMEID_DDZ=18                 	--标准斗地主
GAMEID_BRNN=19               	--百人牛牛
GAMEID_QZNN=20               	--抢庄牛牛
GAMEID_SUOHA=21            		--梭哈
GAMEID_LHD=22					--龙虎斗
GAMEID_ANIMAL=23              	--飞禽走兽
GAMEID_HHDZ=24                	--红黑大战
GAMEID_BJL=25					-- 百家乐
GAMEID_FISH=26					-- 极速捕鱼
GAMEID_FRUIT=27					-- 水果机
GAMEID_CPDDZ=30					-- 百变斗地主
GAMEID_BRQZNN=31				-- 八人抢庄牛牛

GAME_LIST = {
	[GAMEID_ZJH] = "炸金花",
	[GAMEID_MAJIANG] = "麻将",
	[GAMEID_YAODIREN] = "幺地人",
	[GAMEID_DOUDIZHU] = "听用斗地主",
	[GAMEID_NIUNIU] = "牛牛",
	[GAMEID_SAIMA] = "赛马",
	[GAMEID_DEZHOUPUKE] = "德州扑克",
	[GAMEID_MAGU] = "麻古",
	[GAMEID_HUANSANZHANG] = "万洲麻将",
	[GAMEID_BUYU] = "捕鱼",
	[GAMEID_HUANLEWUZHANG] = "欢乐五张",
	[GAMEID_XIAOBAISHA] = "小白鲨",
	[GAMEID_CHONGQINGNIUNIU] = "重庆牛牛",
	[GAMEID_MAJIANGNIUNIU] = "拖儿八",
	[GAMEID_DAER] = "大贰",
	[GAMEID_NEIJIANGMAJIANG] = "内江麻将",
	[GAMEID_JJBUYU] = "街机捕鱼",
	[GAMEID_DDZ] = "斗地主",
	[GAMEID_BRNN] = "百人牛牛",
	[GAMEID_QZNN] = "抢庄牛牛",
	[GAMEID_SUOHA] = "梭哈",
	[GAMEID_LHD] = "龙虎斗",
	[GAMEID_ANIMAL] = "飞禽走兽",
	[GAMEID_HHDZ] = "红黑大战",
	[GAMEID_BJL] = "百家乐",
	[GAMEID_CPDDZ] = "百变斗地主",
	[GAMEID_FISH] = "极速捕鱼",
	[GAMEID_FRUIT] = "水果机",
	[GAMEID_BRQZNN] = "八人抢庄牛牛",
}

GAMECORE_CONFIGS = {
	[GAMEID_DDZ] = "app.games.ddz.DdzCore",
	[GAMEID_ZJH] = "app.games.zjh.ZjhCore",
	[GAMEID_QZNN] = "app.games.qznn.QznnCore",
	[GAMEID_BRNN] = "app.games.brnn.BrnnCore",
	[GAMEID_HHDZ] = "app.games.hhdz.HhdzCore",
	[GAMEID_CPDDZ] = "app.games.cpddz.CPDdzCore",
	[GAMEID_FISH] = "app.games.fish.FishCore",
	[GAMEID_FRUIT] = "app.games.fruit.FruitCore",
	[GAMEID_BRQZNN] = "app.games.brqznn.BRQznnCore",
}

GAME_ALIAS = {
	[GAMEID_ZJH] = "zjh",
	[GAMEID_MAJIANG] = "mj",
	[GAMEID_YAODIREN] = "幺地人",
	[GAMEID_DOUDIZHU] = "听用斗地主",
	[GAMEID_NIUNIU] = "nn",
	[GAMEID_SAIMA] = "赛马",
	[GAMEID_DEZHOUPUKE] = "德州扑克",
	[GAMEID_MAGU] = "麻古",
	[GAMEID_HUANSANZHANG] = "万洲麻将",
	[GAMEID_BUYU] = "by",
	[GAMEID_HUANLEWUZHANG] = "欢乐五张",
	[GAMEID_XIAOBAISHA] = "小白鲨",
	[GAMEID_CHONGQINGNIUNIU] = "重庆牛牛",
	[GAMEID_MAJIANGNIUNIU] = "拖儿八",
	[GAMEID_DAER] = "de",
	[GAMEID_NEIJIANGMAJIANG] = "njmj",
	[GAMEID_JJBUYU] = "jjby",
	[GAMEID_DDZ] = "ddz",
	[GAMEID_BRNN] = "brnn",
	[GAMEID_QZNN] = "qznn",
	[GAMEID_SUOHA] = "sh",
	[GAMEID_LHD] = "lhd",
	[GAMEID_ANIMAL] = "fqzs",
	[GAMEID_HHDZ] = "hhdz",
	[GAMEID_BJL] = "bjl",
	[GAMEID_CPDDZ] = "cpddz",
	[GAMEID_FISH] = "fish",
	[GAMEID_FRUIT] = "fruit",
	[GAMEID_BRQZNN] = "brqznn",
}

--游戏头像数量
COMMON_HEAD_MAX = 12
--公用
COMMON_ANIMATION_RES = "common/animation/"
COMMON_FONT_RES = "common/font/"
COMMON_IMAGES_RES = "common/images/"
COMMON_HEAD_RES = "common/head/"
COMMON_FRAME_RES = "common/frame/"
COMMON_SOUND_RES = "common/sound/"
--大厅
BASE_ANIMATION_RES = "base/animation/"
BASE_FONT_RES = "base/font/"
BASE_IMAGES_RES = "base/images/"
BASE_SOUND_RES = "base/sound/"
--斗地主
GAME_DDZ_PREFAB_RES = "games/ddz/prefab/"
GAME_DDZ_ANIMATION_RES = "games/ddz/animation/"
GAME_DDZ_FONT_RES = "games/ddz/font/"
GAME_DDZ_IMAGES_RES = "games/ddz/images/"
GAME_DDZ_SOUND_RES = "games/ddz/sound/"
--炸金花
GAME_ZJH_ANIMATION_RES = "games/zjh/animation/"
GAME_ZJH_FONT_RES = "games/zjh/font/"
GAME_ZJH_IMAGES_RES = "games/zjh/images/"
GAME_ZJH_SOUND_RES = "games/zjh/sound/"
--抢庄牛牛
GAME_QZNN_ANIMATION_RES = "games/qznn/animation/"
GAME_QZNN_FONT_RES = "games/qznn/font/"
GAME_QZNN_IMAGES_RES = "games/qznn/images/"
GAME_QZNN_SOUND_RES = "games/qznn/sound/"
--百人牛牛
GAME_BRNN_ANIMATION_RES = "games/brnn/animation/"
GAME_BRNN_FONT_RES = "games/brnn/font/"
GAME_BRNN_IMAGES_RES = "games/brnn/images/"
GAME_BRNN_SOUND_RES = "games/brnn/sound/"
--红黑大战
GAME_HHDZ_PREFAB_RES = "games/hhdz/prefab/"
GAME_HHDZ_ANIMATION_RES = "games/hhdz/animation/"
GAME_HHDZ_FONT_RES = "games/hhdz/font/"
GAME_HHDZ_IMAGES_RES = "games/hhdz/images/"
GAME_HHDZ_SOUND_RES = "games/hhdz/sound/"

-- 百变斗地主
GAME_CPDDZ_PREFAB_RES = "games/cpddz/prefab/"
GAME_CPDDZ_ANIMATION_RES = "games/cpddz/animation/"
GAME_CPDDZ_FONT_RES = "games/cpddz/font/"
GAME_CPDDZ_IMAGES_RES = "games/cpddz/images/"
GAME_CPDDZ_SOUND_RES = "games/cpddz/sound/"

--捕鱼
GAME_FISH_ANIMATION_RES = "games/fish/animation/"
GAME_FISH_FONT_RES = "games/fish/font/"
GAME_FISH_IMAGES_RES = "games/fish/images/"
GAME_FISH_SOUND_RES = "games/fish/sound/"
--水果机
GAME_FRUIT_ANIMATION_RES = "games/fruit/Amt/"
GAME_FRUIT_FONT_RES = "games/fruit/Studio/font/"
GAME_FRUIT_IMAGES_RES = "games/fruit/Studio/"
GAME_FRUIT_SOUND_RES = "games/fruit/sound/"
--八人抢庄牛牛
GAME_BRQZNN_ANIMATION_RES = "games/brqznn/animation/"
GAME_BRQZNN_FONT_RES = "games/brqznn/font/"
GAME_BRQZNN_IMAGES_RES = "games/brqznn/images/"
GAME_BRQZNN_SOUND_RES = "games/brqznn/sound/"