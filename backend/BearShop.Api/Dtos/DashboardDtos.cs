using BearShop.Api.Models;

namespace BearShop.Api.Dtos;

/// <summary>Số liệu tổng quan cho Dashboard quản lý.</summary>
public class DashboardStatsDto
{
    public double TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public int TotalProducts { get; set; }
    public int TotalCustomers { get; set; }
    public List<Order> RecentOrders { get; set; } = new();
    public List<Product> TopProducts { get; set; } = new();
    public List<DailyRevenueDto> RevenueLast7Days { get; set; } = new();
    public Dictionary<string, int> OrdersByStatus { get; set; } = new();
}

/// <summary>Doanh thu của 1 ngày.</summary>
public class DailyRevenueDto
{
    public string Date { get; set; } = string.Empty; // yyyy-MM-dd
    public double Revenue { get; set; }
}
