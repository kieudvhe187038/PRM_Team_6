namespace BearShop.Api.Dtos;

/// <summary>Thông tin người dùng hiển thị cho Admin (không có PasswordHash).</summary>
public class UserSummaryDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public int OrderCount { get; set; }
}

/// <summary>Dữ liệu khóa/mở khóa tài khoản.</summary>
public class SetActiveDto
{
    public bool IsActive { get; set; }
}
