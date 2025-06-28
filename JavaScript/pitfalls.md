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
