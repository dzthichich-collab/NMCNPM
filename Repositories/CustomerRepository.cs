using System;
using demo;
using demo.Models;
using Microsoft.Data.SqlClient;

namespace demo.Repositories
{
    public class CustomerRepository
    {
        private readonly string _connectionString = DatabaseSettings.ConnectionString;

        public Customer GetByPhone(string phone)
        {
            const string query = @"
                SELECT customer_id, full_name, phone, email, address
                FROM dbo.tblCustomer
                WHERE phone = @phone;";

            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@phone", phone.Trim());
            connection.Open();
            using var reader = command.ExecuteReader();
            if (!reader.Read()) return null;

            return new Customer
            {
                CustomerId = Convert.ToInt32(reader["customer_id"]),
                FullName = Convert.ToString(reader["full_name"]),
                Phone = Convert.ToString(reader["phone"]),
                Email = reader["email"] == DBNull.Value ? string.Empty : Convert.ToString(reader["email"]),
                Address = reader["address"] == DBNull.Value ? string.Empty : Convert.ToString(reader["address"])
            };
        }

        public void Save(Customer customer)
        {
            const string query = @"
                IF EXISTS (SELECT 1 FROM dbo.tblCustomer WHERE phone = @phone)
                BEGIN
                    UPDATE dbo.tblCustomer
                    SET full_name = @fullName,
                        email = @email,
                        address = @address,
                        updated_at = GETDATE()
                    WHERE phone = @phone;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.tblCustomer (full_name, phone, email, address)
                    VALUES (@fullName, @phone, @email, @address);
                END;";

            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@phone", customer.Phone.Trim());
            command.Parameters.AddWithValue("@fullName", customer.FullName.Trim());
            command.Parameters.AddWithValue("@email", string.IsNullOrWhiteSpace(customer.Email) ? DBNull.Value : customer.Email.Trim());
            command.Parameters.AddWithValue("@address", string.IsNullOrWhiteSpace(customer.Address) ? DBNull.Value : customer.Address.Trim());
            connection.Open();
            command.ExecuteNonQuery();
        }
    }
}
