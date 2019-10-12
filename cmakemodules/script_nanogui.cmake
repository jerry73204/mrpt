# Declares external project: nanogui
#  https://github.com/wjakob/nanogui
# ===================================================
set(CMAKE_MRPT_HAS_NANOGUI 0)
set(CMAKE_MRPT_HAS_NANOGUI_SYSTEM 0)

set(EMBEDDED_NANOGUI_DIR "${MRPT_BINARY_DIR}/otherlibs/nanogui")

set(BUILD_NANOGUI ON CACHE BOOL "Build an embedded version of nanogui (OpenGL GUIs)")
if (BUILD_NANOGUI)
	include(ExternalProject)

	set(nanogui_PREFIX "${MRPT_BINARY_DIR}/otherlibs/nanogui")

	set(nanogui_INSTALL_DIR "${MRPT_BINARY_DIR}/otherlibs/nanogui/install" CACHE PATH "Build-time install path for nanogui")
	mark_as_advanced(nanogui_INSTALL_DIR)

	set(nanogui_CMAKE_ARGS
		-DCMAKE_INSTALL_PREFIX=${nanogui_INSTALL_DIR}
		-DNANOGUI_BUILD_PYTHON=OFF
		-DNANOGUI_BUILD_EXAMPLE=OFF
		-DCMAKE_LIBRARY_OUTPUT_PATH=${MRPT_BINARY_DIR}/lib
		-DLIBRARY_OUTPUT_PATH=${MRPT_BINARY_DIR}/lib
		-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${MRPT_BINARY_DIR}/bin
		-DRUNTIME_OUTPUT_DIRECTORY=${MRPT_BINARY_DIR}/bin
		-DCMAKE_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}
	)

	# download from GH
	ExternalProject_Add(EP_nanogui
		PREFIX ${nanogui_PREFIX}
		GIT_REPOSITORY https://github.com/wjakob/nanogui.git
		GIT_SUBMODULES ext/eigen ext/glfw ext/nanovg # ext/pybind
		INSTALL_DIR ${nanogui_INSTALL_DIR}
		CMAKE_ARGS ${nanogui_CMAKE_ARGS}
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

# nanogui depends on glfw3:
# Compile GLFW
set(glfw3_CMAKE_ARGS
	-DGLFW_BUILD_EXAMPLES=OFF
	-DGLFW_BUILD_TESTS=OFF
	-DGLFW_BUILD_DOCS=OFF
	-DGLFW_USE_CHDIR=OFF
	-DCMAKE_INSTALL_PREFIX=${nanogui_INSTALL_DIR}
	)

ExternalProject_Add(EP_glfw3
	URL ${nanogui_PREFIX}/src/EP_nanogui/ext/glfw/
	INSTALL_DIR ${nanogui_INSTALL_DIR}
	CMAKE_ARGS ${glfw3_CMAKE_ARGS}
)


target_include_directories(nanogui
	SYSTEM  # omit warnings for these hdrs
	INTERFACE
	$<BUILD_INTERFACE:${nanogui_INSTALL_DIR}/include/>
	$<BUILD_INTERFACE:${nanogui_PREFIX}/src/EP_nanogui/ext/nanovg/src/>
	)

#TODO: fix windows build (?)
target_link_libraries(nanogui
	INTERFACE
	$<BUILD_INTERFACE:${nanogui_INSTALL_DIR}/lib/libnanogui.so>
	$<BUILD_INTERFACE:${nanogui_INSTALL_DIR}/lib/libglfw3.a>
	)

endif()
