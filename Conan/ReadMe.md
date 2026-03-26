# ConanFile (`conanfile.py`)

## consume

```python
import os
import conan, conan.tools.cmake, conan.errors, conan.tools.files, conan.tools.cmake
class CompressorRecipe(conan.ConanFile):
    settings = 'os', 'compiler', 'build_type', 'arch'  # project-wide variables about binary configuration
    generators = (
        'CMakeDeps',       # 生成信息: 依赖库被安装在了哪里
        'CMakeToolchain',  # 声明使用 CMake toolchain 的方式来传递 build information
    )  # 生成用于帮助 compiler 或 build system 查找依赖, 并构建项目所需的文件.
    def requirements(self):
        '''
        使用 version range 时, 优先使用 cache 中满足条件的版本; 'conan {install,create} --update' 无此限制.
        '''
        self.requires('zlib/[~1.3]')  # 表示 v1.3 系列的最新可用版
        self.requires('poco/[^1.14]')  # 等价于: ~1 AND >=1.14
    def build_requirements(self):
        '''此处声明的 tool 只适用于构建当前的项目;
        如果要构建 依赖项 (比如 '[requires]' 中所列), 则要求本机有已安装的 toolchain.
        '''
        # 'self.tool_requires' 对应于 conanfile.txt 中的 '[tool_requires]',
        # 它会自动调用 VirtualBuildEnv generator.
        self.tool_requires('cmake/3.27.9')
    def layout(self):
        '''指定 --output-folder 等的参数.'''
        if 使用等价的手写形式 := False:
            multi: bool = self.settings.get_safe("compiler") == 'msvc'
            if multi:
                self.folders.generators = os.path.join('build', 'generators')
                self.folders.build = 'build'
            else:
                # Conan 生成 auxiliary files (CMake toolchain 和 CMake dependencies files) 的位置:
                self.folders.generators = os.path.join('build', str(self.settings.build_type), 'generators')
                self.folders.build = os.path.join('build', str(self.settings.build_type))
        else:
            conan.tools.cmake.cmake_layout(self)
    def validate(self):
        '''conanfile.py 被 load 时会调用本方法'''
        if self.settings.build_type == 'Release':
            raise conan.errors.ConanInvalidConfiguration('垃圾代码用了 UB 不能 -O3 编译')
    def generate(self):
        '''执行 conan install 时, 将 资源文件 从 dependency 的 resdirs 拷贝到 sourceDir 下的指定目录'''
        return
        # 此处仅作为示例:
        dep = self.dependencies['<依赖项的名字>']
        conan.tools.files.copy(
            self,
            '*',
            dep.cpp_info.resdirs[0], os.path.join(self.source_folder, '<目标目录>')
        )
    def build(self):
        '''将 'conan install' + cmake + make 操作打包成一条 conan build 命令'''
        cmake = conan.tools.cmake.CMake(self)
        cmake.configure()
        cmake.build()
```

```bash
conan install . --build=missing --settings=build_type=Debug
bash -c '. ./build/*/generators/conanbuild.sh; cmake --preset conan-debug -S . && cmake --build --preset conan-debug'
bash -c '. ./build/*/generators/conanrun.sh; ./build/*/<可执行文件>'
```

或

```bash
conan build .  # P.S., 它接受传递给 'conan install' 的参数.
bash -c '. ./build/*/generators/conanrun.sh; ./build/*/<可执行文件>'
```

### Dependencies Conflict

#### 间接依赖

```python
def requirements(self: conan.ConanFile):
    self.requires('package_required_by_dependancies/1.9', override=True)
    # 如果多个 直接/间接 依赖项依赖了同一个 package 的不同版本,
    # 则可以使用 override=True 来强制指定版本.
    # 这不会引入新依赖项, 只是用来覆盖可能会用到的 package 的版本号而已.
```

#### 直接依赖

```python
def requirements(self: conan.ConanFile):
    self.requires('package_required_by_self/1.9', force=True)
```

### `[tool_requires]`

```bash
$ conan install . --settings=build_type=Debug --build=missing
$ bash -c '. ./build/conanbuild.sh; cmake --version'
cmake version 3.27.9
```

## create

