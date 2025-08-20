> `http://localhost:8000/index.html` (只是举例):
>
> ```html
> <!DOCTYPE html>
> <script type='module'><!-- 须用 type=module 告诉浏览器此 script 应该被当做 module 对待.  -->
>     import {sayHi} from './say.js'
>     // 浏览器环境下不允许使用 bare module, 路径必须是 URL 或者相对路径.
>
>     document.body.innerHTML = sayHi('John')
>     alert(import.meta.url)  // 当前 HTML 页面的 URL.
>     console.assert(typeof this == 'undefined')
> </script>
> <script>
>     'use strict'  // 这个例子中开不开启 strict 都一样.
>     console.assert(this === globalThis)
> </script>
> <script nomodule> alert('当前浏览器不支持 module') </script>
> ```
>
> `http://localhost:8000/say.js` (module 仅支持 HTTP(s), `file://` 不行):
>
> ```js
> // module 默认启用 strict mode!
> // 不管被 import (或者以 `<script type=module src='...'>` 的方式) 多少次, 只创建一次 module 实体.
> export function sayHi(user) {return `Hello, ${user}!`}
> alert(import.meta.url)  // 当前 module 文件的 URL.
> ```
>
> Module 默认 deferred, 直到 HTML is fully ready 各 module 才开始按照出现的顺序执行.  <br />
> `<script async type="module">` 会在所需 module 皆被 import 后立即执行, 不等待 HTML.

```js
// 如果只打算访问全局作用域, 务必用 globalThis.eval
> var x = 1
> !function() {
      'use strict'  // 这个例子中开不开启 strict 都一样.
      var x = 2
      globalThis.eval('var x = 3')  // 在全局作用域中执行, 和 'new Function' 一样.
      console.log(x)
  }()
2
> console.log(x)
3
```

```js
// typeof 不会抛出 ReferenceError.
> delete globalThis.o_O
true
> typeof o_O
'undefined'
> 0, function() {
      'use strict'
      return typeof o_O
  }()
'undefined'
```

```js
> var x = 1
> [x, !function() {
      'use strict'
      var x = 2
      eval('var x = 3')  // strict mode 下 eval 有自己的 lexical scope.
      return x
  }()]
[1, 2]
```

```js
> var x = 1
> !function() {
      'use strict'  // 这个例子中开不开启 strict 都一样.
      let x = 2
      eval('x = x + 1')  // eval 可以访问词法作用域.
      console.log(x)
  }()
3
```

```js
// BigInt
> 0n || console.log('BigInt(0) is falsy')
BigInt(0) is falsy
> 3n / 2n  // 和 C 一样的整型封闭运算.
1n
```

```js
// Diacritical Mark & Normalization
> 'S\u0307\u0323'
'Ṩ'
> 'S\u0323\u0307'
'Ṩ'
> [...'S\u0307\u0323'.normalize()]
['Ṩ']
> 'S\u0307\u0323'.normalize() == 'S\u0323\u0307'.normalize()
true
```

```js
// JavaScript 字符串使用 UTF-16 编码, 每个 char 占用 2 个字节.
> '\xA9'          // \xXX - 仅限 ASCII
©
> '\u00A9'        // \uXXXX - 只能表示 U+0000 到 U+FFFF 之间的 Unicode rune
©
> '\uD83D\uDE0D'  // U+{D800..DBFF} U+{DC00..DFFF} - surrogate pair
😍
> '\u{1F60D}'     // 表示任何 Unicode rune - 会被拆成 surrogate pair
😍
```

```js
> const RangePrototype = {
      [Symbol.asyncIterator]() {
          let i = this.begin
          return {
              next: async() => {
                  if (i >= this.end)
                      return {done: true}
                  await {then: res => setTimeout(res, this.interval*1e3)}
                  return {done: false, value: i++}
              }
          }
      }
  }
> for await (
      const i of {
          __proto__: RangePrototype,
          begin: 1, end: 4, interval: 1
      }
  ) console.log(new Date, i)
2025-08-19T04:23:40.662Z 1
2025-08-19T04:23:41.666Z 2
2025-08-19T04:23:42.667Z 3

> const NewRangePrototype = {
      async*[Symbol.asyncIterator]() {
          for (let i = this.begin; i < this.end; ++i)
              yield await new Promise(res => setTimeout(()=>res(i), this.interval*1e3))
      }
  }
> for await (
      const i of {
          __proto__: NewRangePrototype,
          begin: 1, end: 4, interval: 1
      }
  ) console.log(new Date, i)
2025-08-19T07:02:23.123Z 1
2025-08-19T07:02:24.130Z 2
2025-08-19T07:02:25.133Z 3
```

