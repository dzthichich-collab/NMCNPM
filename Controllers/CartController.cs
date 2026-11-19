using System.Collections.Generic;
using System.Linq;
using demo;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using demo.Models;
using demo.Repositories;

namespace demo.Controllers
{
    public class CartController : Controller
    {
        private readonly ProductRepository _repo = new ProductRepository();
        private readonly InvoiceRepository _invoiceRepository = new InvoiceRepository();

        // Hiển thị màn hình bán hàng
        public IActionResult Index()
        {
            POSViewModel model = new POSViewModel();
            model.AvailableProducts = _repo.GetAllProducts();

            // Lấy giỏ hàng từ Session
            if (HttpContext.Session.GetObject<List<CartItem>>("Cart") == null)
            {
                HttpContext.Session.SetObject("Cart", new List<CartItem>());
            }
            model.CartItems = HttpContext.Session.GetObject<List<CartItem>>("Cart");

            return View(model);
        }

        // Thêm linh kiện vào giỏ
        public IActionResult AddToCart(int productId)
        {
            List<CartItem> cart = HttpContext.Session.GetObject<List<CartItem>>("Cart") ?? new List<CartItem>();

            // Kiểm tra xem linh kiện đã có trong giỏ chưa
            CartItem existingItem = cart.FirstOrDefault(x => x.ProductId == productId);
            if (existingItem != null)
            {
                existingItem.Quantity++;
            }
            else
            {
                Product p = _repo.GetProductById(productId);
                if (p != null)
                {
                    cart.Add(new CartItem
                    {
                        ProductId = p.ProductId,
                        ProductName = p.ProductName,
                        UnitPrice = p.Price,
                        Quantity = 1,
                        Category = p.Category
                    });
                }
            }

            HttpContext.Session.SetObject("Cart", cart);
            return RedirectToAction("Index");
        }

        // Xóa giỏ hàng
        public IActionResult ClearCart()
        {
            HttpContext.Session.SetObject("Cart", new List<CartItem>());
            return RedirectToAction("Index");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Checkout()
        {
            var cart = HttpContext.Session.GetObject<List<CartItem>>("Cart") ?? new List<CartItem>();
            if (cart.Count == 0)
            {
                TempData["CheckoutError"] = "Giỏ hàng đang trống, chưa thể thanh toán.";
                return RedirectToAction("Index");
            }

            var user = HttpContext.Session.GetObject<UserSession>("UserSession");
            if (user == null)
            {
                TempData["Success"] = "Vui lòng đăng nhập để ghi nhận nhân viên thanh toán.";
                return RedirectToAction("Login", "Account");
            }
            try
            {
                if (!_invoiceRepository.CreateInvoice(cart, user.UserId))
                {
                    TempData["CheckoutError"] = "Không thể lưu hóa đơn. Vui lòng thử lại.";
                    return RedirectToAction("Index");
                }

                HttpContext.Session.SetObject("Cart", new List<CartItem>());
                TempData["CheckoutMessage"] = "Thanh toán thành công. Hóa đơn đã được ghi nhận vào thống kê doanh thu.";
                return RedirectToAction("Revenue", "Report");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Lỗi thanh toán: " + ex.Message);
                TempData["CheckoutError"] = "Thanh toán thất bại. Hãy kiểm tra kết nối và cấu trúc database.";
                return RedirectToAction("Index");
            }
        }
        public IActionResult PrintInvoice()
        {
            var cartItems = HttpContext.Session.GetObject<List<CartItem>>("Cart") ?? new List<CartItem>();

            var model = new POSViewModel
            {
                CartItems = cartItems
            };

            return View("InvoicePrint", model);
        }
    }
}







