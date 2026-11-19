using demo;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using demo.Models;
using demo.Repositories;

namespace demo.Controllers
{
    public class ProductController : Controller
    {
        private readonly ProductRepository _repo = new ProductRepository();

        // Hiển thị danh sách linh kiện hiện có
        public IActionResult Index()
        {
            var list = _repo.GetAllProducts();
            return View(list);
        }

        // Giao diện Thêm mới (STT 1)
        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Create(Product p)
        {
            if (ModelState.IsValid)
            {
                if (_repo.InsertProduct(p)) return RedirectToAction("Index");
            }
            return View(p);
        }

        // Giao diện Cập nhật (STT 2)
        [HttpGet]
        public IActionResult Edit(int id)
        {
            var p = _repo.GetProductById(id);
            return View(p);
        }

        [HttpPost]
        public IActionResult Edit(Product p)
        {
            if (ModelState.IsValid)
            {
                if (_repo.UpdateProduct(p)) return RedirectToAction("Index");
            }
            return View(p);
        }

        // Xử lý Xóa (STT 3)
        public IActionResult Delete(int id)
        {
            if (!_repo.DeleteProduct(id))
            {
                TempData["Error"] = "Không thể xóa linh kiện này vì đã có serial trong kho hoặc nằm trong hóa đơn.";
            }
            return RedirectToAction("Index");
        }
    }
}





