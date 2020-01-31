LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../../Classes/AppDelegate.cpp \
../../../Classes/CallLuaFunction.cpp \
../../../Classes/MyListener.cpp \
../../../Classes/SStringConverter.cpp \
../../../Classes/SDK/Private/Client.cpp \
../../../Classes/SDK/Private/CommMD5.cpp \
../../../Classes/SDK/Private/Http.cpp \
../../../Classes/SDK/Private/SBase64.cpp \
../../../Classes/SDK/Private/SBind.cpp \
../../../Classes/SDK/Private/Server.cpp \
../../../Classes/SDK/Private/SFile.cpp \
../../../Classes/SDK/Private/SInit.cpp \
../../../Classes/SDK/Private/SListener.cpp \
../../../Classes/SDK/Private/SLua.cpp \
../../../Classes/SDK/Private/SMemoryPool.cpp \
../../../Classes/SDK/Private/SMsgManager.cpp \
../../../Classes/SDK/Private/SPacker.cpp \
../../../Classes/SDK/Private/SPlatform.cpp \
../../../Classes/SDK/Private/STools.cpp \
../../../Classes/SDK/FishPath/FishPathManager.cpp \
../../../Classes/SDK/FishPath/lua_FishPathManager.cpp \
hellolua/main.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../Classes

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
