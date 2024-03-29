#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode 4
#
# Copyright © Rei VILO, 2010-2013
# Licence CC = BY NC SA
#
# Last update: Jun 30, 2013 release 55

# References and contribution
# ----------------------------------
# See About folder
# 


include $(MAKEFILE_PATH)/Avrdude.mk

ifneq ($(MAKECMDGOALS),boards)
    ifneq ($(MAKECMDGOALS),build)
        ifneq ($(MAKECMDGOALS),make)
            ifneq ($(MAKECMDGOALS),document)
                ifneq ($(MAKECMDGOALS),clean)
                    ifneq ($(MAKECMDGOALS),distribute)
						ifneq ($(MAKECMDGOALS),info)
                            ifneq ($(MAKECMDGOALS),depends)
                        	    ifeq ($(AVRDUDE_PORT),)
                            	    $(error Serial port not available)
							    endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endif
endif

ifndef UPLOADER
    UPLOADER = avrdude
endif

# Functions
# ----------------------------------
#

# Function TRACE action target source to ~/Library/Logs/embedXcode.log
# result = $(shell echo 'action',$(BOARD_TAG),'target','source' >> ~/Library/Logs/embedXcode.log)
#
TRACE = $(shell echo $(1)': '$(suffix $(2))' < '$(suffix $(3))'	'$(BOARD_TAG)'	'$(dir $(2))'	'$(notdir $(3)) >> ~/Library/Logs/embedXcode.log)

# Function SHOW action target source
# result = $(shell echo 'action',$(BOARD_TAG),'target','source')
#
SHOW  = @echo $(1)': '$(suffix $(2))' < '$(suffix $(3))' 	'$(BOARD_TAG)'	'$(dir $(2))'	'$(notdir $(3))


# CORE libraries
# ----------------------------------
#
ifndef CORE_LIB_PATH
    CORE_LIB_PATH = $(APPLICATION_PATH)/hardware/arduino/cores/arduino
endif

