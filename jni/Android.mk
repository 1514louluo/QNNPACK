LOCAL_PATH := $(call my-dir)/..

ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),armeabi armeabi-v7a))
include $(CLEAR_VARS)
LOCAL_MODULE := qnnpack_aarch32_neon_ukernels
LOCAL_SRC_FILES += \
	src/q8add/neon.c \
	src/q8conv/4x8-aarch32-neon.S \
	src/q8gemm/4x8-aarch32-neon.S \
	src/q8gemm/4x8c2-xzp-aarch32-neon.S \
	src/q8gemm/4x-sumrows-neon.c \
	src/q8updw/9c8-aarch32-neon.S \
	src/q8mpdw/25c8-neon.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src
LOCAL_CFLAGS := -std=c99 -Wall -O2 -march=armv7-a -mfloat-abi=softfp -mfpu=neon
LOCAL_STATIC_LIBRARIES := cpuinfo
include $(BUILD_STATIC_LIBRARY)
endif # armeabi or armeabi-v7a

ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),arm64-v8a))
include $(CLEAR_VARS)
LOCAL_MODULE := qnnpack_aarch64_neon_ukernels
LOCAL_SRC_FILES += \
	src/q8add/neon.c \
	src/q8conv/8x8-aarch64-neon.S \
	src/q8gemm/8x8-aarch64-neon.S \
	src/q8updw/9c8-neon.c \
	src/q8mpdw/25c8-neon.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src
LOCAL_CFLAGS := -std=c99 -Wall -O2
LOCAL_STATIC_LIBRARIES := cpuinfo
include $(BUILD_STATIC_LIBRARY)
endif # arm64-v8a

ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),x86 x86_64))
include $(CLEAR_VARS)
LOCAL_MODULE := qnnpack_sse2_ukernels
LOCAL_SRC_FILES += \
	src/q8add/sse2.c \
	src/q8conv/4x4c2-sse2.c \
	src/q8gemm/4x4c2-sse2.c \
	src/q8mpdw/25c8-sse2.c \
	src/q8updw/9c8-sse2.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src
LOCAL_CFLAGS := -std=c99 -Wall -O2
LOCAL_STATIC_LIBRARIES := cpuinfo FP16
include $(BUILD_STATIC_LIBRARY)
endif # x86 or x86_64

include $(CLEAR_VARS)
LOCAL_MODULE = qnnpack_operators
LOCAL_SRC_FILES := \
	src/add.c \
	src/convolution.c \
	src/deconvolution.c \
	src/fully-connected.c \
	src/operator-run.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/src
LOCAL_CFLAGS := -std=c99 -Wall -O2
ifeq ($(NDK_DEBUG),1)
LOCAL_CFLAGS += -DQNNP_LOG_LEVEL=5
else
LOCAL_CFLAGS += -DQNNP_LOG_LEVEL=0
endif
LOCAL_STATIC_LIBRARIES := clog cpuinfo FP16 pthreadpool_interface fxdiv
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := qnnpack
LOCAL_SRC_FILES := \
	src/init.c \
	src/operator-delete.c
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_C_INCLUDES := $(LOCAL_EXPORT_C_INCLUDES) $(LOCAL_PATH)/src
LOCAL_CFLAGS := -std=c99 -Wall -Oz
ifeq ($(NDK_DEBUG),1)
LOCAL_CFLAGS += -DQNNP_LOG_LEVEL=5
else
LOCAL_CFLAGS += -DQNNP_LOG_LEVEL=0
endif
LOCAL_STATIC_LIBRARIES := clog cpuinfo pthreadpool_interface qnnpack_operators
ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),x86 x86_64))
LOCAL_STATIC_LIBRARIES += qnnpack_sse2_ukernels
endif # x86 or x86_64
ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),armeabi armeabi-v7a))
LOCAL_STATIC_LIBRARIES += qnnpack_aarch32_neon_ukernels
endif # armeabi or armeabi-v7a
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_STATIC_LIBRARIES += qnnpack_aarch64_neon_ukernels
endif # arm64-v8a
include $(BUILD_STATIC_LIBRARY)

$(call import-add-path,$(LOCAL_PATH)/deps)

$(call import-module,clog/jni)
$(call import-module,FP16/jni)
$(call import-module,cpuinfo/jni)
$(call import-module,pthreadpool/jni)
$(call import-module,fxdiv/jni)