```js
> var g = function*() {
      try {
          yield "请在这里把我退出"
      } finally {
          console.log('会执行到这儿的')
      }
  }()
> g.next()
{done: false, value: "请在这里把我退出"}
> g.return(42)
会执行到这儿的
{done: true, value: 42}
```

```js
> var question = function*generate() {
      try {
          const question = " π 的最后一位是?  "
          console.log(question, yield question)
      } catch (err) {
          console.log(`- 你居然不会!  - ${err.message}`)
      }
  }()
> question.next()
> question.throw(new Error("啊?  我不到啊.."))
- 你居然不会!  - 啊?  我不到啊..
```

```js
// “yield” is a two-way street.
> var questions = function*() {
      console.log(`Answer 1: ${yield 1}`)
      console.log(`Answer 2: ${yield 2}`)
  }()
> questions.next()
> questions.next('X')
Answer 1: X
> questions.next('Y')
Answer 2: Y
```

```js
// Generator Composition
> [
      ...function*() {
          const Range = {
              *[Symbol.iterator]() {
                  for (const i = this.start; i < this.end; ++i)
                      yield i
              }
          }
          yield 1
          yield*{
              __proto__: Range,
              start: 2, end: 5
          }
          yield 5
          yield*[6, 7, 8]
      }()
  ]
[ 1, 2, 3, 4, 5, 6, 7, 8 ]
```

```js
// generator
> var g = function*() { yield 1; yield 2; return 3 }()
> [g.next(), g.next(), g.next(), g.next()]
[
  {done: false, value: 1},
  {done: false, value: 2},
  {done:  true, value: 3},  // 不会出现在 for-of-loop 中.
  {done:  true}
]
```

```js
// AggregateError 存储了若干个 errors:
> Object.getOwnPropertyDescriptors(new AggregateError([new Error(1), new Error(2)]))
{
    errors: {
        value: [Error: 1, Error: 2],
        writable: true, enumerable: false, configurable: true
    }
}
```

```js
new Promise(() => {throw new Error("Whoops!")}),

globalThis.window.addEventListener(
    'unhandledrejection',
    event => {
        alert(event.promise)
        alert(event.reason)
    }
)
```

```js
new Promise(
    resolve => resolve(1)
).then(
    result => ({
        num: result,
        then(resolve, reject) {
            alert(resolve)  // 打印 “function() {[native code]}”.
            setTimeout(() => resolve(this.num * 2), 2000)
        }
    })  // 一个 promise-compatible thenable/awaitable 对象
).then(alert)
```

```js
/* Global Catch */
globalThis.window.onerror = function(
    msg,
    /* 发生 error 的脚本的 URL */ url,
    /* error 的抛出位置 */ line, col,
    error
) {/*...*/}
```

```js
// try 结构
try {} catch {}
try {} finally {/* 无论如何都会执行 */}
try {} catch (e) {} catch () {} finally {}
```

```js
// 所有的内置 Error 都有 name/message property.
try {
    !function() {
        'use strict'
        Math.PI = 3
    }()
} catch (e) {
    console.log(`${e.name}: ${e.message}`)
}
```

```js
/* constructor.prototype */
// function 有默认的 prototype, 其 constructor property 指向 function 自身.
> Object.getOwnPropertyDescriptors(function User() {}.prototype)
{
    constructor: {
        value() {/* Function: User] */},
        writable: true,
        enumerable: false,
        configurable: true
    },
}
// 建议仅修改 prototype, 而非直接覆盖 function.prototype,
// 因为默认的 prototype 有自动设置的 constructor property.
```

- for-in loop 包含 inherited properties;
- `Object.keys/values/entries(obj)` 等只考虑 `obj.hasOwnProperty(propName)` 为 true 的情况.

