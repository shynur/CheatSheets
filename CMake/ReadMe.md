# Generator

指定使用 which generator:
- `CMAKE_GENERATOR` 环境变量;
- `cmake -G` option.

## Config

使用 single-configuration generator 时, config 可以这么指定:
- `CMAKE_BUILD_TYPE` 环境变量;
- `cmake -DCMAKE_BUILD_TYPE=<config>`.
而 multi-configuration generator 可以用:
- `cmake --build <build_system_dir> --config` option.

# Command Line Options
## `-S`:

```cmake
cmake -S <root_CML_dir>  
```

默认是 `$PWD`.

## `-B`

```cmake 
cmake -B <build_system_dir>
```

默认是 `$PWD`.
默认情况下, artifacts 也被存放在这里.

使用 `--fresh` flag 可以在 re-configure 时刷新 binary directory 中的 build tree.
这会重建 `CMakeCache.txt` 和关联的 `CMakeFiles/`.

## `--build`

```cmake 
cmake --build <build_system_dir>
```

在指定目录运行 build system.
如果 CMLs 有改动, cmake 会首先按需自动更新 build system.

> CML 中的某些改动, 例如将 `add_executable()` 转移到 子目录 并通过 `add_subdirectory()` 的方式包含,
> 且 子目录 和 executable 同名, 会导致 build system 目录中先前输出的 executable 的名字 和 子目录名 冲突.
> 这种情况下就需要额外的 `--clean-first` flag.

## `-P`

```
cmake -P <script.cmake>
```

启用 *script mode*, 告诉 cmake 这只是个脚本, 无意使用 `project()` 命令.

## `-D`

在 configure 时, 创建 cache variable 或修改其值.

它会在任何其它 commands 之前被处理, 所以优先于 `option()` 和 `set(CACHE)`.

## `-t`

在 `cmake --build` 时, 指定 target.
默认是 `all`.

## `--preset`

载入指定的 CMake Preset[^CMakePresets.json].

Command line arguments 可以和 preset 混合使用, 前者优先级更高.

## `--install`

```bash
# single-configuration generator
cmake --install <build> --prefix <install>
```

### CMake Preset

Preset 能表达整个 CMake workflow (从 configuration, 到 building, 一直到 installing 软件包).

#### Macro

|       macro       |     expansion     |
| :---------------: | :---------------: |
|    `sourceDir`    |    project root   |
| `sourceParentDir` | `${sourceDir}/..` |

#### 示例

```json
{
    "version": 4,
    "configurePresets": [
        {
            "name": "示例preset", 
            "description": "对这个 preset 的描述",      
            "binaryDir": "${sourceDir}/build.cmake",
            "installDir": "/opt/MyLib",
            "cacheVariables": {
                "CMAKE_CXX_STANDARD": "26",
                "CMAKE_PREFIX_PATH": "/usr/local"
            }
        }
    ]
}
```

# 基础概念
## Modules 

Aka, a CMakeLang file.  需要用 `include()` 引入.

CMake 的标准库位于 CMake 自己的 `Modules/` folder.
这个内置的 folder 是 CMake 在执行 `include()` 时的查找路径之一.

## *target*

Just name, 被开发者用于命名一组 properties.

## *property*

包括但不限于:
- artifact kind (executable, library, header collection, etc);
- 源文件;
- include directories;
- 可执行文件名 或 库名;
- 依赖;
- flags (of compiler/linker).

### `HEADER_SETS` `INTERFACE_HEADER_SETS`

当一个 target 被构建时, 它使用自己的 non-interface properties (e.g., `HEADER_SETS`),
以及 dependencies 的 interface properties (e.g., `INTERFACE_HEADER_SETS`).

> 使用 `target_sources()` 时, 它会修改 target 的 properties.
> 其中 private files 会被添加到 `HEADER_SETS`,
> interface files 会被添加到 `INTERFACE_HEADER_SETS`,
> public files 在这两个 properties 中都会被添加.

### `DEPRECATION`

附加弃用通知.
只能通过 `set_target_properties()` 来设置.

### `ADDITIONAL_CLEAN_FILES`

指明需要被 cmake 的 `clean` target 额外移除的文件.

## *scope keyword*

