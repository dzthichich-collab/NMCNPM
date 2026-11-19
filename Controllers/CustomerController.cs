using demo.Models;
using demo.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace demo.Controllers
{
    public class CustomerController : Controller
    {
        private readonly CustomerRepository _repository = new CustomerRepository();

        [HttpGet]
        public IActionResult Index(string phone = "")
        {
            ViewBag.SearchPhone = phone;
            ViewBag.CustomerMessage = TempData["CustomerMessage"];

            if (string.IsNullOrWhiteSpace(phone))
            {
                return View(new Customer());
            }

            try
            {
                var customer = _repository.GetByPhone(phone);
                if (customer == null)
                {
                    ViewBag.NotFound = true;
                    ViewBag.SearchPhone = phone.Trim();
                    return View(new Customer { Phone = phone.Trim() });
                }

                ViewBag.CustomerFound = true;
                return View(customer);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Lỗi tra cứu khách hàng: " + ex.Message);
                ViewBag.CustomerError = "Không thể truy cập dữ liệu khách hàng. Hãy kiểm tra bảng tblCustomer trong database.";
                return View(new Customer { Phone = phone.Trim() });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Save(Customer customer)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.SearchPhone = customer.Phone;
                return View("Index", customer);
            }

            try
            {
                _repository.Save(customer);
                TempData["CustomerMessage"] = "Đã lưu hồ sơ khách hàng.";
                return RedirectToAction("Index", new { phone = customer.Phone.Trim() });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Lỗi lưu khách hàng: " + ex.Message);
                ViewBag.SearchPhone = customer.Phone;
                ViewBag.CustomerError = "Không thể lưu hồ sơ. Hãy kiểm tra kết nối database và bảng tblCustomer.";
                return View("Index", customer);
            }
        }
    }
}
