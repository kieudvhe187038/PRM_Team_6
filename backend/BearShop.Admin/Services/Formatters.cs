using System.Globalization;

namespace BearShop.Admin.Services;

public static class Formatters
{
    public static string Vnd(double amount) =>
        amount.ToString("N0", CultureInfo.InvariantCulture) + " đ";

    public static string DateTime(DateTime value) => value.ToLocalTime().ToString("HH:mm dd/MM/yyyy");
}
