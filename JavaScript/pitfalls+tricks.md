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

___

&copy; 2025  [谢骐](https://github.com/shynur) \<<shynur@outlook.com>\>.  All rights reserved.
