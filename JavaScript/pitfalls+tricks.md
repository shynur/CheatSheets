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
// null 和 undefined 使用恋人规则, 仅它俩相等 ('==').
console.assert(null == null && undefined == undefined && null == undefined)
console.assert(null != 0 && undefined != 0)
```

___

&copy; 2025  [谢骐](https://github.com/shynur) <shynur@outlook.com>.  All rights reserved.
