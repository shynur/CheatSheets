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
console.assert(NaN**0 === 1)  // 但是...
```

```JavaScript
> 2**53  // number 使用 double 浮点数, 这就是可以精确表示的连续整数的最大值了.
9007199254740992
> Date.now() * 1000  // 自 UNIX Time Epoch 起的微秒数, 居然这么大, 赶上同一个数量级了.
1751107833059000
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
console.assert(NaN <= 0 == false && NaN >= 0 == false)  // 更别谈参与 comparison 了.
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
{[prompt('属性: ')]: 233}  // 计算属性 (computed property)
```

```js
var name = 'shynur'
{name, age: 22}  // 属性值简写 (property value shorthand)
```

___

&copy; 2025  [谢骐](https://github.com/shynur) \<<shynur@outlook.com>\>.  All rights reserved.
