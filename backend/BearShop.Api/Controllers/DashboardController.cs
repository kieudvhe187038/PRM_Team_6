using BearShop.Api.Data;
using BearShop.Api.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

/// <summary>Số liệu thống kê tổng quan cho Admin.</summary>
[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class DashboardController : ControllerBase
{
    private readonly AppDbContext _db;
    public DashboardController(AppDbContext db) => _db = db;

    [HttpGet]
    public async Task<ActionResult<DashboardStatsDto>> Get()
    {
        var totalRevenue = await _db.Orders
            .Where(o => o.Status != "cancelled")
            .SumAsync(o => (double?)o.Total) ?? 0;

        var allOrders = await _db.Orders.AsNoTracking().ToListAsync();

        var today = DateTime.UtcNow.Date;
        var revenueLast7Days = Enumerable.Range(0, 7)
            .Select(offset => today.AddDays(-6 + offset))
            .Select(day => new DailyRevenueDto
            {
                Date = day.ToString("yyyy-MM-dd"),
                Revenue = allOrders
                    .Where(o => o.Status != "cancelled" && o.CreatedAt.Date == day)
                    .Sum(o => o.Total),
            })
            .ToList();

        var ordersByStatus = allOrders
            .GroupBy(o => o.Status)
            .ToDictionary(g => g.Key, g => g.Count());

        var stats = new DashboardStatsDto
        {
            TotalRevenue = totalRevenue,
            TotalOrders = allOrders.Count,
            TotalProducts = await _db.Products.CountAsync(),
            TotalCustomers = await _db.Users.CountAsync(u => u.Role == "Customer"),
            RecentOrders = await _db.Orders
                .Include(o => o.Items)
                .OrderByDescending(o => o.CreatedAt)
                .Take(5)
                .ToListAsync(),
            TopProducts = await _db.Products
                .OrderByDescending(p => p.Sold)
                .Take(5)
                .ToListAsync(),
            RevenueLast7Days = revenueLast7Days,
            OrdersByStatus = ordersByStatus,
        };
        return Ok(stats);
    }
}
