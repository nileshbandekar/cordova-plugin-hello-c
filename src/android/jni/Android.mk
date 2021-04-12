# Android Makefile

APP_PLATFORM := android-21
APP_ABI := armeabi-v7a arm64-v8a x86 x86_64

PATH_SEP := /

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

#traverse all the directory and subdirectory
define walk
  $(wildcard $(1)) $(foreach e, $(wildcard $(1)$(PATH_SEP)*), $(call walk, $(e)))
endef

SRC_LIST :=
INCLUDE_LIST :=


################################
# prepare shared lib

LOCAL_MODULE := helloc

# JNI interface files
INCLUDE_LIST += $(LOCAL_PATH)
SRC_LIST += $(wildcard $(LOCAL_PATH)/*.c)

# Cross-platform common files
INCLUDE_LIST += $(LOCAL_PATH)/../../common/
ifeq ($(OS),Windows_NT)
	INCLUDE_LIST += ${shell dir $(LOCAL_PATH)\..\..\common\ /ad /b /s}
else
	INCLUDE_LIST += ${shell find $(LOCAL_PATH)/../../common/ -type d}
endif
SRC_LIST += $(filter %.c, $(call walk, $(LOCAL_PATH)/../../common))


$(info LOCAL_PATH:$(LOCAL_PATH))
$(info SRC_LIST:$(SRC_LIST))
$(info INCLUDE_LIST:$(INCLUDE_LIST))

LOCAL_C_INCLUDES := $(INCLUDE_LIST)
LOCAL_SRC_FILES := $(SRC_LIST:$(LOCAL_PATH)/%=%)

LOCAL_CFLAGS += -std=c99
LOCAL_CPPFLAGS := -fblocks
TARGET_PLATFORM := android-27
LOCAL_DISABLE_FATAL_LINKER_WARNINGS := true
LOCAL_LDLIBS += -Wl,--no-warn-shared-textrel
LOCAL_LDFLAGS += -fuse-ld=gold

include $(BUILD_SHARED_LIBRARY)

################################

# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_VERBOSE_MAKEFILE on)

set(can_use_assembler TRUE)
enable_language(ASM)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             src/main/cpp/syscall.S
             src/main/cpp/native-lib.cpp
              )

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib} )
