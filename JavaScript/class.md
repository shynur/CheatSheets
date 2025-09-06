由 `class` 创建的 constructor 有 `[[IsClassConstructor]]: true`.
带有 `[[IsClassConstructor]]: true` 的 function 只允许通过 `new` 调用:

```js
> !class{}()
Uncaught TypeError: Class constructors cannot be invoked without 'new'
```

________________________________________

*Class methods* are non-enumerable.
因此不会出现在 `for-in` loop 中.

```js
> Object.getOwnPropertyDescriptors(class{m(){}}.prototype)
{
    constructor: {
        value: 类constructor,
        enumerable: false, writable: true, configurable: true
    },  // 不可枚举 ^^^^^
    m: {
        value: function() {/*...*/},
        enumerable: false, writable: true, configurable: true
    }  // 不可枚举  ^^^^^
}
```

________________________________________

声明 `class` 的作用域规则类似 `let`.

________________________________________

`class` body 默认开启 *strict mode*.

```js
> new class{ _ = function() {return this}() }
{ _: undefined }
```

________________________________________

Class field, 类似于 C++ constructor 的成员初始化列表.

```js
> new class {
      x  // 声明名为 'x' 的 class field.
      y = 1  // 直接赋值也是声明 class field.
      z = this.y + 1  // 按顺序执行, 因此此时 `this.y === 1`.
      getZ = () => this.z  // 相当于放在 constructor 中, 可以有效捕获 `this`.
  }().getZ()
2
```