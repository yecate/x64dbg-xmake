add_rules("mode.release", "mode.debug")

add_links(
    "ws2_32", "kernel32", "psapi", "winspool", "gdi32", "ole32", "oleaut32",
    "advapi32", "shell32", "user32", "opengl32", "comdlg32", "shlwapi", "Winmm",
    "iphlpapi", "imm32")

-- ref : https://github.com/xmake-io/xmake/blob/master/xmake/rules/qt/load.lua
-- xmake 没有提供 widget_shared rules
rule("qt.widget_shared")
    add_deps("qt.qrc", "qt.ui", "qt.moc")
    on_config(function(target)
       local function _link(target, linkdirs, framework, qt_sdkver)
            if framework:startswith("Qt") then
                local debug_suffix = "d"
                if qt_sdkver:ge("5.0") then
                    framework = "Qt" .. qt_sdkver:major() .. framework:sub(3) .. (is_mode("debug") and debug_suffix or "")
                else -- for qt4.x, e.g. QtGui4.lib
                    framework = "Qt" .. framework:sub(3) .. (is_mode("debug") and debug_suffix or "") .. qt_sdkver:major()
                end
            end
            return framework
        end
        local function _add_includedirs(target, includedirs)
            for _, includedir in ipairs(includedirs) do
                if os.isdir(includedir) then
                    target:add("sysincludedirs", includedir)
                end
            end
        end
        local qt = target:data("qt")
        -- get qt sdk version
        local qt_sdkver = nil
        if qt.sdkver then
            import("core.base.semver")
            qt_sdkver = semver.new(qt.sdkver)
        else
            raise("Qt SDK version not found, please run `xmake f --qt_sdkver=xxx` to set it.")
        end
        local qt_frameworks = {"QtCore", "QtGui", "QtWidgets", "QtNetwork", "QtWinExtras"}
        for i, framework in ipairs(qt_frameworks) do
            target:add("defines", "QT_" .. framework:sub(3):upper() .. "_LIB")
            target:add("syslinks", _link(target, qt.libdir, framework, qt_sdkver))
            _add_includedirs(target, path.join(qt.includedir, framework))
            _add_includedirs(target, path.join(qt.includedir, framework, qt.sdkver))
            _add_includedirs(target, path.join(qt.includedir, framework, qt.sdkver, framework))
        end
        _add_includedirs(target, qt.includedir)
        _add_includedirs(target, path.join(qt.mkspecsdir, "win32-msvc"))
        target:add("linkdirs", qt.libdir)
    end)

target("zydis_wrapper")
    set_kind("static")
    add_files("x64dbg/src/zydis_wrapper/Zydis/*.c", "x64dbg/src/zydis_wrapper/zydis_wrapper.cpp")
    add_includedirs(
        "x64dbg/src/zydis_wrapper",
        "x64dbg/src/zydis_wrapper/Zydis", {public = true})
    add_defines("ZYDIS_STATIC_DEFINE")


target("loaddll")
    before_build(function(target)
        -- 去掉
        -- #pragmacomment(lib, "..\\dbg\\ntdll\\ntdll_x64.lib")
        -- #pragmacomment(lib, "..\\dbg\\ntdll\\ntdll_x86.lib")
        io.gsub("x64dbg/src/loaddll/loaddll.cpp", "#pragma ", "//pragma")
    end)
    set_kind("binary")
    add_files("x64dbg/src/loaddll/*.cpp")
    local compiled_libs = {"ntdll"}
    for i, v in ipairs(compiled_libs) do
        local lib_path = "x64dbg/src/dbg/" .. v
        -- print(string.format("compile %s", lib_path))
        add_includedirs(lib_path)
        add_linkdirs(lib_path)
        add_links(is_arch("x64") and v .. "_x64" or v .. "_x86")
    end

target("x64dbg_bridge")
    set_kind("shared")
    add_defines("BUILD_BRIDGE")
    set_basename(is_arch("x64") and "x64bridge" or "x32bridge")
    add_files("x64dbg/src/bridge/*.cpp", "x64dbg/src/bridge/*.c")
    add_includedirs("x64dbg/src" ,"x64dbg/src/bridge", {public = true})

