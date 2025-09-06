// 输入
prompt("请输入文本");  // 若用户取消了对话框或没有输入任何响应, 则返回 null, 否则返回字符串.
document.write("Wrote something to the HTML document.");

/* DOM (Document Object Model) */  // 对象‘document’是浏览器提供的.
var my_element = document.getElementById("element-id");  // 若 ID 不存在则返回 null.
my_element.innerHTML, my_element.outerHTML;
my_element.getAttribute("attr"),  // 若不存在则返回 null.
my_element.setAttribute("attr", "val");  // 新增/修改 attribute.

// Local Variables:
// coding: utf-8-unix
// End:
