using demo;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using demo.Models;
using demo.Repositories;

namespace demo.Controllers
{
    public class WarrantyController : Controller
    {
        private readonly WarrantyRepository _repository;

        public WarrantyController()
        {
            _repository = new WarrantyRepository();
        }

        // GET: Hiển thị thanh tìm kiếm ban đầu
        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        // POST: Khi người dùng bấm nút "Tra cứu"
        [HttpPost]
        public IActionResult Index(string searchedSerial)
        {
            if (string.IsNullOrEmpty(searchedSerial))
            {
                TempData["Error"] = "Vui lòng nhập mã Serial cần tra cứu!";
                return View();
            }

            // Gọi Repository để tìm kiếm
            WarrantyViewModel model = _repository.CheckWarranty(searchedSerial);

            // Trả kết quả về lại cho View hiển thị
            return View(model);
        }
    }
}





