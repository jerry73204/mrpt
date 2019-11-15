# Declares external project: nanogui
#  https://github.com/wjakob/nanogui
# ===================================================
set(CMAKE_MRPT_HAS_NANOGUI 0)
set(CMAKE_MRPT_HAS_NANOGUI_SYSTEM 0)

set(EMBEDDED_NANOGUI_DIR "${MRPT_BINARY_DIR}/otherlibs/nanogui")

set(BUILD_NANOGUI ON CACHE BOOL "Build an embedded version of nanogui (OpenGL GUIs)")
if (BUILD_NANOGUI)
	include(ExternalProject)

	set(nanogui_PREFIX "${MRPT_BINARY_DIR}/otherlibs/nanogui-sdl")

	set(nanogui_INSTALL_DIR "${MRPT_BINARY_DIR}/otherlibs/nanogui-sdl/install" CACHE PATH "Build-time install path for nanogui")
	mark_as_advanced(nanogui_INSTALL_DIR)

	set(nanogui_CMAKE_ARGS
		-DCMAKE_INSTALL_PREFIX=${nanogui_INSTALL_DIR}
		-DNANOGUI_BUILD_EXAMPLE=OFF
		-DCMAKE_LIBRARY_OUTPUT_PATH=${MRPT_BINARY_DIR}/lib
		-DLIBRARY_OUTPUT_PATH=${MRPT_BINARY_DIR}/lib
		-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${MRPT_BINARY_DIR}/bin
		-DRUNTIME_OUTPUT_DIRECTORY=${MRPT_BINARY_DIR}/bin
		-DCMAKE_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}
	)

	# download from GH
	ExternalProject_Add(EP_nanogui_sdl
		PREFIX ${nanogui_PREFIX}
		GIT_REPOSITORY https://github.com/dalerank/nanogui-sdl.git
		CMAKE_ARGS ${nanogui_CMAKE_ARGS}
		TEST_COMMAND      ""
		INSTALL_COMMAND   ""
)
	set(CMAKE_MRPT_HAS_NANOGUI 1)
	set(CMAKE_MRPT_HAS_NANOGUI_SYSTEM 0)

	# Define a cmake target for easy linking & including this nanogui lib:
	add_library(nanogui INTERFACE)

	add_library(nanogui::nanogui ALIAS nanogui)

	export(
		TARGETS nanogui
		FILE "${MRPT_BINARY_DIR}/EP_nanogui-config.cmake"
	)

	install(TARGETS nanogui EXPORT nanogui-targets)

	install(
		EXPORT nanogui-targets
		DESTINATION ${this_lib_dev_INSTALL_PREFIX}share/mrpt
	)

target_include_directories(nanogui
	#SYSTEM  # omit warnings for these hdrs
	INTERFACE
	$<BUILD_INTERFACE:${nanogui_PREFIX}/src/EP_nanogui_sdl/>
	)

#TODO: fix windows build (?)
target_link_libraries(nanogui
	INTERFACE
	$<BUILD_INTERFACE:${MRPT_BINARY_DIR}/lib/libnanogui.so>
	)

endif()