Non-pure-dictionary 对象的 `__proto__` 在 specification 中被称为 *`[[Prototype]]`*, 它只能是 object (including `null`).

```js
/* Accessor Property */
> var me = {
      name: "shynur", surname: "Xie",
      get fullName() {
          return `${this.name} ${this.surname}`
      },
      set fullName(value) {
          [this.name, this.surname] = value.split(' ')
      },
  }
> Object.getOwnPropertyDescriptor(me, 'fullName')
{
  get() {return /*...*/},
  set(value) {/*...*/},
  enumerable: true,
  configurable: true,
}  // 一个 property 要么是 *data property* 要么是 *accessor property*.
```

```js
Object.preventExtensions({})  // 🈲新建 property
Object.seal({})               // non-extensible, non-configurable
Object.freeze({})             // 🈲任何变更
// preventExtensions < seal < freeze
```

```js
// truly exact copy, clone whatever anything, 精准拷贝
obj => Object.create(
    Object.getPrototypeOf(obj),            // 获取 __proto__
    Object.getOwnPropertyDescriptors(obj)  // 获取 non-inherited properties
)
```

```js
// “flags-aware” way of cloning an object
> !function() {
      'use strict'
      try {
          Object.defineProperties(
              {},
              Object.getOwnPropertyDescriptors(Math)  // 涵盖 *Symbol or non-enumerable* properties.
          ).PI = 3
      } catch (e) {
          console.log([e+''])
      }
  }()
["TypeError: Cannot assign to read only property 'PI' of object '#<Object>'"]
```

```js
/* Property Flag
 * 对象的 *data property* 由 value and 3 attributes (writable, enumerable, 和 configurable) 组成.  */

// 获取 property 的 flag:
> Object.getOwnPropertyDescriptor({}, 'toString')
{
  value() {/* [Function: toString] */},
  writable: true,
  enumerable: false,
  configurable: true
}

// 更新 property flag:
> var arr = [1]
> Object.keys(Object.defineProperty(arr, 0, {enumerable: false}))
[]
> Object.keys(Object.defineProperty(arr, 0, {enumerable: true}))
[1]

// 新建 property:
> var const_x = Object.defineProperty({}, 'x', {enumerable: true, value: 42})  // 未写明的 attributes 默认是 false.
> !function() {
      'use strict'
      try {
          const_x.x = 123
      } catch (e) {
          console.log([e+''])
      }
  }()
["TypeError: Cannot assign to read only property 'x' of object '#<Object>'"]
```

```js
// Function.prototype.bind 可以绑定部分参数.  对于 'function() {...}', 还能设定 this.
function f(a, b, ...c) {return [this, a, b, ...c]}
f.bind('kfc', 'v').bind('this 不能再被 bound 了', 'me', 50)()
// bind 的返回值是 *exotic object*,
// 它的 this binding 是 hard-fixed, 无法被 re-bound.
```

```js
// Method Borrowing (方法借用)
> !function() {
      console.log(
          // arguments 可以借用 Array.prototype 的 方法:
          [].join.call(arguments, '.')
      )
   }(192, 168, 9, 91)
192.168.9.91
```

```js
// wrapper
var o = {
    m(...args) {console.log(...args)}
}
o.m = function(f) {
    return function() {
        /* 某些预处理... */
        return f.apply(this, arguments)
    }
}(o.m)
```

```js
// 设定 function 的 this
function makeMsgTo(text, to) {
    return `${this.name} -> ${to}: ${text}`
}
console.assert(
    makeMsgTo.call({name: 'shynur'}, 'Hello!', 'LL')
    ===  "shynur -> LL: Hello!"
)
console.assert(
    makeMsgTo.apply({name: 'shynur'}, ['Hello!', 'LL'])  // 只接受 array-like, 不接受 iterable.
    ===  "shynur -> LL: Hello!"
)
```

```js
// 浏览器环境中 setTimeout 经过 5 重嵌套之后, 时间间隔被强制设定为 >=4ms :
> setTimeout(
      function() {
          const intervals = []
          let t = performance.now()
          return function f() {
              intervals.push(performance.now() - t)
              console.log(intervals)
              if (intervals.length >= 8)
                  return
              t = performance.now()
              setTimeout(f)
          }
      }()
  )  // Firefox
Array(1) [ 0 ]
Array(2) [ 0, 0 ]
Array(3) [ 0, 0, 0 ]
Array(4) [ 0, 0, 0, 0 ]
Array(5) [ 0, 0, 0, 0, 4 ]
Array(6) [ 0, 0, 0, 0, 4, 16 ]
Array(7) [ 0, 0, 0, 0, 4, 16, 15 ]

// setInterval timer 以 0 延时执行几次任务后, 也会强制设定间隔 >=4ms.
```

```js
var timerDescriptor = setTimeout('console.log(233)', 9999)
clearTimeout(timerDescriptor)  // 取消定时任务
```

```js
// new Function 指定形参的方式有这些:
console.assert( new Function('a, b', 'c', '').length == 3 )
```

```js
// new Function 可以访问可能被 shadow 的全局变量:
> let x = 42
> new Function('x')()
9
> globalThis.x
undefined
```

```js
// 函数参数数量 (除剩余参数)
> ((a, b, c, ..._)=>{}).length
3
```

```js
// Function: contextual name (上下文命名)
> (function() {}).name
""
> function f1() {}; f1.name
"f1"
> var f2 = ()=>{}; f2.name
"f2"
> var f = function g() {}; f.name
"g"
> ((x = ()=>{})=>x.name)()
"x"
> {m() {}}.m.name
"m"
> {f: ()=>{}}.f.name
"f"
```

```js
// var 和 function 声明的全局符号会挂到 globalThis 对象上.
var x = {}
function f() {}
console.assert(
    globalThis.x === x
    && globalThis.f === f
)
```

```js
> var x = null
> var f = function() {
      return function(n) {
          const old_x = x
          if (x === undefined)
              x = 0
          x += n
          console.log(`${old_x} -> ${x}`)
      }

      if (false) {
          var x  // 无论 var 声明语句位于何处, 被声明的变量都会被提升.
      }
  }()
> f(0), f(3)
undefined -> 0
0 -> 3
```

```js
// Spread iterable objects.
[...'𝒳😂']  // 按照 for-of 迭代.
```

```js
// 箭头函数没有自己的 arguments:
(function() {return ()=>arguments})(1,2,3)()
// arguments 是 iterable array-like object.
```

```js
> var me = {
      toJSON() {
          return Object.fromEntries(
              Object.entries(this).map(
                  ([k, v]) => [k, k.startsWith('_') ? undefined : v]
              )
          )
      },
      name: 'shynur',
      _age: 22,
      gender: 'male',
      _gf: 'xml'
  }
> console.log(JSON.stringify(me, null, 4))
{
    "name": "shynur",
    "gender": "male"
}
```

```js
// 自动时间校准
var date = new Date('2002-12-10T00:00:00+08:00')
date.setDate(date.getDate() + 365)  // 并不代表 12 月 375 日, 也不会溢出, 而是时间向后增长.
console.log(date)
```

```js
function printNow() {
    const now = new Date
    const now_str = `本地时间 (UTC${(-now.getTimezoneOffset()/60 + '').replace(/^(?=\d)/, '+')}) 现在是
${now.getFullYear()} 年 ${now.getMonth()+1} 月 ${now.getDate()} 日
星期 ${now.getDay() || 7}
${now.getHours()}:${(now.getMinutes()+'').padStart(2, '0')}:${(now.getSeconds()+'').padStart(2, '0')}.${(now.getMilliseconds()+'').padStart(3, '0')}`

    console.log(now_str)
}
```

```js
var now = new Date  // 当前时间
console.assert(now.getTime() == +now)
new Date(- 24 * 3600e3)             // UNIX 纪元的前一天
new Date(Date.now() - 24 * 3600e3)  // 昨天
;(new Date).getTime() / 1000         // UNIX epoch (秒)
```

