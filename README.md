# An Phat PC – bản chạy bằng VS Code

Dự án đã được chuyển từ ASP.NET MVC 5 / .NET Framework 4.7.2 sang ASP.NET Core MVC / .NET 10. Các trang, controller, model và thao tác dữ liệu SQL hiện có được giữ lại; session được chuyển sang session của ASP.NET Core.

## Chạy trong VS Code

1. Cài .NET 10 SDK và extension **C# Dev Kit** trong VS Code.
2. Giải nén ZIP, mở đúng thư mục `AnPhatPC-VSCode` trong VS Code.
3. Mở Terminal tại thư mục này và chạy:

   ```powershell
   dotnet restore
   dotnet run
   ```

4. Mở `http://localhost:5000` nếu trình duyệt không tự mở.

Lần đầu `dotnet restore` cần Internet để tải `Microsoft.Data.SqlClient` từ NuGet. Không cần cài lệnh `nuget` riêng hoặc `msbuild`.

## Kết nối SQL Server

Mở `appsettings.json` và sửa `ConnectionStrings:DefaultConnection` cho đúng SQL Server instance trên máy. Bản gốc dùng `localhost\MSSQLSERVER02`; ví dụ nếu máy bạn dùng SQL Express thì thường là `localhost\SQLEXPRESS`.

```json
"DefaultConnection": "Server=localhost\\MSSQLSERVER02;Database=AnPhatDB_Final;Integrated Security=True;TrustServerCertificate=True;"
```

Tạo database `AnPhatDB_Final`, rồi chạy script `Database/AnPhatDB_Final.sql` trong SSMS nếu cần tạo bảng và dữ liệu mẫu. Script này **xóa các bảng cũ rồi tạo lại**, nên chỉ chạy trên database mới hoặc khi bạn chấp nhận reset dữ liệu. Ứng dụng không tự chạy script và không tự xóa database khi khởi động.

Tài khoản mẫu có trong script: `admin` / `123456`.

Nếu trang đăng nhập mở được nhưng thao tác đăng nhập hoặc các trang dữ liệu báo lỗi, thường connection string chưa khớp SQL Server hoặc database chưa được tạo.

## Làm trống thống kê doanh thu

Trang **Thống kê doanh thu** vẫn được giữ lại. Script khởi tạo không còn chèn các hóa đơn mẫu, vì vậy báo cáo mới sẽ hiện tổng 0 và dòng “Chưa có dữ liệu doanh thu.”

Nếu database đã có sáu hóa đơn demo cũ, mở `Database/ClearSampleRevenue.sql` trong SSMS và chạy để xóa đúng các hóa đơn demo ngày 15–20/04/2026 cùng chi tiết hóa đơn tương ứng. Script này giữ lại mọi hóa đơn không khớp ngày giờ và số tiền của dữ liệu mẫu.

Nút quay lại của trình duyệt trên các trang bên trong ứng dụng sẽ đưa bạn về trang chủ.


Tại POS, nút **Thanh toán** sẽ lưu hóa đơn và chi tiết vào `tblInvoice`/`tblInvoiceDetail`, xóa giỏ hàng sau khi lưu và mở trang thống kê. Cần tạo các bảng theo script SQL trước khi thanh toán.



## Mở bằng Visual Studio

Mở `AnPhatPC.sln` trong Visual Studio. Chọn profile `AnPhatPC` rồi nhấn F5. Cài workload ASP.NET and web development và .NET 10 SDK nếu Visual Studio yêu cầu.


Báo cáo doanh thu hiển thị từng hóa đơn, tên nhân viên đã thanh toán và sắp xếp hóa đơn theo nhân viên. Cần đăng nhập trước khi thanh toán để lưu đúng nhân viên.


## Quản lý khách hàng

Trang `Customer/Index` tra cứu theo số điện thoại; nút lưu sẽ thêm hồ sơ nếu chưa có hoặc cập nhật hồ sơ đã có. Với database hiện tại, chạy `Database/AddCustomerTable.sql` trong SSMS một lần. Script này chỉ thêm bảng nếu chưa có và giữ dữ liệu cũ. Không chạy lại script khởi tạo đầy đủ nếu muốn giữ database hiện có.

