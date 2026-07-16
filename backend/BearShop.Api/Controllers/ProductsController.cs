using BearShop.Api.Data;
using BearShop.Api.Dtos;
using BearShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _db;
    public ProductsController(AppDbContext db) => _db = db;

    /// <summary>Lấy toàn bộ sản phẩm (có thể lọc theo danh mục).</summary>
    [HttpGet]
    public async Task<ActionResult<List<Product>>> GetAll([FromQuery] string? category)
    {
        var query = _db.Products.AsQueryable();
        if (!string.IsNullOrWhiteSpace(category) && category != "Tất cả")
            query = query.Where(p => p.Category == category);
        return await query.ToListAsync();
    }

    /// <summary>Lấy chi tiết một sản phẩm.</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Product>> Get(int id)
    {
        var product = await _db.Products.FindAsync(id);
        return product == null ? NotFound() : product;
    }

    /// <summary>Tạo sản phẩm mới (Admin).</summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<Product>> Create(ProductUpsertDto dto)
    {
        var product = new Product
        {
            Name = dto.Name.Trim(),
            Category = dto.Category.Trim(),
            Price = dto.Price,
            Stock = dto.Stock,
            ImageUrl = dto.ImageUrl.Trim(),
            Description = dto.Description.Trim(),
        };
        _db.Products.Add(product);
        await _db.SaveChangesAsync();
        return Ok(product);
    }

    /// <summary>Cập nhật sản phẩm (Admin).</summary>
    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<Product>> Update(int id, ProductUpsertDto dto)
    {
        var product = await _db.Products.FindAsync(id);
        if (product == null) return NotFound();

        product.Name = dto.Name.Trim();
        product.Category = dto.Category.Trim();
        product.Price = dto.Price;
        product.Stock = dto.Stock;
        product.ImageUrl = dto.ImageUrl.Trim();
        product.Description = dto.Description.Trim();
        await _db.SaveChangesAsync();
        return Ok(product);
    }

    /// <summary>Xóa sản phẩm (Admin).</summary>
    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        var product = await _db.Products.FindAsync(id);
        if (product == null) return NotFound();

        _db.Products.Remove(product);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
