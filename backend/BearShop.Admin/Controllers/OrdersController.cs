using BearShop.Admin.Dtos;
using BearShop.Admin.Services;
using Microsoft.AspNetCore.Mvc;

namespace BearShop.Admin.Controllers;

public class OrdersController(BearShopApiClient api) : Controller
{
    public async Task<IActionResult> Index()
    {
        var orders = await api.GetAllOrdersAsync();
        return View(orders);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateStatus(int id, string status)
    {
        try
        {
            await api.UpdateOrderStatusAsync(id, status);
            TempData["Success"] = "Đã cập nhật trạng thái đơn hàng.";
        }
        catch (ApiException ex)
        {
            TempData["Error"] = ex.Message;
        }
        return RedirectToAction(nameof(Index));
    }
}