s5              = $(subst .h,,$(subst $(CORE_LIB_PATH)/,,$(wildcard $(CORE_LIB_PATH)/*.h))) # */
CORE_LIBS_LIST  = $(subst $(USER_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s5)))


# List of sources
# ----------------------------------
#

# CORE sources
#
ifdef CORE_LIB_PATH
    CORE_C_SRCS     = $(wildcard $(CORE_LIB_PATH)/*.c) # */
    
    ifneq ($(strip $(NO_CORE_MAIN_FUNCTION)),)
        CORE_CPP_SRCS = $(filter-out %main.cpp, $(wildcard $(CORE_LIB_PATH)/*.cpp $(CORE_LIB_PATH)/*/*.cpp)) # */
    else
        CORE_CPP_SRCS = $(wildcard $(CORE_LIB_PATH)/*.cpp $(CORE_LIB_PATH)/*/*.cpp) # */
    endif        

    CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o) $(CORE_AS_SRCS:.S=.o) 
    CORE_OBJS       = $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
endif


# APPlication Arduino/chipKIT/Digispark/Energia/Maple/Teensy/Wiring
#
ifndef APP_LIB_PATH
    APP_LIB_PATH  = $(APPLICATION_PATH)/libraries
endif

ifeq ($(APP_LIBS_LIST),)
    s1         = $(realpath $(sort $(dir $(wildcard $(APP_LIB_PATH)/*/*.h $(APP_LIB_PATH)/*/*/*.h)))) # */
    APP_LIBS_LIST = $(subst $(APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s1)))
endif

ifndef APP_LIBS
ifneq ($(APP_LIBS_LIST),0)
	s4         = $(patsubst %,$(APP_LIB_PATH)/%,$(APP_LIBS_LIST))
	APP_LIBS   = $(realpath $(sort $(dir $(foreach dir,$(s4),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h)))))
endif
endif

ifndef APP_LIB_OBJS
    FLAG = 1
    APP_LIB_C_SRC     = $(wildcard $(patsubst %,%/*.c,$(APP_LIBS))) # */
    APP_LIB_CPP_SRC   = $(wildcard $(patsubst %,%/*.cpp,$(APP_LIBS))) # */
    APP_LIB_OBJS      = $(patsubst $(APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.o,$(APP_LIB_C_SRC))
    APP_LIB_OBJS     += $(patsubst $(APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.o,$(APP_LIB_CPP_SRC))
else
    FLAG = 0
endif 

# USER libraries
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifndef USER_LIB_PATH
    USER_LIB_PATH    = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)
endif

ifndef USER_LIBS_LIST
	s2               = $(realpath $(sort $(dir $(wildcard $(USER_LIB_PATH)/*/*.h)))) # */
    USER_LIBS_LIST   = $(subst $(USER_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s2)))
endif

ifneq ($(USER_LIBS_LIST),0)
    s3               = $(patsubst %,$(USER_LIB_PATH)/%,$(USER_LIBS_LIST))
	USER_LIBS        = $(realpath $(sort $(dir $(foreach dir,$(s3),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h)))))

    USER_LIB_CPP_SRC = $(wildcard $(patsubst %,%/*.cpp,$(USER_LIBS))) # */
    USER_LIB_C_SRC   = $(wildcard $(patsubst %,%/*.c,$(USER_LIBS))) # */

    USER_OBJS        = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.o,$(USER_LIB_CPP_SRC))
    USER_OBJS       += $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/libs/%.o,$(USER_LIB_C_SRC))
endif

# LOCAL sources
#
LOCAL_C_SRCS    = $(wildcard *.c)

ifneq ($(strip $(NO_CORE_MAIN_FUNCTION)),)
    LOCAL_CPP_SRCS = $(wildcard *.cpp)
else
    LOCAL_CPP_SRCS = $(filter-out %main.cpp, $(wildcard *.cpp))
endif

LOCAL_CC_SRCS   = $(wildcard *.cc)

# Use of implicit rule for LOCAL_PDE_SRCS
#
#LOCAL_PDE_SRCS  = $(wildcard *.$(SKETCH_EXTENSION))
LOCAL_AS_SRCS   = $(wildcard *.S)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.o) $(LOCAL_CPP_SRCS:.cpp=.o) \
		$(LOCAL_PDE_SRCS:.$(SKETCH_EXTENSION)=.o) \
		$(LOCAL_CC_SRCS:.cc=.o) $(LOCAL_AS_SRCS:.S=.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))


# All the objects
# ??? Does order matter?
#
REMOTE_OBJS = $(CORE_OBJS) $(BUILD_CORE_OBJS) $(APP_LIB_OBJS) $(BUILD_APP_LIB_OBJS) $(VARIANT_OBJS) $(USER_OBJS)
OBJS        = $(REMOTE_OBJS) $(LOCAL_OBJS)

# Dependency files
#
DEPS   = $(LOCAL_OBJS:.o=.d)


# Processor model and frequency
# ----------------------------------
#
ifndef MCU
    MCU   = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
endif

ifndef F_CPU
    F_CPU = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
endif


# Rules
# ----------------------------------
#

# Main targets
#
TARGET_A   = $(OBJDIR)/$(TARGET).a
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGET_BIN = $(OBJDIR)/$(TARGET).bin
TARGETS    = $(OBJDIR)/$(TARGET).*

ifndef TARGET_HEXBIN
    TARGET_HEXBIN = $(TARGET_HEX)
endif

ifndef TARGET_EEP
    TARGET_EEP    =
endif

# List of dependencies
#
DEP_FILE   = $(OBJDIR)/depends.mk

# Executables
#
REMOVE  = rm -r
MV      = mv -f
CAT     = cat
ECHO    = echo

# General arguments
#
SYS_INCLUDES  = $(patsubst %,-I%,$(APP_LIBS))
SYS_INCLUDES += $(patsubst %,-I%,$(BUILD_APP_LIBS))
SYS_INCLUDES += $(patsubst %,-I%,$(USER_LIBS))

SYS_OBJS      = $(wildcard $(patsubst %,%/*.o,$(APP_LIBS))) # */
SYS_OBJS     += $(wildcard $(patsubst %,%/*.o,$(BUILD_APP_LIBS))) # */
SYS_OBJS     += $(wildcard $(patsubst %,%/*.o,$(USER_LIBS))) # */

CPPFLAGS      = -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU) -I$(CORE_LIB_PATH)
CPPFLAGS     += $(SYS_INCLUDES) -g -Os -w -Wall -ffunction-sections -fdata-sections
CPPFLAGS     += $(EXTRA_CPPFLAGS)

ifdef USB_FLAGS
    CPPFLAGS += $(USB_FLAGS)
endif    

ifdef USE_GNU99
    CFLAGS        = -std=gnu99
endif

# CXX = flags for C++ only
# CPP = flags for both C and C++
#
CXXFLAGS      = -fno-exceptions
ifdef EXTRA_CXXFLAGS
    CXXFLAGS += $(EXTRA_CXXFLAGS)
endif

ASFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -x assembler-with-cpp
ifeq ($(BUILD_CORE),sam)
    LDFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -lm -Wl,--gc-sections,-u,main -Os $(EXTRA_LDFLAGS)
else
    LDFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -lm -Wl,--gc-sections -Os $(EXTRA_LDFLAGS)
endif

ifndef OBJCOPYFLAGS
    OBJCOPYFLAGS  = -Oihex -R .eeprom
endif

# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future


# 1-6 Build
# ----------------------------------
#

# 2- APPlication Arduino/chipKIT/Digispark/Energia/Maple/Teensy/Wiring library sources
#
$(OBJDIR)/libs/%.o: $(APP_LIB_PATH)/%.c
	$(call SHOW,"2.1-APP",$@,$<)
	$(call TRACE,"2-APP",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.o: $(APP_LIB_PATH)/%.cpp
	$(call SHOW,"2.2-APP",$@,$<)
	$(call TRACE,"2-APP",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.o: $(BUILD_APP_LIB_PATH)/%.cpp
	$(call SHOW,"2.3-APP",$@,$<)
	$(call TRACE,"2-APP",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.o: $(BUILD_APP_LIB_PATH)/%.c
	$(call SHOW,"2.4-APP",$@,$<)
	$(call TRACE,"2-APP",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

# 3- USER library sources
#
$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.cpp
	$(call SHOW,"3.1-USER",$@,$<)
	$(call TRACE,"3-USER",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.c
	$(call SHOW,"3.2-USER",$@,$<)
	$(call TRACE,"3-USER",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

    
# 4- LOCAL sources
# .o rules are for objects, .d for dependency tracking
# 
$(OBJDIR)/%.o: %.c
	$(call SHOW,"4.1-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cc
	$(call SHOW,"4.2-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: 	%.cpp
	$(call SHOW,"4.3-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.S
	$(call SHOW,"4.4-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.o: %.s
	$(call SHOW,"4.5-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.d: %.c
	$(call SHOW,"4.6-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.cpp
	$(call SHOW,"4.7-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.S
	$(call SHOW,"4.8-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.s
	$(call SHOW,"4.9-LOCAL",$@,$<)
	$(call TRACE,"4-LOCAL",$@,$<)
	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)


# 5- SKETCH pde/ino -> cpp -> o file
#
$(OBJDIR)/%.cpp: %.$(SKETCH_EXTENSION)
	$(call SHOW,"5.1-SKETCH",$@,$<)
	$(call TRACE,"5-SKETCH",$@,$<)
	@$(ECHO) $(PDEHEADER) > $@
	@$(CAT)  $< >> $@
#	@$(ECHO) $(PDEHEADER) > $(OBJDIR)/text.txt
#	@$(CAT)  $< >> $(OBJDIR)/text.txt

$(OBJDIR)/%.o: $(OBJDIR)/%.cpp
	$(call SHOW,"5.2-SKETCH",$@,$<)
	$(call TRACE,"5-SKETCH",$@,$<)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) -I. $< -o $@

$(OBJDIR)/%.d: $(OBJDIR)/%.cpp
	$(call SHOW,"5.3-SKETCH",$@,$<)
	$(call TRACE,"5-SKETCH",$@,$<)
	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) -I. $< -MF $@ -MT $(@:.d=.o)


# 6- VARIANT files
#
$(OBJDIR)/libs/%.o: $(VARIANT_PATH)/%.cpp
	$(call SHOW,"6.1-VARIANT",$@,$<)
	$(call TRACE,"6-VARIANT",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(VARIANT_PATH)/%.cpp
	$(call SHOW,"6.2-VARIANT",$@,$<)
	$(call TRACE,"6-VARIANT",$@,$<)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@


# 1- CORE files
#
$(OBJDIR)/%.o: $(CORE_LIB_PATH)/%.c
	$(call SHOW,"1.1-CORE",$@,$<)
	$(call TRACE,"1-CORE",$@,$<)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(CORE_LIB_PATH)/%.S
	$(call SHOW,"1.2-CORE",$@,$<)
	$(call TRACE,"1-CORE",$@,$<)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(CORE_LIB_PATH)/%.cpp
	$(call SHOW,"1.3-CORE",$@,$<)
	$(call TRACE,"1-CORE",$@,$<)
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: $(BUILD_CORE_LIB_PATH)/%.c
	$(call SHOW,"1.4-CORE",$@,$<)
	$(call TRACE,"1-CORE",$@,$<)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(BUILD_CORE_LIB_PATH)/%.cpp
	$(call SHOW,"1.5-CORE",$@,$<)
	$(call TRACE,"1-CORE",$@,$<)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@


# 7- Link
# ----------------------------------
#
$(TARGET_ELF): 	$(OBJS)
		@echo "---- Link ---- "
ifneq ($(BOARD_TAG),teensy3)
		$(call SHOW,"7.1-ARCHIVE",$@,.)
		$(call TRACE,"7-ARCHIVE",$@,.)
		@$(AR) rcs $(TARGET_A) $(REMOTE_OBJS)
endif
		$(call SHOW,"7.2-LINK",$@,.)
		$(call TRACE,"7-LINK",$@,.)
ifeq ($(BUILD_CORE),sam)
# Builds/syscalls_sam3.c.o needs to be mentioned again
		$(CXX) $(LDFLAGS) -o $@ -L$(OBJDIR) -Wl,--start-group Builds/syscalls_sam3.o $(SYSTEM_OBJS) $(LOCAL_OBJS) $(TARGET_A) -Wl,--end-group
else ifeq ($(VARIANT),stellarpad)
# -lc -lm -lgcc need to be at the end of the sentence
#		$(CXX) $(LDFLAGS) -o $@ $(SYSTEM_OBJS) $(LOCAL_OBJS) $(TARGET_A) -L$(OBJDIR) -lc -lm -lgcc
# arm-none-eabi-ar doesn't seem to work with release 4.7.1
		$(CXX) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(REMOTE_OBJS) -L$(OBJDIR) -lc -lm -lgcc

else ifeq ($(PLATFORM),MapleIDE)
		$(CXX) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(TARGET_A) -L$(OBJDIR)

else ifeq ($(PLATFORM),MPIDE)
		$(CXX) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(TARGET_A) -L$(OBJDIR)

else ifeq ($(BOARD_TAG),teensy3)
# arm-none-eabi-ar doesn't seem to work with release 4.7.1
#		$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(TARGET_A) -lc -L$(OBJDIR)
# alternative without archive
		$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(REMOTE_OBJS) -lc -L$(OBJDIR)
else
		$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(TARGET_A) -lc
endif


# 8- Final conversions
# ----------------------------------
#
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(call SHOW,"8.1-COPY",$@,$<)
	$(call TRACE,"8-COPY",$@,$<)
	$(OBJCOPY) -Oihex -R .eeprom $< $@

$(OBJDIR)/%.bin: $(OBJDIR)/%.elf
	$(call SHOW,"8.2-COPY",$@,$<)
	$(call TRACE,"8-COPY",$@,$<)
	$(OBJCOPY) -Obinary -v $< $@

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	$(call SHOW,"8.3-COPY",$@,$<)
	$(call TRACE,"8-COPY",$@,$<)
	-$(OBJCOPY) -Oihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	$(call SHOW,"8.4-COPY",$@,$<)
	$(call TRACE,"8-COPY",$@,$<)
	$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	$(call SHOW,"8.5-COPY",$@,$<)
	$(call TRACE,"8-COPY",$@,$<)
	$(NM) -n $< > $@


# Size of file
# ----------------------------------
#
ifeq ($(TARGET_HEXBIN),$(TARGET_HEX))
    HEXSIZE = $(SIZE) --target=ihex --totals $(CURDIR)/$(TARGET_HEX) | grep TOTALS | tr '\t' . | cut -d. -f2 | tr -d ' '
else ifeq ($(TARGET_HEXBIN),$(TARGET_BIN))
    BINSIZE = $(SIZE) --target=binary --totals $(CURDIR)/$(TARGET_BIN) | grep TOTALS | tr '\t' . | cut -d. -f2 | tr -d ' '
endif

ELFSIZE = $(SIZE) $(CURDIR)/$(TARGET_ELF)
MAX_FLASH_SIZE = $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_size)
RAMSIZE = $(SIZE) $(CURDIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

#PROGRAM_SIZE = $(SIZE) $(CURDIR)/$(TARGET_ELF) -C | grep Program: | cut -d: -f2 | sed -e 's/^[ \t]*//'

#DATA_SIZE = $(SIZE) $(CURDIR)/$(TARGET_ELF) -C | grep Data: | cut -d: -f2 | sed -e 's/^[ \t]*//'


ifneq ($(MAX_FLASH_SIZE),)
    MAX_FLASH_BYTES   = 'bytes (of a '$(MAX_FLASH_SIZE)' byte maximum)'
else
    MAX_FLASH_BYTES   = bytes
endif

ifneq ($(MAX_RAM_SIZE),)
    MAX_RAM_BYTES   = 'bytes (of a '$(MAX_RAM_SIZE)' byte maximum)'
else
    MAX_RAM_BYTES   = bytes
endif


# Serial monitoring
# ----------------------------------
#

# First /dev port
#
ifndef SERIAL_PORT
    SERIAL_PORT = $(firstword $(wildcard $(BOARD_PORT)))
endif

ifndef SERIAL_BAUDRATE
    SERIAL_BAUDRATE = 9600
endif

ifndef SERIAL_COMMAND
    SERIAL_COMMAND  = screen
endif


# Info for debugging
# ----------------------------------
#
# 0- Info
#
info:	
		$(call TRACE,"0-START",)

ifneq ($(MAKECMDGOALS),boards)
ifneq ($(MAKECMDGOALS),clean)
		@if [ -f $(CURDIR)/About/About.txt ]; then $(CAT) $(CURDIR)/About/About.txt; fi;

		@echo ==== Info ====
		@echo ---- Project ----
		@echo 'Target		'$(MAKECMDGOALS)
		@echo 'Name		'$(PROJECT_NAME)
		@echo 'Tag			'$(BOARD_TAG)
		@echo 'Extension		'$(SKETCH_EXTENSION)

		@echo 'User			'$(USER_PATH)

ifneq ($(PLATFORM),Wiring)
		@echo 'IDE			'$(PLATFORM)

ifneq ($(PLATFORM),MapleIDE)
		@echo 'Version		'$(shell cat $(APPLICATION_PATH)/lib/version.txt)
else
		@echo 'Version		'$(shell cat $(APPLICATION_PATH)/lib/build-version.txt)
endif
endif

ifneq ($(BUILD_CORE),)
		@echo 'Platform		'$(BUILD_CORE)
endif

ifneq ($(VARIANT),)
		@echo 'Variant		'$(VARIANT)
endif

ifneq ($(USB_VID),)
		@echo 'USB VID		'$(USB_VID)
endif

ifneq ($(USB_PID),)
		@echo 'USB PID		'$(USB_PID)
endif

		@echo ---- Board ----
		@echo 'Name		$(call PARSE_BOARD,$(BOARD_TAG),name)'
		@echo 'Frequency		'$(F_CPU)
		@echo 'MCU			'$(MCU)

		@echo ---- Ports ----
		@echo 'Uploader		'$(UPLOADER)

ifeq ($(UPLOADER),avrdude)
		@echo 'AVRdude    	'$(AVRDUDE_PORT)
endif

		@echo 'Serial   	  	'$(SERIAL_PORT)
		@echo ---- Libraries ----
		@echo . Core libraries
		@echo $(CORE_LIBS_LIST)

ifneq ($(BUILD_CORE_LIBS_LIST),)
		@echo $(BUILD_CORE_LIBS_LIST)
endif

		@echo . Application libraries of Arduino/chipKIT/Digispark/Energia/Maple/Teensy/Wiring
		@echo $(APP_LIBS_LIST)
		@echo . User libraries from $(SKETCHBOOK_DIR)
		@echo $(USER_LIBS_LIST)
		@echo . Local libraries from $(CURDIR)

ifneq ($(wildcard *.h),)
		@echo $(subst .h,,$(wildcard *.h))
else
		@echo 0
endif

		@echo ==== Info done ====
endif
endif



# Doxygen
# ----------------------------------
#
ifeq ($(MAKECMDGOALS),document)
    include $(MAKEFILE_PATH)/Doxygen.mk
endif


# Release management
# ----------------------------------
#
RELEASE       := 55
RELEASE_PATH  := http://embedxcode.free.fr/release.php?tag=$(BOARD_TAG)&goal=$(MAKECMDGOALS)&ver=$(RELEASE)&proj=$(PROJECT_NAME)
MESSAGE_PATH  := http://embedxcode.free.fr/message.php
RELEASE_LINE  := $(shell curl -s '$(RELEASE_PATH)' | grep -e 'release' | sed 's/&bull;/•/g' | sed -e /^$$/d | tail -1)
RELEASE_LAST  := $(shell echo '$(RELEASE_LINE)' | cut -d' ' -f7)
RELEASE_TEXT  := $(shell echo '$(RELEASE_LINE)' | cut -d' ' -f9-)
RELEASE_DATE  := $(shell echo '$(RELEASE_LINE)' | cut -d' ' -f3-5)
MESSAGE_LINE  := $(shell curl -s '$(MESSAGE_PATH)')


# Rules
# ----------------------------------
#
all: 		info message_all clean compile reset raw_upload serial end_all prepare

fast: 		info message_fast changed compile reset raw_upload serial end_fast prepare

build: 		info message_build clean compile end_build prepare

make:		info message_make changed compile end_make prepare

compile:	info message_compile $(OBJDIR) $(TARGET_HEXBIN) $(TARGET_EEP) size 
		@echo $(BOARD_TAG) > $(NEW_TAG)

prepare:
		@if [ -f Utilities/embedXcode_prepare ]; then if [ $(RELEASE_LAST) ]; then if [ $(RELEASE_LAST) -gt $(RELEASE) ]; then osascript -e 'tell application "System Events" to if button returned of (display dialog "A new release is available.\n\n$(RELEASE_DATE) release $(RELEASE_LAST) • $(RELEASE_TEXT)\n\nInstalled release is $(RELEASE)." buttons {"Go to Download", "Ignore"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") default button 2 with title "embedXcode" giving up after 5) = "Go to Download" then tell application "Safari"' -e 'open location "http://www.embedXcode.weebly.com/download"' -e 'activate' -e 'end tell'; fi; fi; fi;
		@if [ -f Utilities/embedXcode_prepare ]; then Utilities/embedXcode_prepare $(PROJECT_FILE_PATH) $(USER_LIB_PATH); rm -r Utilities/embedXcode_prepare; fi;
		@if [ $(RELEASE_LAST) ]; then if [ $(RELEASE_LAST) -gt $(RELEASE) ]; then echo "==== New release $(RELEASE_LAST) available ===="; echo "$(RELEASE_DATE) release $(RELEASE_LAST) • $(RELEASE_TEXT)"; echo "Have you contributed? Thanks!"; echo "==== Release $(RELEASE) installed ===="; fi; fi;

$(OBJDIR):
		@echo "---- Build ---- "
		@mkdir $(OBJDIR)

#$(TARGET_ELF): 	$(OBJS)
#		@echo "7-" $<
#ifeq ($(PLATFORM),MapleIDE)
#		$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(SYS_OBJS) -L$(OBJDIR)
#else
#		$(CC) $(LDFLAGS) -o $@ $(OBJS) $(SYS_OBJS) -lc
#endif

$(DEP_FILE):	$(OBJDIR) $(DEPS)
		@echo "9-" $<
		@cat $(DEPS) > $(DEP_FILE)


upload:		message_upload reset raw_upload
		@echo "==== upload done ==== "


reset:
		@echo "---- Reset ---- "
		-screen -X kill
		sleep 1
ifeq ($(UPLOADER),dfu-util)
		$(call SHOW,"9.1-RESET",$(DFU_RESET))
		$(call TRACE,"9-RESET",$(DFU_RESET))
		$(DFU_RESET)
		sleep 1
endif

ifdef USB_RESET
# Method 1
		$(call SHOW,"9.2-RESET",USB_RESET 1200)
		$(call TRACE,"9-RESET",USB_RESET 1200)
		stty -f $(AVRDUDE_PORT) 1200
		sleep 2
# Method 2
#		$(USB_RESET) $(AVRDUDE_PORT)
#		sleep 2
endif

# stty on MacOS likes -F, but on Debian it likes -f redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
#		@if [ -z "$(AVRDUDE_PORT)" ]; then \
#			echo "No Arduino-compatible TTY device found -- exiting"; exit 2; \
#			fi
#		for STTYF in 'stty --file' 'stty -f' 'stty <' ; \
#		  do $$STTYF /dev/tty >/dev/null 2>/dev/null && break ; \
#		done ;\
#		$$STTYF $(AVRDUDE_PORT)  hupcl ;\
#		(sleep 0.1 || sleep 1)     ;\
#		$$STTYF $(AVRDUDE_PORT) -hupcl


raw_upload:
		@echo "---- Upload ---- "

ifeq ($(UPLOADER),micronucleus)
		osascript -e 'tell application "System Events" to display dialog "Click OK and plug the Digispark into the USB port." buttons {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") with title "embedXcode"'
		$(call SHOW,"9.1-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -Uflash:w:$(TARGET_HEX):i
else ifeq ($(UPLOADER),avrdude)
		$(call SHOW,"9.1-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -Uflash:w:$(TARGET_HEX):i
else ifeq ($(UPLOADER),bossac)
		$(call SHOW,"9.2-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(BOSSAC) $(BOSSAC_OPTS) $(TARGET_BIN) -R
else ifeq ($(UPLOADER),mspdebug)
		$(call SHOW,"9.3-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(MSPDEBUG) $(MSPDEBUG_OPTS) "$(MSPDEBUG_COMMAND) $(TARGET_HEX)"
else ifeq ($(UPLOADER),lm4flash)
		$(call SHOW,"9.4-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(LM4FLASH) $(LM4FLASH_OPTS) $(TARGET_BIN)
else ifeq ($(UPLOADER),dfu-util)
		$(call SHOW,"9.5-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(DFU_UTIL) $(DFU_UTIL_OPTS) -D $(TARGET_BIN) -R
		sleep 4
		$(info .)
else ifeq ($(UPLOADER),teensy_flash)
		$(call SHOW,"9.6-UPLOAD",$(UPLOADER))
		$(call TRACE,"9-UPLOAD",$(UPLOADER))
		$(TEENSY_POST_COMPILE) -file=$(basename $(notdir $(TARGET_HEX))) -path=$(dir $(abspath $(TARGET_HEX))) -tools=$(abspath $(TEENSY_FLASH_PATH))/
		$(TEENSY_REBOOT)
else
		$(error No valid uploader)
endif


ispload:	$(TARGET_HEX)
		@echo "---- ISP upload ---- "
ifeq ($(UPLOADER),avrdude)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e \
			-U lock:w:$(ISP_LOCK_FUSE_PRE):m \
			-U hfuse:w:$(ISP_HIGH_FUSE):m \
			-U lfuse:w:$(ISP_LOW_FUSE):m \
			-U efuse:w:$(ISP_EXT_FUSE):m
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -D \
			-U flash:w:$(TARGET_HEX):i
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			-U lock:w:$(ISP_LOCK_FUSE_POST):m
endif

serial:		reset
		@echo "---- Serial ---- "
		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $(SERIAL_PORT) $(SERIAL_BAUDRATE)"'
		
#		echo "$@"
#		echo "-- "
#		export TERM="vt100"
#		echo "#!/bin/sh" /tmp/arduino.command
#		echo "$(SERIAL_COMMAND) $(SERIAL_PORT) $(SERIAL_BAUDRATE)" > /tmp/arduino.command
#		chmod 0755 /tmp/arduino.command
#		open /tmp/arduino.command

size:
		@echo "---- Size ----"
#		echo 'PROGRAM_SIZE ' $(shell $(PROGRAM_SIZE))
#		echo 'DATA_SIZE ' $(shell $(DATA_SIZE))
		@if [ -f $(TARGET_HEX) ]; then echo 'Binary sketch size: ' $(shell $(HEXSIZE)) $(MAX_FLASH_BYTES); echo; fi
#		@if [ -f $(TARGET_ELF) ]; then $(ELFSIZE); echo; fi
		@if [ -f $(TARGET_BIN) ]; then echo 'Binary sketch size:' $(shell $(BINSIZE)) $(MAX_FLASH_BYTES); echo; fi
		@if [ -f $(TARGET_ELF) ]; then echo 'Estimated SRAM used:' $(shell $(RAMSIZE)) $(MAX_RAM_BYTES); echo; fi
#		@echo PROGRAM_SIZE $(PROGRAM_SIZE)
#		@echo DATA_SIZE $(DATA_SIZE)
		@if [ -n '$(MESSAGE_LINE)' ]; then echo 'Message: $(MESSAGE_LINE)'; fi;

distribute:
		@echo "==== Distribution ===="
		@Utilities/dist.sh $(PROJECT_NAME)
		@echo "==== Distribution done ===="

clean:
		@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
		@echo "nil" > $(OBJDIR)/nil
		@echo "---- Clean ----"
		-@rm -r $(OBJDIR)/* # */ 

changed:
		@echo "---- Clean changed ----"
ifeq ($(CHANGE_FLAG),1)
		@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
		@echo "nil" > $(OBJDIR)/nil
		$(REMOVE) $(OBJDIR)/* # */
else
#		$(REMOVE) $(LOCAL_OBJS)
		for f in $(LOCAL_OBJS); do if [ -f $$f ]; then rm $$f; fi; done
endif

depends:	$(DEPS)
		@echo "---- Depends ---- "
		@cat $(DEPS) > $(DEP_FILE)

boards:
		@echo "==== Boards ===="
		@echo "Tag=Name"
		@if [ -f $(ARDUINO_PATH)/hardware/arduino/boards.txt ]; then echo "---- $(notdir $(basename $(ARDUINO_APP))) ---- "; \
			grep .name $(ARDUINO_PATH)/hardware/arduino/boards.txt; echo; fi
		@if [ -d $(ARDUINO_PATH)/hardware/arduino/sam ]; then echo "---- $(notdir $(basename $(ARDUINO_APP))) SAM ---- "; \
			grep .name $(ARDUINO_PATH)/hardware/arduino/sam/boards.txt; echo; fi
		@if [ -d $(ARDUINO_PATH)/hardware/arduino/avr ]; then echo "---- $(notdir $(basename $(ARDUINO_APP))) AVR ---- "; \
			grep .name $(ARDUINO_PATH)/hardware/arduino/avr/boards.txt; echo; fi
		@if [ -d $(MPIDE_APP) ];   then echo "---- $(notdir $(basename $(MPIDE_APP))) ---- ";   \
			grep .name $(MPIDE_PATH)/hardware/pic32/boards.txt;     echo; fi
		@if [ -d $(DIGISPARK_APP) ];  then echo "---- $(notdir $(basename $(DIGISPARK_APP))) ---- ";  \
			grep .name $(DIGISPARK_PATH)/hardware/digispark/boards.txt;  echo; fi
		@if [ -d $(ENERGIA_APP) ]; then echo "---- $(notdir $(basename $(ENERGIA_APP))) MSP430 ---- "; \
			grep .name $(ENERGIA_PATH)/hardware/msp430/boards.txt;  echo; fi
		@if [ -d $(ENERGIA_PATH)/hardware/lm4f ]; then echo "---- $(notdir $(basename $(ENERGIA_APP))) LM4F ---- ";  \
			grep .name $(ENERGIA_PATH)/hardware/lm4f/boards.txt;  echo; fi
		@if [ -d $(MAPLE_APP) ];   then echo "---- $(notdir $(basename $(MAPLE_APP))) ---- ";    \
			grep .name $(MAPLE_PATH)/hardware/leaflabs/boards.txt;  echo; fi
		@if [ -d $(TEENSY_APP) ];  then echo "---- $(notdir $(basename $(TEENSY_APP))) ---- ";   \
			grep .name $(TEENSY_PATH)/hardware/teensy/boards.txt | grep -v menu;    echo; fi
		@if [ -d $(WIRING_APP) ];  then echo "---- $(notdir $(basename $(WIRING_APP))) ---- ";  \
			grep .name $(WIRING_PATH)/hardware/Wiring/boards.txt;   echo; fi
		@echo "==== Boards done ==== "

message_all:
		@echo "==== All ===="

message_fast:
		@echo "==== Fast ===="

message_make:
		@echo "==== Make ===="

message_build:
		@echo "==== Build ===="

message_compile:
		@echo "---- Compile ----"

message_upload:
		@echo "==== Upload ===="

message_document:
		@echo "==== Document ===="

end_all:
		@echo "==== All done ==== "

end_fast:
		@echo "==== Fast done ==== "

end_build:
		@echo "==== Build done ==== "

end_make:
		@echo "==== Make done ==== "


                
.PHONY:	all clean depends upload raw_upload reset serial show_boards headers size document