描述 property 对 target 的可用性.

### `PRIVATE`

形容一个 property 仅对 attached target 可见.

(一个 private property 又称 non-interface property.)

### `INTERFACE`

形容 target (dependency) 的 property 仅对 dependant (which *links* dependency) 可见.
甚至 target 自己也无法访问这个 property.

> 一个 header-only library 就是一组 `INTERFACE` properties 的集合.
> 因为 header-only library 根本不需要 build, 因此无需访问自身拥有的文件.

### `PUBLIC`

既 `PRIVATE` 也 `INTERFACE`.

## Cache Variables

这类 variables 是 globally visible 的, 并且是 *sticky* 的 (其值一旦 set 就难以更改).

在 project mode 下, cache variables 是 "locked in" 的 -- 除非显示指定, cmake 会在 re-configure 时保持 cache variables 的值.
但是它们可以被 *shadowed* by normal variables.

### 手动修改
#### `CMakeCache.txt`

(该文件会记录 option 的 类型, 但这也只是一个 hint.)

```
// 描述
<选项名>:<类型>=<值>
```

修改后重新 build 即可.

#### `cmake -D`

```bash
cmake -B build/ -DMyOption=NewValue
cmake --build build/
```

## Generator Expression

延迟求值的条件表达式.

> Generator expression 在底层 build system 被生成时求值.

常用于 multi-config generator 和 复杂的依赖注入系统, 例如:

```cmake
target_compile_definitions(MyApp PRIVATE MYAPP_BUILD_CONFIG=$<CONFIG>)
```

注入 `cmake --config <config>`.  (对于 single-config generator, 可以用 `CMAKE_BUILD_TYPE` 指定.)

# Important Variables
## `CMAKE_CURRENT_SOURCE_DIR`

当前 CML 的所属目录.

CMake 的世界中, 路径名要么是 absolute 的, 要么就是 relative to 该 variable.

## `ARGV` `ARGN`

`ARGV`: 所有 arguments 组成的 list;
`ARGN`: 相当于 "...rest".

## `CMAKE_<LANG>_STANDARD` option

对于 C++, 不同的语言标准可能会导致 ABI incompatibility.
例如, 使用旧标准的代码可能会通过 polyfill 实现新标准的标准库.

将 `CMAKE_CXX_STANDARD` 作为 option 使用, 可以确保所有 targets 都在相同的 language standard 下构建.

> CMake 向 packager 提供了一些 **important** normal/cache variables 用来控制 build.
> 一些 decisions (如 compilers, default flags, search locations for packages) 皆由 CMake 自己的 configuration variables 控制.
>
> 开发者不应该在 CMLs 中 shadow 这类变量.
> 除非有充分的理由, 不要 `set()` `CMAKE_*` [^configuration_variable_prefix] globals.

注意: 不要全局设置 `CMAKE_<LANG>_STANDARD`, 不要推翻 packager 关于使用哪种 language standard 的决定.

## `CMAKE_<LANG>_COMPILER_FRONTEND_VARIANT`

兼容多个编译器前端的常用写法:

```cmake
if(
  (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC") OR
  (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
)
  target_compile_options(MyTarget PRIVATE /W3)
elseif(
  (CMAKE_CXX_COMPILER_ID STREQUAL "GNU") OR
  (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
)
  target_compile_options(MyTarget PRIVATE -Wall)
endif()
```

## `CMAKE_<LANG>_FLAGS`

用于传递编译器前端的 flags.
`-Werror` 适合在 CI/CD 中通过该 variable 传递, 而不适合写死在 CML 中.

## `CMAKE_CURRENT_LIST_DIR`

当前被执行的 CMakeLang 文件的所在目录.

# Commands
## Target Commands 

用于修改 target 的 property. 
这些 properties 描述了构建软件所需的 如 sources, compile flags, 和 output names 等事物; 
或者是 consume 这个 target 所需的 如 header includes, library directories, 和 linkage rules 等事物.

### `get_target_property()` `set_target_properties()`

```cmake
add_library(Me)
set_target_properties(Me
    PROPERTIES   
        Name "Xie Qi"
        Age  23
)
get_target_property(MyName Me Name)
get_target_property(MyAge  Me Age)
```

