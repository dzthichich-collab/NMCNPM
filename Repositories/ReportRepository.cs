using System;
using System.Collections.Generic;
using demo;
using demo.Models;
using Microsoft.Data.SqlClient;

namespace demo.Repositories
{
    public class ReportRepository
    {
        private readonly string _connectionString = DatabaseSettings.ConnectionString;

        public List<RevenueViewModel> GetRevenue()
        {
            var list = new List<RevenueViewModel>();
            const string query = @"
                SELECT
                    invoice.invoice_id AS InvoiceId,
                    invoice.created_at AS Ngay,
                    COALESCE(NULLIF(userAccount.full_name, N''), userAccount.username, N'Chưa xác định') AS EmployeeName,
                    invoice.total_amount - invoice.discount_amount AS DoanhThu
                FROM dbo.tblInvoice AS invoice
                LEFT JOIN dbo.tblUser AS userAccount ON userAccount.user_id = invoice.user_id
                ORDER BY COALESCE(NULLIF(userAccount.full_name, N''), userAccount.username, N'Chưa xác định'), invoice.created_at DESC, invoice.invoice_id DESC;";

            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(query, connection);
            connection.Open();
            using var reader = command.ExecuteReader();
            while (reader.Read())
            {
                list.Add(new RevenueViewModel
                {
                    InvoiceId = Convert.ToInt32(reader["InvoiceId"]),
                    Date = Convert.ToDateTime(reader["Ngay"]),
                    EmployeeName = Convert.ToString(reader["EmployeeName"]),
                    Total = Convert.ToDecimal(reader["DoanhThu"])
                });
            }

            return list;
        }
    }
}

