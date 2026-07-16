using BearShop.Admin.Services;
using Microsoft.AspNetCore.Mvc;

namespace BearShop.Admin.Controllers;

public class UsersController(BearShopApiClient api) : Controller
{
    public async Task<IActionResult> Index()
    {
        var users = await api.GetUsersAsync();
        return View(users);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> SetActive(int id, bool isActive)
    {
        try
        {
            await api.SetUserActiveAsync(id, isActive);
            TempData["Success"] = isActive ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản.";
        }
        catch (ApiException ex)
        {
            TempData["Error"] = ex.Message;
        }
        return RedirectToAction(nameof(Index));
    }
}
