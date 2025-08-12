```js
/*
 * - 解构 array 可以用 逗号 忽略部分赋值
 * - 解构 array 时等号右侧可以是任何 iterable (本质是 for-of 语法糖)
 * 
 */
var [
    /*  */ {width, height: H = prompt("高度"), title: menu_title, unknown},
    /*  */ q1 = prompt('Q1'), q2 = prompt('Q2'),
    /*  */ firstName, , title,
    /*  */ ...rest
] = [
    /*  */ {
        title: "Menu",
        width: 100,
        height: 200,
    },
    /*  */ 'A1', ,
    /*  */ "Julius", "Caesar", "Consul",
    /*  */ "of the Roman Republic", "something else"
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
var arr = [1, 2]
var arr_like = {0: 'A', 1: 'B', length: 2},
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

// Object.keys/values/entries 和 for-in 等常规枚举方式都会忽略 symbol key:
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
+function() {
    labelName: for (let i=0; ; ++i)
        for (let j=0; ; ++j) {
            console.log(i, j)
            break labelName  // break/continue 作用于 被 labelName 标记的 循环层级.
        }
}()

+function() {
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

&copy; 2025  [谢骐](https://github.com/shynur) \<<shynur@outlook.com>\>.  All rights reserved.