```python
# 可以使用 'conan new cmake_lib -d name=mylib -d version=0.1' 生成一个 conanfile.py 模板.
import os, conan, conan.tools.cmake, conan.tools.files, conan.tools.files.symlinks, conan.tools.scm
class mypkgRecipe(conan.ConanFile):
    name = 'mypkg'
    package_type = 'library'

    # Binary Configuration
    settings = 'os', 'compiler', 'build_type', 'arch'           # project-wide configuration
    options = {'shared': [True, False], 'fPIC': [True, False]}  # package-specific configuration
    default_options = {'shared': True, 'fPIC': True}

    exports_sources = 'CMakeLists.txt', 'src/*', 'include/*'

    def set_version(self):
        if self.version:
            return  # 已从 CLI '--version' 读取版本号.
        if 使用VERSION文件 := False:
            self.version = conan.tools.files.load(self, 'VERSION.txt')
        elif 使用GitTag := False:
            git = conan.tools.scm.Git(self)
            tag = git.run('describe --tags')
            self.version = tag
        self.version = self.version.lstrip('v')
    def config_options(self):
        if self.settings.os == 'Windows':
            del self.options.fPIC  # 或👇
            self.options.rm_safe('fPIC')
    def configure(self):
        if self.options.shared:
            self.options.rm_safe('fPIC')  # 构建 lib*.so 时无视 fPIC 选项的值.
    def layout(self):
        '''指定源码和产物的目录结构.
        包括由 self.generate 生成的文件.
        '''
        conan.tools.cmake.cmake_layout(self)
    def generate(self):
        deps = conan.tools.cmake.CMakeDeps(self)
        deps.generate()  # 如果没有依赖项, 可以不调用 CMakeDeps.  它为 CMake 生成找到依赖项所需的配置文件.
        tc = conan.tools.cmake.CMakeToolchain(self)
        tc.generate()  # 创建 'conan_toolchain.cmake', 用于将 settings 和 options 转成 CMake 语法.
    def build(self):
        '''将 '-DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake' 传递给 CMake 并调用'''
        cmake = conan.tools.cmake.CMake(self)
        cmake.configure()
        cmake.build()
    def package(self):
        '''将 artifacts (headers, libraries, etc.) 从 build folder 复制到最终的 package folder'''
        cmake = conan.tools.cmake.CMake(self)
        cmake.install()  # Conan 会设置 CMAKE_INSTALL_PREFIX 使其指向 self.package_folder.
        conan.tools.files.copy(
            self,
            'LICENSE',
            src=self.source_folder,
            dst=os.path.join(self.package_folder, 'licenses'),
        )  # Conan package 的常见约定.
        if 不使用CMake安装 := False:
            conan.tools.files.copy(
                self,
                pattern='*.h',
                src=os.path.join(self.source_folder, 'include'),
                dst=os.path.join(self.package_folder, 'include'),
            )
            conan.tools.files.copy(
                self,
                pattern='*.dll',
                src=self.build_folder,
                dst=os.path.join(self.package_folder, 'bin'),
                keep_path=False,
            )
        conan.tools.files.symlinks.absolute_to_relative_symlinks(
            self, self.package_folder
        )  # 将 package folder 中的 absolute symlinks 转成 relative symlinks 从而 make package relocatable.
    def package_info(self):
        '''提供 供 generator (e.g., CMakeDeps) 所生成的文件使用, 以便 consumer 使用'''
        self.cpp_info.libs = ['mypkg']  # 要求 consumer 必须 link mypkg.
        self.cpp_info.libdirs     = [  'lib'  ]  # by default
        self.cpp_info.includedirs = ['include']  # by default
```

### 创建 package

```bash
conan create . --build=missing --settings=build_type=Debug  # P.S., 它接受传递给 'conan install' 的参数.
```

### 声明 CMake target 的 name

```cmake
# consumer
target_link_libraries(example Hello::hello)
```

```python
def package_info(self: conan.ConanFile):
    self.cpp_info.components['hello'].set_property('cmake_target_name', 'Hello::hello')  # TODO: test
```

### 声明需要 link 的 library 的 name

```cmake
add_library(hello)
if (BUILD_SHARED_LIBS)
    set_target_properties(hello PROPERTIES OUTPUT_NAME hello-shared)
else()
    set_target_properties(hello PROPERTIES OUTPUT_NAME hello-static)
endif()
```

```python
def package_info(self: conan.ConanFile):
    if self.options.shared:
        self.cpp_info.libs = ['hello-shared']
    else:
        self.cpp_info.libs = ['hello-static']
```

### test

