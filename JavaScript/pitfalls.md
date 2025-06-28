```JavaScript
console.assert(isNaN(NaN*0))  // 按理说 NaN 是有传播性的,
console.assert(NaN**0 === 1)  // 但是...
```