```js
/*
 * - 解构 array 可以用 逗号 忽略部分赋值
 * - 解构 array 时等号右侧可以是任何 iterable (本质是 for-of 语法糖)
 */
var [
    /* 1 */ {
        width,
        height: H = prompt("高度"),
        title: menu_title,
        unknown
    },
    /* 2 */ {...obj},
    /* 3 */ q1 = prompt('Q1'), q2 = prompt('Q2'),
    /* 4 */ firstName, , title,
    /* 5 */ ...rest
] = [
    /* 1 */ {
        title: "Menu",
        width: 100,
        height: 200,
    },
    /* 2 */ {a: 1, b: 2},
    /* 3 */ 'A1', ,
    /* 4 */ "Julius", "Caesar", "Consul",
    /* 5 */ "of the Roman Republic", "something else"
].values()
```

```js
// 转换对象
> var prices = { banana: 1, orange: 2, meat: 4 }
> Object.fromEntries(
      Object.entries(prices).map(
          ([k, v]) => [k, 2*v]
      )
  )
{ banana: 2, orange: 4, meat: 8 }
```

```js
> var o = {name: "John", age: 30}

// 从 object 创建 map:
> var m = new Map(Object.entries(o)); m
Map(2) { "name" => "John", "age" => 30 }

// 从 map 创建 object:
> Object.fromEntries(m)
{ name: 'John', age: 30 }
```

```js
// Map 的迭代保留了插入顺序.
console.assert(
        [...(new Map).set(3, 'A').set(1, 'B').set(2, 'C')]
        == '3,A,1,B,2,C'
)
```

```js
// Map.prototype.set 可以链式调用.
var m = (new Map).set(0, 'A').set(1, 'B')
console.assert(m.has(0) && m.has(1))
```

```js
// 获取字符串的 Unicode Point 数量:
console.assert(
    '𝒳😂'.length == 4
    && [...'𝒳😂'].length == 2
)
```

```js
// Array.prototype.includes 使用 [SameValueZero](https://tc39.es/ecma262/multipage/abstract-operations.html#sec-samevaluezero),
// 所以最直观的判等方式是:
console.assert(
        [     0   ].includes(     -0  )
    &&  [   NaN   ].includes(    NaN  )
    &&  [   NaN   ].includes(   -NaN  )
    &&  [  null   ].includes(   null  )
    &&  [undefined].includes(undefined)
    && ![  null   ].includes(undefined)
)
```

```js
// 约定 parameter thisArg 表示传入的 callback 的 this 值.
// E.g., Array.prototype.filter(callbackFn, thisArg)
console.assert(
    ['Qi', 'shynur', 'Bob', 'Alice'].filter(
        function(name) {return name.length >= this},
        new Number(4)
    ) == 'shynur,Alice'
)
```

```js
console.assert(Array.isArray([]))
```

```js
var arr = [1, 2],
    arr_like = {0: 'A', 1: 'B', length: 2},
    arr_like_concatspreadable = {
        0: 'C', 1: 'D',
        length: 2,
        [Symbol.isConcatSpreadable]: true,  // 允许 concat array-like 对象.
    }
console.assert(
    arr.concat(arr_like, arr_like_concatspreadable)
    == '1,2,[object Object],C,D'
)
```

```js
var arr = [1, 2, 3]
console.assert(arr.slice() == '1,2,3')  // 直接调用 'Array.prototype.slice' 可以获取 array 的副本.
```

```js
// new Array().length 是可写的.
var arr = [1, 2, 3, 4, 5]

arr.length = 3  // 截断数组.
console.assert(arr == '1,2,3')

arr.length = 0  // 清空数组.
console.assert(arr == '')
```

```js
// UTF-16 / code point, UCS-2 / code unit
console.assert('🐮'.length == 2)  // JavaScript 中的字符串是按照 code unit (i.e. UCS-2) 进行索引的.
console.assert(
    eval(`'\\u${'🐮'.charCodeAt(0).toString(16)}\\u${'🐮'.charCodeAt(1).toString(16)}'`)
    === '🐮'
)  // String.prototype.charCodeAt 和 String.prototype.fromCharCode 使用 UCS-2.
console.assert(
    eval(`'\\u{${'🐮'.codePointAt(0).toString(16)}}'`)
    == '🐮'
)  // String.prototype.codePointAt 和 String.prototype.fromCodePoint 使用 UTF-16.
```