```cmake
if (NOT BUILD_TESTING STREQUAL OFF)
    add_subdirectory(test/)
endif()
```

```python
def build_requirements(self: conan.ConanFile):
    '''声明 test dependencies'''
    self.test_requires('gtest/1.17.0')
def build(self: conan.ConanFile):
    import os
    import conan.tools.cmake
    cmake = conan.tools.cmake.CMake(self)
    cmake.configure()  # 若 Conan option tools.build:skip_test=True, 则 Conan 会向 CMake 注入 BUILD_TESTING=OFF 选项.
    cmake.build()
    if not self.conf.get(
        'tools.build:skip_test',
        default=False,
    ):
        test_folder = os.path.join('test/')
        if self.settings.os == 'Windows':
            test_folder = os.path.join('test/', str(self.settings.build_type))
        self.run(os.path.join(test_folder, 'test_example.exe'))
```

#### 跳过测试

```bash
conan create . -c tools.build:skip_test=True
```

### Build System

#### Autotools

```python
def generate(self: conan.ConanFile):
    tc = conan.tools.gnu.AutotoolsToolchain(self)
    tc.generate()
    deps = conan.tools.gnu.PkgConfigDeps(self)
    deps.generate()
def build(self: conan.ConanFile):
    autotools = conan.tools.gnu.Autotools(self)
    autotools.autoreconf()
    autotools.configure()
    autotools.make()
```

### Package ID

由 configuration (settings / options / requirements) 生成的 hash 值,
与每次 conan 构建出来的 binary 相关联.

#### Library written in C

如果打包的是 C 编写的库, 则可使用如下代码删去对 package ID 的计算没有意义的 settings:

```python
def configure(self: conan.ConanFile):
    self.settings.rm_safe('compiler.cppstd')
    self.settings.rm_safe('compiler.libcxx')
```

#### Header-only Library

```python
def package_id(self: conan.ConanFile):
    self.info.clear()  # 啥都不考虑
```

### `conan.ConanFile.options`

```python
options = {'with-fmt': [True, False]}
default_options = {'with_fmt': False}
generators = 'CMakeDeps'
def validate(self: conan.ConanFile):
    import conan.tools.build, conan.errors
    if self.options.with_fmt:
        conan.tools.build.check_min_cppstd(self, '11')
        if not self.dependencies['fmt'].options.shared:
            raise conan.errors.ConanInvalidConfiguration('你怎么不用动态库呢?')
def requirements(self: conan.ConanFile):
    if self.options.with_fmt:
        self.requires('fmt/8.1.1')
def generate(self: conan.ConanFile):
    import conan.tools.cmake
    tc = conan.tools.cmake.CMakeToolchain(self)
    if self.options.with_fmt:
        tc.variables['MyLib_WITH_FMT'] = True  # CMake Option
    tc.generate()
```

```bash
conan create . --build=missing --settings=build_type=Debug --options=with_fmt=True
```

### `requirements(self: conan.ConanFile)`

```python
generators = 'CMakeDeps'
def requirements(self: conan.ConanFile):
    self.requires(
        'fmt/8.1.1',
        # 如果 self 库的 INTERFACE headers include 了上方库的 headers,
        # 那么为了 self 库的 consumer 能正确找到上方库的 headers,
        # 需要开启如下选项👇 (<https://github.com/conan-io/conan/issues/19707>):
        transitive_headers=True,
    )
```

### `validate(self: conan.ConanFile)`

```python
def validate(self: conan.ConanFile):
    import conan.tools.build
    conan.tools.build.check_min_cppstd(self, '11')
```

### `source(self: conan.ConanFile)`

该 API 用于实现与 `conan.ConanFile.exports_sources` 类似的功能.

#### 从 zip 文件中提取源码

```python
def source(self: conan.ConanFile):
    import conan.tools.files
    conan.tools.files.get(
        self,
        'https://github.com/conan-io/libhello/archive/refs/tags/0.0.1.zip',
        strip_root=True,  # 如果被压缩的是一个 folder (GitHub 代码压缩包就是这样), 则 folder 内的所有内容都会被 mv 到父文件夹中.
    )
```

#### 从 git 远程仓库 checkout 代码

```python
def source(self: conan.ConanFile):
    import conan.tools.scm
    git = conan.tools.scm.Git(self)
    git.clone(
        url='https://github.com/conan-io/libhello.git',
        target='.',  # clone 到当前目录
    )
    git.checkout('0.0.1')
```

