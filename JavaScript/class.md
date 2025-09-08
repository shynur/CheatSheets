由 `class` 创建的 constructor 具备 `[[IsClassConstructor]]:true`.
带有 `[[IsClassConstructor]]:true` 的 function 只允许通过 `new` 调用:

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

*Class field*, 类似于 C++ constructor 的成员初始化列表.

```js
> new class {
      x  // 声明名为 'x' 的 class field, 隐式赋值为 undefined.
      y = 1  // 直接赋值也是声明 class field.
      z = this.y + 1  // 按顺序执行, 因此此时 `this.y === 1`.
      getZ = () => this.z  // 相当于放在 constructor 中, 可以有效捕获 `this`.
  }().getZ()
2
```

_______________________________________

*Derived constructor* 具备 `[[ConstructorKind]]:"derived"`,
因此它自己不新建对象, 而是通过 `super` 委托 *parent constructor*.
由 *parent constructor* 新建的对象的 `__proto__` 就是 *derived constructor* 的 `prototype`,
但除此以外的所有字段都未设置.

默认情况下会自动把 constructor 接收到的实参传递给 parent constructor:

```js
> new class extends class {
      constructor(...args) { console.log(args) }
  } {
      // 默认行为: constructor(...args) { super(...args) }
  }(1, 'b', false)
[1, 'b', false]
```

_______________________________________

`super()` 在新建对象之后, 先初始化 class field,
再恢复 derived constructor 的执行.

```js
> new class extends class {
      a = (console.log("declare class filed 'a'"), 1)
      constructor() {
          console.log('a =', this.a)
      }
  } {
      b = (console.log("declare class filed 'b'"), 2)
      constructor() {
          console.log('before super()')
          super()
          console.log('after super()')
          console.log('b =', this.b)
      }
  }
before super()
declare class filed 'a'
a = 1
declare class filed 'b'
after super()
b = 2
```

_______________________________________

Method 创建时会记住自己的 `[[HomeObject]]`,
从而 `super` 可以调用 `[[HomeObject]].__proto__` 的 method.

```js
> var o = { m() {super.m()} }  // m.[[HomeObject]] === o
> m = o.m
> o.__proto__ = { m() {console.log(233)} }
> m()
233
```

_______________________________________

`class` 的 `static` method/field 也通过 `extends` 继承.

```js
var {x, __proto__: {x: super_x}} = class extends class {
    static x = Symbol()
} {}
console.assert(x == super_x)
```

_______________________________________

`Array.prototype.filter` 和 `Array.prototype.map` 等方法会根据 `this.constructor` 构造结果对象:

```js
new class extends Array {
    [0]='a'; [1]='b'; [2]='c'
}().map(l => l.toUpperCase()).__proto__.__proto__ == [].__proto__
```

但我们可以通过 `Symbol.species` 定制它的行为:

```js
> new class extends Array {
      static get [Symbol.species]() {return Number}
      [0]='a'; [1]='b'; [2]='c'
  }().map(l => l.toUpperCase())
[Number:3] { '0':'A', '1':'B', '2':'C'}
```

________________________________________

`instanceof` 检查 prototype chain,
但我们可以通过 `Symbol.hasInstance` 定制它的行为:

```js
> 1 instanceof class {
      static [Symbol.hasInstance]() {
          return '一切都是我的子类'
      }
  }
true
```

________________________________________

`Object.prototype.toString` 默认生成 `'[object ClassName]'`,
但我们可以通过 `Symbol.toStringTag` 定制它的行为:

```js
> {}.toString.call(
      new class {
          [Symbol.toStringTag] = 'WTF?'
      }
  )
'[object WTF?]'
```

___

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