```js
// Unicode code unit 相关方法:
function get_all_upper_case_letters() {
    let letters = ''
    for (let point = 'A'.charCodeAt(0); point <= 'Z'.codePointAt(0); ++point)
        letters += String.fromCharCode(point)
    return letters
}
console.log(get_all_upper_case_letters())
```

```js
console.assert( Object.is(NaN, NaN))
console.assert(!Object.is(+0, -0))
// 除此以外, 'Object.is' 和 '===' 表现一致.
// ES 标准称 'Object.is' 为 SameValue.
```

```js
// isFinite 检查数字是否正常.
console.assert(isFinite(1) && !isFinite(NaN) && !isFinite(Infinity))
```

```js
console.assert(1.23.toFixed(4) === '1.2300')  // 精确到固定位.
```

```js
> 123456..toString(36)  // 用两个点调用 number 的方法.
'2n9c'
```

```ts
// `binary operator+` 和 与 string/number/symbol 进行 == 比较时, 使用 'default' hint.
var o = {[Symbol.toPrimitive](hint: string) {console.log(hint)}}
o + 1
o == 1
o == '1'
o == Symbol()
// 而 `<` `>` 由于历史原因, 使用 'number' hint.
```

```ts
// 由于历史原因, 如果 toString/valueOf 返回一个对象, 则不会出现 error, 只会表现得像没有定义该方法一样.
// 但是 Symbol.toPrimitive 是严格的:
try {
    +{
        [Symbol.toPrimitive](hint: string) {
            switch (hint) {
                case 'number': return {}
            }
        }
    }
} catch (err: TypeError) {
    console.error(err)
}
```

```js
var o = {'':0}
console.assert(o == '[object Object]')  // 对象的 toString() 默认就返回这个字符串.
console.assert(o.valueOf() === o)  // valueOf() 默认返回自己.
```

```js
var id = Symbol()

// Object.keys/values/entries 和 for-in 等常规枚举方式都会忽略 Symbol-key 和 non-enumerable:
console.assert(Object.keys({[id]:0})+'' === '')
for (const prop in {[id]:0}) {
    console.assert(typeof prop != 'symbol')
}

// 但是 Object.assign 连 symbol key 也会复制:
console.assert(Object.assign({}, {[id]:0})[id] != undefined)
```

```js
// 和 '??' 不一样, '?.' 是一种语法结构.
// 它在短路时返回 undefined, 否则就相当于对 property 的引用 (暗示它还可以用在 delete 后面).
console.assert(null?.prop === null)
var o = {m: ()=>233, i: [996]}
console.log(o.m?.(), o.i?.[0])  // '?.' 还可以和 '()' '[]' 配合使用.
```

```ts
function User(name: string) {
    if (name)
        this.name = name
    else
        return {default_name: 'Godzilla'}  // 被 new 时, 如果 return 后跟一个 non-primitive, 则返回该 object 而不是 this;
    return null                            // 否则, 立即返回 this.
}
console.log(new User)
console.log(new User('shynur'))
```

```js
// 一种省略 constructor 调用中的 'new' 的写法.
var User = function User(name) {
    if (new.target === undefined)
        return new User(name)
    console.assert(new.target == arguments.callee)
    this.name = name
}
```

```js
const a = []
for (const e of [1, 1n, true, '', Symbol(), undefined]) {
    console.assert(typeof e != 'object')
    a.__proto__ = e  // 将 non-object 赋给 __proto__ property 会被忽略.
    console.assert(a.__proto__ === Array.prototype)
}
```

```js
// 尽量不要在 non-arrow function 里使用 this, 这在 (non-)strict modes 下行为不一致.
!function() {              console.log(this)}()  // this === globalThis
!function() {'use strict'; console.log(this)}()  // this === undefined
```

```js
var o = {
    i: 0,
    f: function() {return ++this.i},
    m() {return ++this.i},  // 方法定义使用 method shorthand, 和简单地把 function 赋给 property 有细微区别.
}
```

```js
> var d = {a:1}, s1 = {a:2, b:3, c:4}, s2 = {c:5, d:6}
> Object.assign(d, s1, s2)  // 浅拷贝 (只包含 enumerable own properties), 最终 d 的 property value 是参数从右往左依次查找的结果.
{ a: 2, b: 3, c: 5, d: 6 }
> {...d, ...s1, ...s2}
{ a: 2, b: 3, c: 5, d: 6 }
```

