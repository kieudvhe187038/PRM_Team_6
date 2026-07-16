using BearShop.Api.Data;
using BearShop.Api.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

/// <summary>Quản lý người dùng (chỉ Admin).</summary>
[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _db;
    public UsersController(AppDbContext db) => _db = db;

    /// <summary>Danh sách toàn bộ người dùng kèm số đơn hàng.</summary>
    [HttpGet]
    public async Task<ActionResult<List<UserSummaryDto>>> GetAll()
    {
        var orderCounts = await _db.Orders
            .GroupBy(o => o.UserId)
            .Select(g => new { UserId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(g => g.UserId, g => g.Count);

        var users = await _db.Users.OrderBy(u => u.FullName).ToListAsync();
        return users.Select(u => new UserSummaryDto
        {
            Id = u.Id,
            FullName = u.FullName,
            Email = u.Email,
            Phone = u.Phone,
            Role = u.Role,
            IsActive = u.IsActive,
            OrderCount = orderCounts.GetValueOrDefault(u.Id, 0),
        }).ToList();
    }

    /// <summary>Khóa/mở khóa tài khoản.</summary>
    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> SetActive(int id, SetActiveDto dto)
    {
        var user = await _db.Users.FindAsync(id);
        if (user == null) return NotFound();

        user.IsActive = dto.IsActive;
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