#### 运行任意 shell 命令

可以在函数体中调用 `self.run()` 来执行任意 shell 命令.

### patch

#### 在 `source(self: conan.ConanFile)` 中打 patch

推荐在此处进行 patch 操作.

#### 在 `build(self: conan.ConanFile)` 中打 patch

```python
def build(self: conan.ConanFile):
    import os
    import conan.tools.files
    conan.tools.files.replace_in_file(
        self,
        os.path.join(self.source_folder, 'src', 'hello.cpp'),
        '${{SHARED_OR_STATIC}}', f"{'shared' if self.options.shared else 'static'}",
    )
```

P.S., 在此处修改源码 *will make it more difficult to develop your packages locally*.

## `test_package`

```python
import os
import conan, conan.tools.cmake, conan.tools.build
class mypkgTestConan(conan.ConanFile):
    settings = 'os', 'compiler', 'build_type', 'arch'
    generators = 'CMakeDeps', 'CMakeToolchain'
    def requirements(self):
        self.requires(
            self.tested_reference_str  # ==> mypkg/0.1
        )
    def build(self):
        cmake = conan.tools.cmake.CMake(self)
        cmake.configure()
        cmake.build()
    def layout(self):
        conan.tools.cmake.cmake_layout(self)
    def test(self):
        '''该方法会在 self.build() 之后立即执行.
        它仅会在 test_package recipe 中被调用.
        '''
        if conan.tools.build.can_run(self):  # 用于判断 cross build 的产物是否能在当前环境运行 (Mac M1 能运行 x64 和 ARMv8).
            cmd = os.path.join(self.cpp.build.bindir, 'pkg_example.exe')
            self.run(cmd, env='conanrun')
```

除了在 `conan create` 时自动执行 `test_package` recipe,
还可以在 package 已经存在于 cache 的前提下手动执行 `test_package` recipe:

```bash
conan test test_package/ mypkg/0.1
```

# Profile

一组配置 (e.g., compiler, build configuration, CPU 架构, 静态库/DLL), 用来构建项目.

运行 `conan profile detect --force` 会尝试根据当前环境猜测并生成 default profile.

## 命令

### 获取 profile 的路径

```bash
$ conan profile path default
~/.conan2/profiles/default
```

## 结构

```ini
[settings]
arch=x86_64
build_type=Debug
compiler=gcc
compiler.cppstd=26
compiler.libcxx=libstdc++11
compiler.version=16
os=Linux
```

# Install

从 `conan_server` 拉取 package:

```bash
conan install . --settings=build_type=Debug --build=missing --output-folder=build
```

这会生成一个 `CMakeUserPresets.json`, 包含 Conan 提供的一些 presets.
它还把 `--output-folder` 当成 CMake 的 binaryDir,
因此接下来直接 `cmake --preset conan-debug -S . && cmake --build --preset conan-debug` 即可

## Option

### `shared`

Zlib 的 Conan package 有一个 option 用于指定 static/shared linking, (截至本文编写时) 默认是 `shared=False`.
这可以通过 `--options=<包名/版本>:shared=True` 修改, 它还会自动调用 VirtualRunEnv generator.

```bash
$ conan install . --settings=build_type=Debug --build=missing --output-folder=build --options=\*:shared=True
$ cmake --preset conan-debug -S . && cmake --build --preset conan-debug
$ bash -c '. ./build/conanrun.sh; ldd ./build/<MyCompressor> | grep /.conan2/p/'
libz.so.1 => ~/.conan2/p/b/zlib90a466e748ea9/p/lib/libz.so.1
```

# Conan Home Folder

```bash
[ ~/.conan2/ -ef `conan config home` ]
```

________________________

<footer>
    <small>
        Copyright &copy; 2025-2026  <a href='https://github.com/shynur'>shynur</a> &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.  <br />
        This file is licensed under <a href='https://creativecommons.org/licenses/by-nc-nd/4.0/' title='Attribution-NonCommercial-NoDerivatives 4.0 International'>CC BY-NC-ND 4.0</a>.
        因此也不允许以任何形式拿去训练商业或闭源的 AI/ML 模型.
    </small>
</footer>

<!-- Local Variables: -->
<!-- markdown-fontify-code-blocks-natively: t -->
<!-- display-line-numbers: t -->
<!-- End: -->