```js
// enumerate string properties 的 顺序 是可预测的.
Object.keys({'b':0, '10':0, 'a':0, '2':0})  // 先是升序排列的自然数, 再是按插入时间排列的 string.
```

```js
{0:233}['0']  /* 除了 symbol, 任何 property name 都会被转为 string.  */
```

```js
{for: 1, let: 2, return: 3}.return  // property name 可以是任何关键字, 毫无限制.
```

```JavaScript
console.assert(isNaN(NaN*0))  // 按理说 NaN 是有传播性的,
console.assert(NaN**0 === 1)  // 但是... 这是唯一违反 NaN 传播性的例外.
```

```js
// 与 IEEE 754 不兼容的地方:
console.assert(isNaN(1**NaN) && isNaN(1**Infinity))  // IEEE 754 指定结果应为 1.
```

```JavaScript
> 2**53  // number 使用 double 浮点数, 这就是可以精确表示的连续整数的最大值了.
9007_1992_5474_0992
> Date.now() * 1000  // 自 UNIX Time Epoch 起的微秒数, 居然这么大, 赶上同一个数量级了.
1751_1078_3305_9000
```

```JavaScript
var a = '2', b = '3'
var a_plus_b = +a + +b  // +varname === Number(varname)
```

```JavaScript
> (-3)**-2  // unary '-' 的结合性 > '**', 因此此处可以省略指数的括号.
0.1111111111111111
```

```JavaScript
> (4.2>>>0) + (6.9>>>0)  // bitwise-operator 把 double static_cast 到 int32_t 再执行 bitwise-operation.
10
```

```JavaScript
// null 和 undefined 使用恋人规则, 仅它俩可以通过相等性检查 ('==').
console.assert(null == null && undefined == undefined && null == undefined)
console.assert(null != 0 && undefined != 0)
console.assert(null >= 0 && undefined >= 0)  // 比较运算符是另一回事.
```

```HTML
<script><!--
    'JavaScript 代码...'
//--></script>
```

```JavaScript
// NaN 通过不了任何相等性检查 ('==').
console.assert(NaN != NaN)  // 它甚至自己都不 == 自己!
console.assert(!(NaN <= 0) && !(0 <= NaN))  // 更别谈参与 comparison 了.
```

```JavaScript
> !!''  //  用 '!!' 将值转换为 boolean.
false
```

```JavaScript
!function() {
    labelName: for (let i=0; ; ++i)
        for (let j=0; ; ++j) {
            console.log(i, j)
            break labelName  // break/continue 作用于 被 labelName 标记的 循环层级.
        }
}()

!function() {
    outer: {
        console.log('outer: before break')
        inner: {
            console.log('inner: before break')
            break outer  // 'break labelName' 句式是用来跳出代码块的通用方法.  此处 'continue' 非法 (它只在循环体内有效).
            console.log('inner: after break')
        }
        console.log('outer: after break')
    }
}()
```

```JavaScript
> function f(a=console.log('*')) {console.log('--')}
> f(), f(undefined), f(null)  // 默认参数每次被传 undefined (或无值) 都会求值.
*
--
*
--
--
```

```html
<!DOCTYPE html>
<html>
<script>
f()
function f() {
    var a = 1
    debugger  // 设置断点.  仅在 F12 时生效, 对普通用户无影响.
}
</script>
</html>
```

```JavaScript
{[prompt('属性: ')]: 233, [prompt('方法: ')]() {}}  // 计算属性 (computed property)
```

```js
var name = 'shynur'
{name, age: 22}  // 属性值简写 (property value shorthand)
```

___

## TODO / DONE

### JavaScript TODO

- <https://javascript.info/classes>
- <https://javascript.info/custom-errors>
- <https://javascript.info/proxy>

### Browser DONE

### Additional DONE

## License

### Additional Terms

This document and its historical versions may NOT be used to
train, fine-tune, or improve any artificial intelligence or
machine learning models, in any form or for any purpose.

<footer>
    <small>
        Copyright &copy; 2025  谢骐 &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.
        All rights reserved.
    </small>
</footer>
