// 输入
prompt("请输入文本");  // 若用户取消了对话框或没有输入任何响应, 则返回 null, 否则返回字符串.
document.write("Wrote something to the HTML document.");

/* Object */
var my_obj = {
    // 属性名可以是字符串, 不加引号时要遵循变量命名规则.
     property_1 : true,
    'property-2': function(arg) {
        this.property_1 = false;  // ‘this’是在方法被调用 (而非被定义) 时设置的.
    }  // 不加多余的逗号以提高可移植性.
};
// 若成功删除了属性, 则返回‘true’(即使要删除的属性本就不存在), 否则‘false’(e.g., 有些对象属于浏览器, 因而受到保护, 会删除失败).
my_obj.property_3 = 'new property', delete my_obj.property_3;

/* DOM (Document Object Model) */  // 对象‘document’是浏览器提供的.
var my_element = document.getElementById("element-id");  // 若 ID 不存在则返回 null.
my_element.innerHTML, my_element.outerHTML;
my_element.getAttribute("attr"),  // 若不存在则返回 null.
my_element.setAttribute("attr", "val");  // 新增/修改 attribute.

// Local Variables:
// coding: utf-8-unix
// End:
