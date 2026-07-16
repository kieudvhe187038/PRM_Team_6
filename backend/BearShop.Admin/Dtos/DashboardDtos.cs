namespace BearShop.Admin.Dtos;

public class DashboardStatsDto
{
    public double TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public int TotalProducts { get; set; }
    public int TotalCustomers { get; set; }
    public List<OrderDto> RecentOrders { get; set; } = [];
    public List<ProductDto> TopProducts { get; set; } = [];
    public List<DailyRevenueDto> RevenueLast7Days { get; set; } = [];
    public Dictionary<string, int> OrdersByStatus { get; set; } = [];
}

public class DailyRevenueDto
{
    public string Date { get; set; } = string.Empty;
    public double Revenue { get; set; }
}