### `target_compile_features()`

描述 build 所需的最小 feature set.

```cmake
# 如果 C++20 特性仅在 implementation 文件中使用
target_compile_features(MyTarget PRIVATE cxx_std_20)  
```

如果 `CMAKE_CXX_STANDARD` 高于 `cxx_std_YY`, 或 compiler 默认已经提供了所需的 language standard,
则无事发生.  否则, cmake 会添加必要的 flags 以启用所需的 standard.

### `target_link_libraries()`
#### link a vendored pre-compiled binary 

```cmake
# /opt/VendorLib/

add_library(VendorLib INTERFACE)
# 这是 `INTERFACE` library, 它没有 build requirement, 
# 因为 vendor 提供的已经是构建完成的 binary.

target_include_directories(VendorLib INTERFACE include/)  # 传递 `-L` 参数.
target_link_directories(VendorLib INTERFACE lib/)         # 传递 `-I` 参数.

target_link_libraries(VendorLib INTERFACE libVendor.a)  # 传递 `-l` 参数.
# 此处 libVendor.a 不是一个 target name, 
# 因此 cmake 会直接将这个 string 添加到 link line, 作为需要被 link 到 build 中的 library.
```
### `target_sources()`
#### header

```cmake
target_sources(MyTarget
    INTERFACE  # 仅举例
        FILE_SET   myHeaders
        TYPE       HEADERS
        BASE_DIRS  include/
        FILES      a.h b.h
)
```

- 省略 `TYPE` 字段, 则其字段值视为 `FILE_SET` 的字段值. E.g., `FILE_SET HEADERS`.
- 省略 `BASE_DIRS` 字段, 则其字段值视为 `./`.
- 通常 compiler 会提供 dependency scanner 以发现被依赖的 headers, 这样虽然省略 `FILES` 也能正确地实行增量构建.  如有意向 install 这些 headers (e.g., public headers of a library), 则需显式列出 `FILES` 字段.

## `cmake_minimum_required()`

**绝对是 root CML 第 1 个 command.**

## `project()`

该 command 执行各种检查以确保环境适合构建软件.
例如, 检查 compiler 等构建工具, 探查 host 和 target machine 的字节序等属性.

(它可能不是 root CML 中的第 2 个命令.)

## `if()`
### 真值表

| falsy |       truthy      | 
| :---: | :---------------: |
| False |       True        | 
|  Off  |        On         |
|   No  |        Yes        |
|   0   | *non-zero number* |
| Ignore |                  |
| NotFound |                |
| *null string* |           |

### variable check

仅当传递给 `if()` 的是 unquoted string 时, `if()` 会检查这是否表示一个 variable.

## `include()`

像 macro 一样立即在 caller 的 context 中执行.

> 通常将一些小型 cmake 函数或工具 放到独立于 project 的 CMLs 之外的 `.cmake` 文件中,
> 以与 build system 分离.
>
> Traditionally, 这类 `.cmake` 文件 live in project 根目录下的 `cmake/` 文件夹中. 

## `option()`

```cmake
option(CacheVariable "描述" ON)
```

创建 cache variable.

## `set()`
### Cache Variable 
#### creation

`set()` 可以创建 cache variable:

```cmake
set(CacheVariable "初始值" CACHE STRING "")
```

但无法修改 already created cache variables.

#### shadow

```cmake
option(MyVar "" 1)
set(MyVar 2)
message(${MyVar})  # ==> 2
unset(MyVar)
message(${MyVar})  # ==> 1
```

## `add_library()`
### Type of Library

`add_library()` 的第二个参数 (type of library) 是可选的:

- `STATIC`: 
  Archive of objects.  对其它 target 执行 link 时使用.

- `SHARED`: 
  Linked by other targets, loaded at runtime;

- `MODULE`:
  Plugin.
  无法直接被其它 target link, 但能在运行时 (使用类似 `dlopen` 的功能) 动态加载;

- `OBJECT`: 
  Objects 本身是无法被 transitively link 的.
  如果一个 object library 出现在某个 target 的 `INTERFACE_LINK_LIBRARIES` 中, dependent which links that target 是不会看到 objects 的.
  此时 object library 表现得就像 `INTERFACE` library. 
  一般来说, object library 只适合以 `PRIVATE`/`PUBLIC` 的形式在 `target_link_libraries()` 中被 consume.