target("x64dbg_exe")
    set_kind("binary")
    add_files(
        "x64dbg/src/exe/*.cpp",
        "x64dbg/src/exe/*.rc|icon*.rc",
        is_arch("x64") and "x64dbg/src/exe/icon64.rc" or "x64dbg/src/exe/icon32.rc")
    set_basename(is_arch("x64") and "x64dbg" or "x32dbg")
    add_deps("x64dbg_bridge")
    -- /DEF:"signaturecheck.def"
    add_ldflags("/DEF:x64dbg/src/exe/signaturecheck.def", {force = true})

target("x64dbg_launcher")
    -- 只生成 x86
    set_kind(is_arch("x64") and "phony" or "binary")
    add_files(
        "x64dbg/src/launcher/*.cpp",
        "x64dbg/src/exe/*.rc|icon64.rc|icon32.rc")
    set_basename("x96dbg")

target("x64dbg_gui")
    set_kind("shared")
    add_rules("qt.widget_shared")
    add_defines("BUILD_LIB", "NOMINMAX", "UNICODE")
    set_basename(is_arch("x64") and "x64gui" or "x32gui")
    add_files(
        "x64dbg/src/gui/Src/Gui/*.ui",
        "x64dbg/src/gui/Src/Tracer/TraceWidget.ui",
        "x64dbg/src/gui/resource.qrc")
    local src_paths = {
        "x64dbg/src/gui/Src/BasicView",
        "x64dbg/src/gui/Src/Bridge",
        "x64dbg/src/gui/Src/Disassembler",
        "x64dbg/src/gui/Src/Gui",
        "x64dbg/src/gui/Src/Memory",
        "x64dbg/src/gui/Src/QHexEdit",
        "x64dbg/src/gui/Src/Tracer",
        "x64dbg/src/gui/Src/Utils",
        "x64dbg/src/gui/Src"}
    for _, v in ipairs(src_paths) do
        add_includedirs(v)
        add_files(v .. "/*.h", v .. "/*.cpp")
    end
    -- ldconvert
    add_includedirs("x64dbg/src/gui/Src/ThirdPartyLibs/ldconvert")
    add_linkdirs("x64dbg/src/gui/Src/ThirdPartyLibs/ldconvert")
    add_links(is_arch("x64") and "ldconvert_x64" or "ldconvert_x86")
    add_deps("zydis_wrapper", "x64dbg_bridge")

    -- 拷贝依赖库
    after_build(function(target)
        local qt = target:data("qt")
        local deps_path = path.join("x64dbg/deps", is_arch("x64") and "x64" or "x32", "*")
        print(string.format("copy deps %s to %s", deps_path, "$(buildir)/$(os)/$(arch)/$(mode)"))
        os.cp(deps_path, "$(buildir)/$(os)/$(arch)/$(mode)")
        local windeployqt = qt.bindir .. "/windeployqt.exe"
        local mode = is_mode("debug") and "--debug" or "--release"
        os.execv(windeployqt, {mode, "--force", target:targetfile()})
    end)

target("x64dbg_dbg")
    set_kind("shared")
    set_basename(is_arch("x64") and "x64dbg" or "x32dbg")
    add_defines("BUILD_DBG")
    add_includedirs(
        "x64dbg/src",
        "x64dbg/src/dbg",
        "x64dbg/src/dbg/analysis",
        "x64dbg/src/dbg/btparser",
        "x64dbg/src/dbg/commands",
        "x64dbg/src/dbg/msdia",
        "x64dbg/src/dbg/WinInet-Downloader")
    add_files(
        "x64dbg/src/dbg/*.cpp|log.cpp",
        "x64dbg/src/dbg/analysis/*.cpp",
        "x64dbg/src/dbg/btparser/btparser/*.cpp|main.cpp",
        "x64dbg/src/dbg/commands/*.cpp",
        "x64dbg/src/dbg/msdia/*.cpp",
        "x64dbg/src/dbg/WinInet-Downloader/*.cpp")

    local compiled_libs = {"ntdll", "lz4", "TitanEngine", "jansson", "dbghelp", "DeviceNameResolver", "XEDParse", "LLVMDemangle"}
    for i, v in ipairs(compiled_libs) do
        local lib_path = "x64dbg/src/dbg/" .. v
        add_includedirs(lib_path)
        add_linkdirs(lib_path)
        add_links(is_arch("x64") and v .. "_x64" or v .. "_x86")
    end
    add_deps("zydis_wrapper", "x64dbg_bridge")