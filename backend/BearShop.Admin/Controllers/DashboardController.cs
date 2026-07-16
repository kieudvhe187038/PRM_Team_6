using BearShop.Admin.Services;
using Microsoft.AspNetCore.Mvc;

namespace BearShop.Admin.Controllers;

public class DashboardController(BearShopApiClient api) : Controller
{
    public async Task<IActionResult> Index()
    {
        var stats = await api.GetDashboardAsync();
        return View(stats);
    }
}
