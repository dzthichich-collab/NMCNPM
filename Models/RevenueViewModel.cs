using System;

namespace demo.Models
{
    public class RevenueViewModel
    {
        public int InvoiceId { get; set; }
        public DateTime Date { get; set; }
        public string EmployeeName { get; set; } = "Chưa xác định";
        public decimal Total { get; set; }
    }
}