- `INTERFACE`: 
  它们自己不 build 也不生成任何 artifact, 而是用于向 dependent 指示 usage requirement.
  **`INTERFACE` library 的 property 只能是 interface 的.**

- `IMPORTED`

推荐的做法是留空, 这样 cmake 就会根据 `BUILD_SHARED_LIBS`[^BUILD_SHARED_LIBS_default] 决定创建 `STATIC` 还是 `SHARED` library.

## `add_custom_target()`

| | |
| :---: | :---: |
| `COMMAND` parameter | 调用的程序名既可以是 build environment 中的 executable 也可以是 CMake executable target name |
| `VERBATIM` keyword  | effectively mandatory                                                                   |

### source generation

```cmake
add_executable(GenCode)
target_sources(GenCode PRIVATE GenCode.cpp)

add_custom_command(
  OUTPUT generated.cpp
  COMMAND GenCode -i input.txt -o generated.cpp
  DEPENDS GenCode input.txt
  VERBATIM
)

add_library(GeneratedObject OBJECT)
target_sources(GeneratedObject PRIVATE Generated.cxx)
```

### header-only file generation

由于 **`INTERFACE` library itself 没有 build step**, 
通常需要用 `add_custom_target()` 创建一个 intermediary target 将 header generation 加到 build stage.

```cmake
add_library(GeneratedLib INTERFACE)
add_dependencies(GeneratedLib RunGenerator)   # 强制 custom target 在任何 dependant 之前运行.
target_sources(GeneratedLib
    INTERFACE
        FILE_SET   HEADERS
        BASE_DIRS  ${CMAKE_CURRENT_BINARY_DIR}  # 当前在 build tree 中用于放置 artifact 的位置.
        # FILES      ${CMAKE_CURRENT_BINARY_DIR}/generated.h  # 该行 unnecessary for the build.
)
add_custom_target(RunGenerator DEPENDS generated.h)
add_custom_command(
    OUTPUT generated.h
    COMMAND header_generator
    DEPENDS header_generator
    VERBATIM
) 
```

## `add_test()`

```cmake
option(BUILD_TESTING "惯用的 test flag name" ON)
if(BUILD_TESTING)  
    enable_testing()  # 在 root CML 中调用.
endif()
add_test(NAME MyTest COMMAND MyExecutable arg1 arg2)
```

以上 commands 允许 cmake 在 build folder 中 setup 必要的 infrastructure,
供 CTest 发现/运行/汇报 测试用例.
CTest 是一个 task launcher which 运行 command 并检查退出码, 用法 (single-configuration generator):

```bash
ctest --test-dir build
ctest --test-dir build -R <regexp>  # 仅运行 name 匹配的 tests.
```

## `install()`

所有 installation 都借助 `install()` 这一单一 command, which 被拆成若干个负责 installation process 各方面的 subcommands.

### `install(TARGETS)`: target-based installation

CMake 将 target-based installation 分类成多种 artifact kinds[^target-based-installation.artifact-kinds],
大多数 artifact kinds 有明确的 default destination 或通过定义 `CMAKE_INSTALL_<dir>`[^cmake-install-dir] 手动指定:

|                           artifact kind                         |          variable          | built-in default |
| :-------------------------------------------------------------: | :------------------------: | :--------------: |
| `RUNTIME`                                                       | `CMAKE_INSTALL_BINDIR`     | `bin`            |
| `LIBRARY`[^artifact-kind.library]                               | `CMAKE_INSTALL_LIBDIR`     | `lib`            |
| `ARCHIVE`[^artifact-kind.archive]                               | `CMAKE_INSTALL_LIBDIR`     | `lib`            |
| `{PUBLIC,PRIVATE}_HEADER`[^artifact-kind.public-private-header] | `CMAKE_INSTALL_INCLUDEDIR` | `include`        |
| `FILE_SET HEADERS`                                              | `CMAKE_INSTALL_INCLUDEDIR` | `include`        |

