using demo;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace demo.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            // BẢO MẬT: Kiểm tra xem người dùng đã đăng nhập chưa (Biến Session có tồn tại không)
            if (HttpContext.Session.GetObject<demo.Models.UserSession>("UserSession") == null)
            {
                // Nếu chưa đăng nhập, tự động đá về trang Login
                return RedirectToAction("Login", "Account");
            }

            // Nếu đã đăng nhập rồi thì cho phép xem trang chủ
            return View();
        }
    }
}





