using BearShop.Api.Data;
using BearShop.Api.Dtos;
using BearShop.Api.Models;
using BearShop.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly TokenService _tokens;

    public AuthController(AppDbContext db, TokenService tokens)
    {
        _db = db;
        _tokens = tokens;
    }

    /// <summary>Đăng ký tài khoản mới.</summary>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterDto dto)
    {
        var email = dto.Email.Trim().ToLower();
        if (await _db.Users.AnyAsync(u => u.Email == email))
            return Conflict(new { message = "Email này đã được sử dụng." });

        var user = new User
        {
            FullName = dto.FullName.Trim(),
            Email = email,
            Phone = dto.Phone.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
        };
        _db.Users.Add(user);
        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            // Race hiếm: 2 request đăng ký cùng email gần như đồng thời đều
            // qua được check AnyAsync ở trên — unique index sẽ chặn ở đây.
            return Conflict(new { message = "Email này đã được sử dụng." });
        }

        return Ok(ToResponse(user));
    }

    /// <summary>Đăng nhập.</summary>
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginDto dto)
    {
        var email = dto.Email.Trim().ToLower();
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
        if (user == null)
            return Unauthorized(new { message = "Email chưa được đăng ký." });

        if (!BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return Unauthorized(new { message = "Mật khẩu không đúng." });

        if (!user.IsActive)
            return Unauthorized(new { message = "Tài khoản đã bị khóa." });

        return Ok(ToResponse(user));
    }

    private AuthResponse ToResponse(User user) => new()
    {
        Token = _tokens.CreateToken(user),
        FullName = user.FullName,
        Email = user.Email,
        Phone = user.Phone,
        Role = user.Role,
    };
}