```cmake
install(
    TARGETS  MyApp MyLib
    FILE_SET HEADERS
    FILE_SET myLibHeaders
)
```

大部分 artifact kinds 都会默认安装而无需在 `install()` 参数中列出, 除了 `FILE_SET`.
因此, 要安装的 `FILES` 必须提供 `FILE_SET` name 以供指代.

### 安装到 default location 的特定 subdirectory 

```cmake
include(GNUInstallDirs)  
install(
    TARGETS MyApp
    RUNTIME 
        DESTINATION ${CMAKE_INSTALL_BINDIR}/SubDir
)
```

(对于 `OBJECT` artifact, 如果没有被指定 `DESTINATION`, 它就会像 `INTERFACE` library 一样只 install headers.)

### `install(EXPORT)`: target export file

简单用 `install(TARGETS)` 会失去 cmake target model.
如果要让其它 project 能从我们提供的 install tree 中 reconstruct our targets,
就需要一个 known as "target export file" 的 CMakeLang file.

```cmake
install(
   TARGETS  MyApp MyLib
    EXPORT  <ExportName>
  FILE_SET  HEADERS
)
include(GNUInstallDirs)
install(
       EXPORT  <ExportName>
  DESTINATION  ${CMAKE_INSTALL_LIBDIR}/cmake/<PackageName>/
    NAMESPACE  <PackageName>::
)
install(
    FILES cmake/<PackageName>Config.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<PackageName>/
)
```

向 `install(TARGETS)` 传递一个 export name, 它是一个用于记录我们需要 export 的 installed targets 的 list.
使用这个 list 生成的 target export file 的惯用的路径是 `${CMAKE_INSTALL_LIBDIR}/cmake/<PackageName>/<ExportName>.cmake`.

为了供 `find_package()` 使用, 还需提供 config file:

```cmake
# MyProject/cmake/<PackageName>Config.cmake

# 导入 exported targets
include(${CMAKE_CURRENT_LIST_DIR}/<ExportName>.cmake)

# 传递依赖关系
include(CMakeFindDependencyMacro)
find_dependency(AnotherPackage)
```

### 导出 version file

CMake 会先检查 version file 再查看 config file.

创建 version file 再用 `install(FILES)` 安装它:

```cmake
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/<PackageName>ConfigVersion.cmake
    COMPATIBILITY ExactVersion
)
include(GNUInstallDirs)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/<PackageName>ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<PackageName>/
)
```

| | |
| :---: | :---: |
| `write_basic_package_version_file(COMPATIBILITY)` | `AnyNewerVersion`, `SameMajorVersion`, `SameMinorVersion`, or `ExactVersion` |
| `write_basic_package_version_file(ARCH_INDEPENDENT)` | optional |
| `write_basic_package_version_file(VERSION)` | 默认和 `project(VERSION)` 一致 |

## Find Dependency
### Packaged
#### `find_package()`

未加 `REQUIRED` 时, `find_package()` 通过 `<PackageName>_FOUND:BOOL` 报告是否找到 package.

### Unpackaged
#### `find_path()`

假设 `Unpackaged.h` 位于 `${CMAKE_PREFIX_PATH}/include/Unpackaged/Unpackaged.h`:

```cmake
find_path(UnpackagedIncludeFolder Unpackaged.h REQUIRED
    PATH_SUFFIXES
        Unpackaged/
)
target_include_directories(MyTarget 
    PRIVATE
        ${UnpackagedIncludeFolder}
)
```

### Subdirectory 
#### Target Alias

直接 `add_subdirectory()` 依赖的 project 而不 find.
但这样就不会像 `install(NAMESPACE)` 那样提供 namespace 了.

Dependency project 的作者可以用 `add_executable(ALIAS)`/`add_library(ALIAS)` 创建 target alias 供 dependant 使用:

```cmake
add_library(MyLib)
add_library(<PackageName>::MyLib ALIAS MyLib)
```

# Introspection
## `check_include_files()`

查看某个 header 在特定的 platform 是否可用.
这特别适合检查 system and intrinsic headers, which may 不是由 特定的 package 提供 但仍然被期待在 build environment 中可用.

