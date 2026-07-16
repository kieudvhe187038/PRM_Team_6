using BearShop.Admin.Dtos;
using BearShop.Admin.Services;
using Microsoft.AspNetCore.Mvc;

namespace BearShop.Admin.Controllers;

public class ProductsController(BearShopApiClient api) : Controller
{
    public async Task<IActionResult> Index()
    {
        var products = await api.GetProductsAsync();
        return View(products);
    }

    public IActionResult Create()
    {
        ViewData["Categories"] = ProductCategories.All;
        return View(new ProductUpsertDto());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(ProductUpsertDto dto)
    {
        if (!ModelState.IsValid)
        {
            ViewData["Categories"] = ProductCategories.All;
            return View(dto);
        }

        try
        {
            await api.CreateProductAsync(dto);
            TempData["Success"] = "Đã thêm sản phẩm mới.";
            return RedirectToAction(nameof(Index));
        }
        catch (ApiException ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            ViewData["Categories"] = ProductCategories.All;
            return View(dto);
        }
    }

    public async Task<IActionResult> Edit(int id)
    {
        var product = await api.GetProductAsync(id);
        ViewData["Categories"] = ProductCategories.All;
        return View(new ProductEditViewModel
        {
            Id = product.Id,
            Name = product.Name,
            Category = product.Category,
            Price = product.Price,
            Stock = product.Stock,
            ImageUrl = product.ImageUrl,
            Description = product.Description,
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, ProductEditViewModel model)
    {
        if (!ModelState.IsValid)
        {
            ViewData["Categories"] = ProductCategories.All;
            return View(model);
        }

        try
        {
            await api.UpdateProductAsync(id, new ProductUpsertDto
            {
                Name = model.Name,
                Category = model.Category,
                Price = model.Price,
                Stock = model.Stock,
                ImageUrl = model.ImageUrl,
                Description = model.Description,
            });
            TempData["Success"] = "Đã lưu thay đổi sản phẩm.";
            return RedirectToAction(nameof(Index));
        }
        catch (ApiException ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            ViewData["Categories"] = ProductCategories.All;
            return View(model);
        }
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            await api.DeleteProductAsync(id);
            TempData["Success"] = "Đã xóa sản phẩm.";
        }
        catch (ApiException ex)
        {
            TempData["Error"] = ex.Message;
        }
        return RedirectToAction(nameof(Index));
    }
}
