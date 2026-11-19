using System.Linq;
using demo;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using demo.Repositories;
using demo.Models;

namespace demo.Controllers
{
    public class ReportController : Controller
    {
        private ReportRepository repo = new ReportRepository();

        public IActionResult Revenue()
        {
            var data = repo.GetRevenue();
            ViewBag.TotalRevenue = data.Sum(x => x.Total);
            ViewBag.CheckoutMessage = TempData["CheckoutMessage"];
            return View(data);
        }
    }
}