```cmake
include(CheckIncludeFiles)
check_include_files(sys/socket.h HAVE_SYS_SOCKET_H LANGUAGE CXX)
if(HAVE_SYS_SOCKET_H)
    # ...
endif()
```

## `check_source_compiles()`

默认情况下 `CheckSourceCompiles` build 并 link 一个 executable, 
因此供 introspect 的代码须提供 `main` 函数.

```cmake
include(CheckSourceCompiles)
check_source_compiles(CXX
    [[
        typedef double v2df __attribute__((vector_size(16)));
        int main() {
            __builtin_ia32_sqrtsd(v2df{});
        }
    ]]
    HAS_GNU_BUILTIN
)
if(HAS_GNU_BUILTIN)
    # ...
endif()
```

## `check_ipo_supported()`

```cmake
include(CheckIPOSupported)
check_ipo_supported()  # fatal error if IPO isn’t supported
set_target_properties(MyApp
    PROPERTIES
        INTERPROCEDURAL_OPTIMIZATION TRUE
)
```

最好提供外部机制来决定是否启用 IPO, 而不是在项目内决定.  因为:
- CMake 并不了解每个 compiler 上的 IPO/LTO flag, 
  最好单独针对特定的 toolchain 手动调优 (presets, `-D` flags, toolchain files, etc).
- 在 target 上设置 `INTERPROCEDURAL_OPTIMIZATION` 并不会影响 上下游的 targets, 
  IPO 仅在其它 target 也被 compiled appropriately (例如, 也使用了 IPO) 时才生效.

更好的写法:

```cmake
option(MyProject_ENABLE_IPO "是否尝试启用 IPO" ON)
if(MyProject_ENABLE_IPO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result OUTPUT output)
    if(result)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
        # Normally 不鼓励在 project 里 set 'CMAKE_' variable,
        # 但在需要控制由 'CMAKE_' variable 决定的 project-wide 行为时, 
        # 提供 option 是一个不完美但可接受的方案, 它使此处的 set 变成可选的. 
    else()
        message(WARNING "当前 toolchain 不支持 IPO: ${output}")
    endif()
endif()
```

________________________

<footer>
    <small>
        Copyright &copy; 2025-2026  <a href='https://github.com/shynur'>shynur</a> &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.  <br />
        This file is licensed under <a href='https://creativecommons.org/licenses/by-nc-nd/4.0/' title='Attribution-NonCommercial-NoDerivatives 4.0 International'>CC BY-NC-ND 4.0</a>.
        因此也不允许以任何形式拿去训练商业或闭源的 AI/ML 模型.
    </small>
</footer>

[^configuration_variable_prefix]: 按照惯例, configuration variable name 以其 provider 作为前缀, 例如 `<PROJECT>_`.

[^CMakePresets.json]: CMake Presets 来自 `CMakePresets.json`/`CMakeUserPresets.json`, 后者不应被纳入 version control.

[^BUILD_SHARED_LIBS_default]: CMake 默认没有 define `BUILD_SHARED_LIBS`, 这意味着 `add_library` 默认产出 `STATIC` library.

[^target-based-installation.artifact-kinds]: `ARCHIVE`, `LIBRARY`, `RUNTIME`, `OBJECT`, `FRAMEWORK`, `BUNDLE`, `{PUBLIC,PRIVATE}_HEADER`/`RESOURCE`, `FILE_SET <set-name>`.

[^artifact-kind.library]: Shared libraries (`.so`), modules, and other dynamically loadable objects.  并非 MS-Windows 的 DLL 文件 (`.dll`) 或 macOS framework.

[^artifact-kind.archive]: Static libraries (`.a`/`.lib`), DLL import libraries (`.lib`), and a handful of other "archive-like" objects.

[^artifact-kind.public-private-header]: Typically used with macOS frameworks.

[^cmake-install-dir]: CMake 默认不 define `CMAKE_INSTALL_<dir>`s.  如果 project 希望将 artifact 安装到其原本默认位置的 subdirectory 那对应的 `CMAKE_INSTALL_<dir>` 就必须已定义 (这通过 `include(GNUInstallDirs)` 实现).

<!-- Local Variables: -->
<!-- markdown-fontify-code-blocks-natively: t -->
<!-- display-line-numbers: t -->
<!-- End: -->
