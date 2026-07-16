namespace BearShop.Admin.Services;

/// <summary>Lỗi trả về từ BearShop.Api (message lấy từ body JSON { "message": "..." } khi có).</summary>
public class ApiException(string message) : Exception(message);
