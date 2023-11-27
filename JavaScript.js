/* JavaScript 关键字
   break     delete   for         let        super   void
   case      do       function    new        switch  while
   catch     else     if          package    this    with
   class     enum     implements  private    throw   yield
   const     export   import      protected  true
   continue  extends  in          public     try
   debugger  false    instanceof  return     typeof
   default   finally  interface   static     var
*/

// 基本类型变量 (e.g., number, string, boolean) 存储值, 对象变量存储引用.

// 以 ‘$’ 打头的变量名通常保留用于 JS 库; 有些作者根据各种约定使用以 ‘_’ 打头的变量名.
var my_variable_1 = "Hello, " + 'world!',
    my_variable_2;  // <- 其值为 ‘undefined’.

// 输入
prompt("请输入文本");  // 若用户取消了对话框或没有输入任何响应, 则返回 null, 否则返回字符串.
// 输出
alert("Alert!");
document.write("Wrote something to the HTML document.");
console.log("Logged a message.");  // 所有现代浏览器都提供 console, 但 console 并不在标准中.

/* 数学函数 */
Math.random();  // 返回小数∈[0,1).
Math.floor(Math.random() * 10);  // 返回随机的一位数.

/* 作用域 */
// 浏览器加载网页时就开始从上到下地执行文件的 JavaScript 代码,
// 浏览器分两遍读取网页: 1. 读取所有的函数定义; 2. 开始执行代码.
// 因此可以将函数放在文件的任何地方.
my_func(arg);
function my_func(arg /* 按值传递 */) {
    // JavaScript 在函数开始执行时创建所有局部变量而不管它们是否已经声明 (这被称为提升).
    var my_variable_1;  // 该声明 shadow 外层的同名变量.
    global_var = null;  // 首次使用未声明的变量时, 它将自动被视为全局的.  (即使是在函数体内, 正如此例.)
    alert("函数定义语句位于调用语句之后.");
}

/* 数组 */
var my_arr = [], my_arr_0 = new Array(3);
my_arr[1] = my_arr.length;  // 这下变成 sparse 数组了.
my_arr.push('0');  // 此时 ‘my_arr’ 为 “[<1 empty item>, 0, '0']”.
my_arr[0] == undefined;  // => true
my_arr[0] = undefined;  // => [undefined, 0, '0']

/* Object */
var my_obj = {
    // 属性名可以是字符串, 不加引号时要遵循变量命名规则.
     property_1 : true,
    'property_2': function(arg) {
        this.property_1 = false;  // ‘this’ 是在方法被调用 (而非被定义) 时设置的.
    }
    'property-3': 3  // 不加多余的逗号以提高可移植性.
};
// 若成功删除了, 则返回 ‘true’ (即使要删除的属性本就不存在), 否则 ‘false’ (e.g., 有些对象属于浏览器, 因而受到保护, 会删除失败).
my_obj.property_4 = 'new property', delete my_obj.property_4;
// 另一种访问属性的办法:
my_obj['property_1'];  // 更加灵活.

/* DOM (Document Object Model) */  // 对象 ‘document’ 是浏览器提供的.
var my_element = document.getElementById("element-id");  // 若 ID 不存在则返回 null.
my_element.innerHTML, my_element.outerHTML;
my_element.getAttribute("attr"),  // 若不存在则返回 null.
my_element.setAttribute("attr", "val");  // 新增/修改 attribute.

undefined == null, 0 == '';
1 + 2  // ‘+’ 的 结合性 是 从左到右 的:
    + '3' === '33',
true + 1 === 2,
true + 'STR' === 'trueSTR',
'2.5' - 0 === 2.5;
// 非 boolean 也可用在条件表达式中, 它们要么是 falsy 要么是 truthy.  下面是 falsy:
undefined, null, 0, '', NaN;


// Local Variables:
// coding: utf-8-unix
// End:
