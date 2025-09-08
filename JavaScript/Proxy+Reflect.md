# Proxy

## Intro

`Proxy` is a special *exotic object*, 它没有 own property.
`Proxy` 可以 trap *internal method*.

`Proxy` 必须满足一些 invariants.
E.g., Proxy 不能改变 `[[GetPrototypeOf]]` 的返回值.

## 自动生效

任何用到被 trap 的 internal method 的操作都会被影响.

```js
> var numbers = new Proxy(
      [3, 1, 4], {
          set(target, property, value, receiver) {
              if (typeof value == 'number') {
                  target[property] = value
                  return true  // 必须写, 表示 [[Set]] 成功.
              }
              return false  // TypeError when using strict mode
          }
      }
  )
> numbers.push(1)
> numbers.push('5')  // Array.prototype.push uses strict mode.
Uncaught TypeError: 'set' on proxy: trap returned falsish for property '4'
> console.log(numbers)
[3, 1, 4, 1]
```

## 撤销代理

```js
> var {proxy, revoke} = Proxy.revocable({test:233}, {})
> proxy.test
233
> revoke()
> proxy.test
Uncaught TypeError: Cannot perform 'get' on a proxy that has been revoked
```

Proxy object 内所有对 target 的 references 都会被 `revoke()` 移除.

# Reflect

## Intro

`Reflect` 的 static method 实现了对 *internal method* 的封装.

对于每个 *internal method* which is trappable by `Proxy`,
`Reflect` 都有相应的 static method, 名字和参数都与 trapper 的方法一致.

## 给 accessor 绑定 this

```js
{
    __proto__: new Proxy(
        { _name: '默认用户名', get name() {return this._name} },
        {
            get(target, getter, thisArg) {
                // 直接写 target[getter] 拿不到 getter 函数,
                // 因此也无法绑定新的 thisArg.
                return Reflect.get(...arguments)
            }
        }
    ),
    _name: 'shynur'
}.name == 'shynur'
```

# Internal Slot

## Intro

Many built-in objects 使用了 *internal slot*.

E.g., `Map` 不经过 `[[Get]]`, 直接读取 `[[MapData]]` slot 里的数据, 这一步没法被代理.
此外, `#privateField` 也是使用 *internal slot* 实现的, 访问它们不经过 `[[Get]]`/`[[Set]]`.

## 例外

`Array` 诞生得太早了, 因此并未使用 *internal slot*.

# License

## Additional Terms

This document and its historical versions may NOT be used to
train, fine-tune, or improve any artificial intelligence or
machine learning models, in any form or for any purpose.

<footer>
    <small>
        Copyright &copy; 2025  谢骐 &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.
        All rights reserved.
    </small>
</footer>
