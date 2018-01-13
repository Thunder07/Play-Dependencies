if(CMAKE_CURRENT_SOURCE_DIR STREQUAL "${CMAKE_SOURCE_DIR}")
	option(TARGET_IOS "Enable building for iOS" OFF)

	# macOS deployment target needs to be set before 'project' to work
	if(APPLE AND NOT TARGET_IOS)
		set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9" CACHE STRING "Minimum OS X deployment version")
	endif()

	if(ANDROID)
		message("-- Generating for Android --")
		set(TARGET_PLATFORM_ANDROID TRUE)
	elseif(APPLE AND TARGET_IOS)
		message("-- Generating for iOS --")
		set(TARGET_PLATFORM_IOS TRUE)
	elseif(APPLE)
		message("-- Generating for macOS --")
		set(TARGET_PLATFORM_MACOS TRUE)
	elseif(WIN32)
		message("-- Generating for Win32 --")
		string(FIND ${CMAKE_GENERATOR} "Win64" HASWIN64)
		if(NOT HASWIN64 EQUAL -1)
			message("-- Arch: x64 --")
			set(TARGET_PLATFORM_WIN32_X64 TRUE)
		else()
			message("-- Arch: x86 --")
			set(TARGET_PLATFORM_WIN32_X86 TRUE)
		endif()
		set(TARGET_PLATFORM_WIN32 TRUE)
	else()
		message("-- Generating for Unix compatible platform --")
		set(TARGET_PLATFORM_UNIX TRUE)
	endif()
	
	set(CMAKE_CXX_STANDARD 14)
	set(CMAKE_CXX_STANDARD_REQUIRED ON)
	if(TARGET_PLATFORM_WIN32)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /MP")
	endif()

	if(NOT CMAKE_BUILD_TYPE)
		set(CMAKE_BUILD_TYPE Release CACHE STRING
			"Choose the type of build, options are: None Debug Release"
			FORCE)
	endif()

	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")

	# definitions
	if(NOT MSVC)
		MESSAGE("-- Build type: ${CMAKE_BUILD_TYPE}")
		if(CMAKE_BUILD_TYPE STREQUAL "Release")
			add_definitions(-DNDEBUG)
		else()
			add_definitions(-D_DEBUG)
		endif()
	endif()

	if(TARGET_PLATFORM_WIN32)
		add_definitions(-D_CRT_SECURE_NO_WARNINGS)
		add_definitions(-D_SCL_SECURE_NO_WARNINGS)
		add_definitions(-D_LIB)
		add_definitions(-D_UNICODE -DUNICODE)

		if(DEFINED VTUNE_ENABLED)
			add_definitions(-DVTUNE_ENABLED)
			list(APPEND PROJECT_LIBS libittnotify jitprofiling)
			if(DEFINED VTUNE_PATH)
				if(TARGET_PLATFORM_WIN32_X86)
					link_directories($(VTUNE_PATH)\lib32)
				else()
					link_directories($(VTUNE_PATH)\lib64)
				endif()
				include_directories($(VTUNE_PATH)\include)
			else()
				MESSAGE(FATAL_ERROR "VTUNE_PATH was not defined")
			endif()
		endif()
	endif()

	if(PROFILE)
		add_definitions(-DPROFILE)
	endif()
endif()
