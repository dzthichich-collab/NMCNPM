using System.Collections.Generic;
using System.Data;
using demo;
using demo.Models;
using System.Linq;
using System;
using Microsoft.Data.SqlClient;

namespace demo.Repositories;

public class InvoiceRepository
{
    public bool CreateInvoice(IReadOnlyCollection<CartItem> items, int userId)
    {
        if (items == null || items.Count == 0)
        {
            return false;
        }

        var subTotal = items.Sum(item => item.UnitPrice * item.Quantity);
        var discount = items.Count >= 3 ? subTotal * 0.05m : 0m;

        using var connection = new SqlConnection(DatabaseSettings.ConnectionString);
        connection.Open();
        using var transaction = connection.BeginTransaction();

        try
        {
            const string insertInvoice = @"
                INSERT INTO dbo.tblInvoice (user_id, total_amount, discount_amount)
                OUTPUT INSERTED.invoice_id
                VALUES (@userId, @totalAmount, @discountAmount);";

            int invoiceId;
            using (var command = new SqlCommand(insertInvoice, connection, transaction))
            {
                command.Parameters.Add("@userId", SqlDbType.Int).Value = userId;
                command.Parameters.Add("@totalAmount", SqlDbType.Decimal).Value = subTotal;
                command.Parameters["@totalAmount"].Precision = 18;
                command.Parameters["@totalAmount"].Scale = 2;
                command.Parameters.Add("@discountAmount", SqlDbType.Decimal).Value = discount;
                command.Parameters["@discountAmount"].Precision = 18;
                command.Parameters["@discountAmount"].Scale = 2;
                invoiceId = Convert.ToInt32(command.ExecuteScalar());
            }

            // Older copies of the database may not have the optional detail table.
            // The invoice header still records the amount and employee for revenue reporting.
            bool hasInvoiceDetailTable;
            using (var checkCommand = new SqlCommand("SELECT CASE WHEN OBJECT_ID(N'dbo.tblInvoiceDetail', N'U') IS NULL THEN 0 ELSE 1 END;", connection, transaction))
            {
                hasInvoiceDetailTable = Convert.ToInt32(checkCommand.ExecuteScalar()) == 1;
            }

            if (hasInvoiceDetailTable)
            {
                const string insertDetail = @"
                    INSERT INTO dbo.tblInvoiceDetail (invoice_id, product_id, quantity, unit_price)
                    VALUES (@invoiceId, @productId, @quantity, @unitPrice);";

                foreach (var item in items)
                {
                    using var command = new SqlCommand(insertDetail, connection, transaction);
                    command.Parameters.Add("@invoiceId", SqlDbType.Int).Value = invoiceId;
                    command.Parameters.Add("@productId", SqlDbType.Int).Value = item.ProductId;
                    command.Parameters.Add("@quantity", SqlDbType.Int).Value = item.Quantity;
                    command.Parameters.Add("@unitPrice", SqlDbType.Decimal).Value = item.UnitPrice;
                    command.Parameters["@unitPrice"].Precision = 18;
                    command.Parameters["@unitPrice"].Scale = 2;
                    command.ExecuteNonQuery();
                }
            }
            transaction.Commit();
            return true;
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }
}


