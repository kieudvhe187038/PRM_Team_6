namespace BearShop.Api.Models;

/// <summary>Tài khoản người dùng lưu trong CSDL.</summary>
public class User
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;

    /// <summary>Mật khẩu đã được băm bằng BCrypt (không lưu plaintext).</summary>
    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>Vai trò: "Customer" hoặc "Admin".</summary>
    public string Role { get; set; } = "Customer";

    /// <summary>Tài khoản có bị khóa hay không (do Admin quản lý).</summary>
    public bool IsActive { get; set; } = true;

    public List<Order> Orders { get; set; } = new();
}
